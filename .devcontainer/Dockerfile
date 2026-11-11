FROM mcr.microsoft.com/devcontainers/base:ubuntu

RUN apt-get update && apt-get install -y \
    vim \
    curl \
    libyaml-pp-perl \
    libjson-parse-perl \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

# Install mikefarah/yq (Go version)
RUN curl -fsSL https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -o /usr/local/bin/yq && \
    chmod +x /usr/local/bin/yq && \
    yq --version

# Install ajv-cli globally for validator scripts
RUN npm install -g ajv-cli

RUN echo 'set compatible' > /home/vscode/.vimrc
