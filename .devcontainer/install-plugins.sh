#!/usr/bin/env bash
set -euo pipefail

log() {
  echo "[install-plugins] $*"
}

error() {
  echo "[install-plugins] ERROR: $*" >&2
}

if ! command -v npm >/dev/null 2>&1; then
  error "npm not found on PATH; cannot install copilot CLI"
  exit 1
fi

if ! command -v copilot >/dev/null 2>&1; then
  log "Installing GitHub Copilot CLI..."
  npm install -g @github/copilot
fi

if ! command -v copilot >/dev/null 2>&1; then
  error "copilot CLI still not found after install attempt"
  exit 1
fi

log "Installing copilot CLI plugin: ai-research-workflows@rse-plugins"
copilot plugin install ai-research-workflows@rse-plugins

log "Copilot CLI plugins installed."
