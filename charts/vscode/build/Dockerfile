FROM buildpack-deps:jammy

ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

# Code Server
ENV CODE_SERVER_VERSION="4.98.2"
RUN curl -fOL https://github.com/cdr/code-server/releases/download/v${CODE_SERVER_VERSION}/code-server_${CODE_SERVER_VERSION}_amd64.deb \
   && apt-get update -qq && apt-get install -qq -y --no-install-recommends \
   ./code-server_${CODE_SERVER_VERSION}_amd64.deb \
   && rm -rf /var/lib/apt/lists/* \
   && rm code-server_${CODE_SERVER_VERSION}_amd64.deb \
   && rm /usr/bin/code-server

# Docker CLI
ENV DOCKER_CLIENT_VERSION="28.0.4"
RUN curl -fsSL -o - https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_CLIENT_VERSION}.tgz | tar -zxf - --strip=1 -C /usr/local/bin/ docker/docker

# Docker Buildx Plugin
ENV DOCKER_BUILDX_VERSION="v0.22.0"
RUN mkdir -p /usr/libexec/docker/cli-plugins && curl -fsSL "https://github.com/docker/buildx/releases/download/${DOCKER_BUILDX_VERSION}/buildx-${DOCKER_BUILDX_VERSION}.linux-amd64" -o /usr/libexec/docker/cli-plugins/docker-buildx && chmod +x /usr/libexec/docker/cli-plugins/docker-buildx

# Docker-in-Docker daemon socket
RUN mkdir -p /var/run/dind && touch /var/run/dind/docker.sock && ln -s /var/run/dind/docker.sock /run/docker.sock

# Kubernetes CLI
ENV KUBECTL_VERSION="v1.32.3"
RUN curl -fsSL "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl" -o /usr/local/bin/kubectl && chmod +x /usr/local/bin/kubectl

# Helm CLI
ENV HELM_VERSION="v3.17.2"
RUN curl -fsSL "https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz" | tar -zxf - --strip=1 -C /usr/local/bin/ linux-amd64/helm

# Java
RUN apt-get update -qq && apt-get install -qq -y --no-install-recommends \
   default-jdk-headless \
   maven \
   gradle \
   && rm -rf /var/lib/apt/lists/*

# Node.js
ENV NODE_VERSION="20"
RUN apt-get update && apt-get install -y ca-certificates curl gnupg \
   && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
   && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_VERSION.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list \
   && apt-get update && apt-get install nodejs -y \
   && rm -rf /var/lib/apt/lists/*

# Python
RUN apt-get update -qq && apt-get install -qq -y --no-install-recommends \
   python3 \
   python3-pip \
   && rm -rf /var/lib/apt/lists/*

# Go
RUN curl -fsSL "https://dl.google.com/go/$(curl --silent -L https://golang.org/VERSION?m=text | grep -m 1 go).linux-amd64.tar.gz" | tar -C /usr/local -xzf -
ENV PATH="/usr/local/go/bin:${PATH}"

# .NET
RUN curl -o packages-microsoft-prod.deb https://packages.microsoft.com/config/debian/12/packages-microsoft-prod.deb \
   && dpkg -i packages-microsoft-prod.deb \
   && rm packages-microsoft-prod.deb \
   && apt-get update \
   && apt-get install -y dotnet-sdk-7.0 \
   && rm -rf /var/lib/apt/lists/*

RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
 && sh -c 'echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' \
 && apt-get update\
 && apt --fix-broken install \
 && apt-get install google-chrome-stable -y

# Delete any existing user and group with ID 1000
RUN deluser --remove-home $(getent passwd 1000 | cut -d: -f1) || true \
   && delgroup $(getent group 1000 | cut -d: -f1) || true \
# Recreate the 'codespace' user and group with ID 1000
   && groupadd -g 1000 -r codespace \
   && useradd -u 1000 -m -r codespace -g codespace


RUN apt-get update -qq && apt-get install -qq -y --no-install-recommends \
   sudo \
   && rm -rf /var/lib/apt/lists/* \
   && adduser codespace sudo \
   && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

ENV HOME=/home/codespace
ENV SHELL=/bin/bash

RUN mkdir /usr/share/codespace \
   && chown codespace:codespace /usr/share/codespace

USER 1000
WORKDIR ${HOME}

COPY --chown=codespace:codespace share/User .local/share/code-server/User
COPY --chown=codespace:codespace share/workspace workspace

RUN ITEM_URL="" SERVICE_URL="https://extensions.coder.com/api" /usr/lib/code-server/bin/code-server \
   --disable-telemetry \
   --disable-update-check \
   --install-extension "redhat.vscode-xml" \
   --install-extension "redhat.vscode-yaml" \
   --install-extension "github.github-vscode-theme" \
   --install-extension "vscode-icons-team.vscode-icons" \
   --install-extension "ms-vscode.live-server" \
   --install-extension "ms-azuretools.vscode-docker" \
   --install-extension "ms-kubernetes-tools.vscode-kubernetes-tools" \
   --install-extension "redhat.java" \
   --install-extension "vscjava.vscode-java-debug" \
   --install-extension "golang.go" \
   --install-extension "ms-python.python" \
   --force \
   && ITEM_URL="https://open-vsx.org/vscode/item" SERVICE_URL="https://open-vsx.org/vscode/gallery" /usr/lib/code-server/bin/code-server \
   --disable-telemetry \
   --disable-update-check \
   --install-extension "muhammad-sammy.csharp" \
   --force \
   && mv workspace /usr/share/codespace/ \
   && rm -r .local/share/code-server/CachedExtensionVSIXs \
   && rm -r .local/share/code-server/coder-logs \
   && rm -r .local/share/code-server/logs \
   && mv .local/share/code-server /usr/share/codespace/ \
   && mv .config/code-server /usr/share/codespace/config \
   && rm -r .config \
   && rm -r .local

COPY --chown=root:root codespace /usr/local/bin/codespace

CMD [ "codespace" ]
