# IT-Tools on a patched nginx.
#
# Upstream's latest image (2024.10.22-7ca5933) is the static site on nginx 1.26.2, which is
# vulnerable to nginx2root (CVE-2026-123007, CVE-2026-123634, CVE-2026-123633, CVE-2026-121810,
# CVE-2026-113425) and upstream has no newer release. Copy the built site and upstream's server
# config onto the official nginx image unchanged: same entrypoint, root master process with nginx
# (UID 101) workers, port 80, `try_files $uri $uri/ /index.html`.
FROM corentinth/it-tools:2024.10.22-7ca5933@sha256:8b8128748339583ca951af03dfe02a9a4d7363f61a216226fc28030731a5a61f AS upstream

FROM nginx:1.30.7-alpine3.24
# apk upgrade pulls the base's security fixes.
RUN apk upgrade --no-cache
COPY --from=upstream /usr/share/nginx/html/ /usr/share/nginx/html/
COPY --from=upstream /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
