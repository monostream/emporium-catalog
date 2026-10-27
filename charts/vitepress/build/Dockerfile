# VitePress live docs: nginx serves the site, poll-and-serve.sh clones GIT_URL,
# builds it with npm and rebuilds whenever origin/main moves.
#
# Node comes from the official image on the same Alpine release (musl), so the
# runtime is a supported Node line instead of whatever nodejs Alpine ships.
FROM node:24.22.1-alpine3.24 AS node

FROM nginx:1.30.6-alpine3.24
# apk upgrade pulls the base's security fixes (e.g. brotli-libs 1.2.1).
RUN apk upgrade --no-cache \
    && apk add --no-cache git libstdc++
COPY --from=node /usr/local/bin/node /usr/local/bin/node
COPY --from=node /usr/local/lib/node_modules /usr/local/lib/node_modules
RUN ln -s ../lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm \
    && ln -s ../lib/node_modules/npm/bin/npx-cli.js /usr/local/bin/npx \
    && node -v && npm -v

WORKDIR /workspace
COPY --chmod=0755 poll-and-serve.sh /usr/local/bin/poll-and-serve.sh
EXPOSE 80
CMD ["/usr/local/bin/poll-and-serve.sh"]
