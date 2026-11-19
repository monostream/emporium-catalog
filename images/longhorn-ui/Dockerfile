# Longhorn UI on a patched nginx.
#
# Every published longhornio/longhorn-ui tag (v1.11.x, v1.12.x, v1.13.x) ships SLES nginx 1.21.5,
# which is vulnerable to nginx2root (CVE-2026-123007, CVE-2026-123634, CVE-2026-123633,
# CVE-2026-121810, CVE-2026-113425). Copy the UI build, the nginx config template and
# start-nginx.sh onto the official nginx image and keep upstream's runtime contract:
# - CMD start-nginx.sh renders /etc/nginx/nginx.conf.template into /var/config/nginx/ with
#   envsubst (LONGHORN_MANAGER_IP, LONGHORN_UI_PORT, IPV6_LISTEN) and runs nginx -c on it;
# - runs as UID 499 on port 8000; pid in /run, temp files in /var/cache/nginx (the chart mounts
#   emptyDirs on /var/run, /var/cache/nginx and /var/config/nginx).
# The script needs bash and `ip -6 addr show scope global` (iproute2); envsubst ships in the base.
#
# CI tags the image with the org.opencontainers.image.version label below.
FROM docker.io/longhornio/longhorn-ui:v1.11.1@sha256:9008cce5be4752f7fcef2d0e008076ba5c0c8a6df8f57fb6ab0285b0f49634ab AS upstream

FROM nginx:1.30.7-alpine3.24
LABEL org.opencontainers.image.version="v1.11.1-nginx1.30.7"
# apk upgrade pulls the base's security fixes.
RUN apk upgrade --no-cache \
    && apk add --no-cache bash iproute2 \
    && mkdir -p /var/config /web/dist \
    && touch /run/nginx.pid \
    && chown -R 499 /var/config /run/nginx.pid /var/cache/nginx
WORKDIR /web
COPY --from=upstream /web/dist /web/dist
COPY --from=upstream /etc/nginx/nginx.conf.template /etc/nginx/nginx.conf.template
COPY --from=upstream --chmod=755 /usr/local/bin/start-nginx.sh /usr/local/bin/start-nginx.sh
ENV LONGHORN_MANAGER_IP=http://localhost:9500
ENV LONGHORN_UI_PORT=8000
EXPOSE 8000
USER 499
# The base image's /docker-entrypoint.sh is not used, as upstream.
ENTRYPOINT []
CMD ["/usr/local/bin/start-nginx.sh"]
