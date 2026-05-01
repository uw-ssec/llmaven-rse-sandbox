#!/usr/bin/env bash
set -euo pipefail

log() {
  echo "[install-plugins] $*"
}

error() {
  echo "[install-plugins] ERROR: $*" >&2
}

if ! command -v copilot >/dev/null 2>&1; then
  error "copilot CLI not found on PATH"
  exit 1
fi

log "Installing copilot CLI plugin: ai-research-workflows@rse-plugins"
copilot plugin install ai-research-workflows@rse-plugins

log "Copilot CLI plugins installed."
