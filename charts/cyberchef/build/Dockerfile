# CyberChef on a patched nginx.
#
# Upstream's latest image (11.5.0) is the static site on nginx-unprivileged 1.30.4, which is
# vulnerable to nginx2root (CVE-2026-123007, CVE-2026-123634, CVE-2026-123633, CVE-2026-121810,
# CVE-2026-113425) and upstream has no newer release. Copy the built site and the server config
# onto the official nginx-unprivileged image (nginx/nginx-unprivileged; nginxinc/ stops at 1.30.6):
# same entrypoint, UID 101, port 8080. Upstream serves the base image's stock config.
FROM ghcr.io/gchq/cyberchef:11.5.0@sha256:f04a39926344faf8e4cbbc8c92fb125d2b466f9be62db09aff23c7c406101a51 AS upstream

FROM nginx/nginx-unprivileged:1.30.7-alpine3.24
# apk upgrade pulls the base's security fixes.
USER root
RUN apk upgrade --no-cache
USER 101
COPY --from=upstream /usr/share/nginx/html/ /usr/share/nginx/html/
COPY --from=upstream /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf
EXPOSE 8080
