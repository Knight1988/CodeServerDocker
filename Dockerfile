# syntax=docker/dockerfile:1

FROM ubuntu:noble

ARG CODE_VERSION=latest

ENV HOME="/config"

# Install dependencies and code-server
RUN apt-get update && \
        apt-get install -y wget jq curl gzip && \
        curl -fsSL https://code-server.dev/install.sh | sh -s -- --version "${CODE_VERSION}" && \
        apt-get clean && \
        rm -rf /var/lib/apt/lists/* && \
        sh -c 'if command -v code-server >/dev/null 2>&1; then \
            echo "code-server found at: $(command -v code-server)"; \
            code-server --version || echo "code-server --version failed with $?"; \
        else \
            echo "code-server not found"; \
            echo "PATH=$PATH"; \
            echo "Contents of /usr/local/bin:"; ls -la /usr/local/bin || true; \
            echo "Contents of /usr/bin:"; ls -la /usr/bin || true; \
            echo "Environment (env):"; env || true; \
            exit 1; \
        fi'

# Copy installer for GitHub Copilot extensions and try installing during build
COPY install-copilot.sh /usr/local/bin/install-copilot.sh
RUN chmod +x /usr/local/bin/install-copilot.sh && \
    /usr/local/bin/install-copilot.sh || echo "Build-time Copilot installation failed, will retry at startup"

# Copy entrypoint script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 8443
WORKDIR /config

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
