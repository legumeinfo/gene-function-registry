FROM mcr.microsoft.com/devcontainers/base:ubuntu

RUN apt-get update && apt-get install -y \
    vim \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install mikefarah/yq (Go version)
RUN curl -sSL https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -o /usr/local/bin/yq && \
    chmod +x /usr/local/bin/yq

RUN echo 'set compatible' > /home/vscode/.vimrc

FROM python:3.9-slim-buster

WORKDIR /workspaces/gene-function-registry

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt


