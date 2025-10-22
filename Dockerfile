# syntax=docker/dockerfile:1

FROM ubuntu:noble

ARG CODE_VERSION=latest

ENV HOME="/config"

# Install dependencies and code-server
RUN apt-get update && \
    apt-get install -y wget jq curl && \
    curl -fsSL https://code-server.dev/install.sh | sh -s -- --version "${CODE_VERSION}" && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    which code-server && code-server --version

# Copy VSIX files from the same folder as the Dockerfile
COPY GitHub.copilot.vsix /tmp/GitHub.copilot.vsix
COPY GitHub.copilot-chat.vsix /tmp/GitHub.copilot-chat.vsix

# Install the VSIX extensions
RUN code-server --install-extension /tmp/GitHub.copilot.vsix && \
    code-server --install-extension /tmp/GitHub.copilot-chat.vsix && \
    rm -f /tmp/*.vsix

# Copy entrypoint script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 8443
WORKDIR /config

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
