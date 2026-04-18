#!/usr/bin/env bash
set -euo pipefail

echo "[on-create] Preparing workspace..."

if [ -e .pixi ]; then
  if [ ! -d .pixi ] || [ -L .pixi ]; then
    echo "Refusing to chown .pixi: must be a real directory, not a symlink" >&2
    exit 1
  fi

  PIXI_REAL="$(realpath .pixi)"
  WORKSPACE_REAL="$(realpath .)"

  case "$PIXI_REAL" in
    "$WORKSPACE_REAL"/*) ;;
    *)
      echo "Refusing to chown .pixi: resolved path '$PIXI_REAL' is outside workspace '$WORKSPACE_REAL'" >&2
      exit 1
      ;;
  esac

  sudo chown -R --no-dereference vscode:vscode "$PIXI_REAL"
fi

echo "[on-create] Installing pixi environment..."
pixi install --locked

echo ""
echo "[on-create] Workspace bootstrap complete."
echo "[on-create] Next step: open docs/getting-started.md"
