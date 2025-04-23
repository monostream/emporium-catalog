FROM buildpack-deps:jammy

ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Architecture detection
ARG TARGETARCH

# Code Server
ENV CODE_SERVER_VERSION="4.99.3"
RUN curl -fOL https://github.com/cdr/code-server/releases/download/v${CODE_SERVER_VERSION}/code-server_${CODE_SERVER_VERSION}_${TARGETARCH}.deb \
   && apt-get update -qq && apt-get install -qq -y --no-install-recommends \
   ./code-server_${CODE_SERVER_VERSION}_${TARGETARCH}.deb \
   && rm -rf /var/lib/apt/lists/* \
   && rm code-server_${CODE_SERVER_VERSION}_${TARGETARCH}.deb \
   && rm /usr/bin/code-server

# Docker CLI
ENV DOCKER_CLIENT_VERSION="28.1.1"
RUN if [ "$TARGETARCH" = "arm64" ]; then \
      DOCKER_ARCH="aarch64"; \
    else \
      DOCKER_ARCH="x86_64"; \
    fi \
    && curl -fsSL -o - https://download.docker.com/linux/static/stable/${DOCKER_ARCH}/docker-${DOCKER_CLIENT_VERSION}.tgz | tar -zxf - --strip=1 -C /usr/local/bin/ docker/docker

# Docker Buildx Plugin
ENV DOCKER_BUILDX_VERSION="v0.23.0"
RUN mkdir -p /usr/libexec/docker/cli-plugins && curl -fsSL "https://github.com/docker/buildx/releases/download/${DOCKER_BUILDX_VERSION}/buildx-${DOCKER_BUILDX_VERSION}.linux-${TARGETARCH}" -o /usr/libexec/docker/cli-plugins/docker-buildx && chmod +x /usr/libexec/docker/cli-plugins/docker-buildx

# Docker-in-Docker daemon socket
RUN mkdir -p /var/run/dind && touch /var/run/dind/docker.sock && ln -s /var/run/dind/docker.sock /run/docker.sock

# Kubernetes CLI
ENV KUBECTL_VERSION="v1.32.4"
RUN curl -fsSL "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/${TARGETARCH}/kubectl" -o /usr/local/bin/kubectl && chmod +x /usr/local/bin/kubectl

# Helm CLI
ENV HELM_VERSION="v3.17.3"
RUN curl -fsSL "https://get.helm.sh/helm-${HELM_VERSION}-linux-${TARGETARCH}.tar.gz" | tar -zxf - --strip=1 -C /usr/local/bin/ linux-${TARGETARCH}/helm

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

# Claude Code CLI
RUN npm install -g @anthropic-ai/claude-code

# Python with uv package installer
RUN apt-get update -qq && apt-get install -qq -y --no-install-recommends \
   python3 \
   python3-pip \
   curl \
   && curl -LsSf https://astral.sh/uv/install.sh | sh \
   && ln -s /root/.cargo/bin/uv /usr/local/bin/uv \
   && rm -rf /var/lib/apt/lists/*

# Go
RUN curl -fsSL "https://dl.google.com/go/$(curl --silent -L https://golang.org/VERSION?m=text | grep -m 1 go).linux-${TARGETARCH}.tar.gz" | tar -C /usr/local -xzf -
ENV PATH="/usr/local/go/bin:${PATH}"

# .NET
RUN curl -o packages-microsoft-prod.deb https://packages.microsoft.com/config/debian/12/packages-microsoft-prod.deb \
   && dpkg -i packages-microsoft-prod.deb \
   && rm packages-microsoft-prod.deb \
   && apt-get update \
   && apt-get install -y dotnet-sdk-7.0 \
   && rm -rf /var/lib/apt/lists/*

# Google Chrome installation with architecture detection
RUN apt-get update && apt-get install -y ca-certificates curl gnupg wget && \
    wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - && \
    if [ "$TARGETARCH" = "arm64" ]; then \
        # For arm64, we need to specify the architecture in the sources list
        echo "deb [arch=arm64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google.list && \
        apt-get update && \
        # If Google Chrome install fails on arm64, fall back to Chromium
        (apt-get install -y google-chrome-stable || \
        (apt-get install -y chromium-browser && ln -s /usr/bin/chromium-browser /usr/bin/google-chrome)); \
    else \
        # For amd64, use standard installation
        echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google.list && \
        apt-get update && \
        apt --fix-broken install && \
        apt-get install -y google-chrome-stable; \
    fi && \
    rm -rf /var/lib/apt/lists/*

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

# Install extensions from Open VSX Registry
RUN ITEM_URL="https://open-vsx.org/vscode/item" SERVICE_URL="https://open-vsx.org/vscode/gallery" /usr/lib/code-server/bin/code-server \
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
   --install-extension "ms-python.debugpy" \
   --install-extension "muhammad-sammy.csharp" \
   --install-extension "saoudrizwan.claude-dev" \
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
