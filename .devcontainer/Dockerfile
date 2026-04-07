# Base image intentionally uses "base" (not python) because
# environment + dependencies are managed via pixi, not system Python.
FROM mcr.microsoft.com/devcontainers/base:jammy

ARG PIXI_VERSION=v0.63.2

RUN apt-get update && apt-get install -y \
    curl \
    git \
    jq \
    && rm -rf /var/lib/apt/lists/*

RUN curl -L -o /usr/local/bin/pixi -fsSL --compressed \
    "https://github.com/prefix-dev/pixi/releases/download/${PIXI_VERSION}/pixi-$(uname -m)-unknown-linux-musl" \
    && chmod +x /usr/local/bin/pixi \
    && pixi info

ENV VSCODE_HOME=/home/vscode \
    VSCODE_USER=vscode \
    SHELL=/bin/bash

USER ${VSCODE_USER}
WORKDIR /workspaces/llmaven-rse-sandbox

RUN echo 'eval "$(pixi completion -s bash)"' >> ${VSCODE_HOME}/.bashrc