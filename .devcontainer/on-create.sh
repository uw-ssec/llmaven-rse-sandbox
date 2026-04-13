#!/usr/bin/env bash
set -euo pipefail

if [ -e .pixi ]; then
  if [ ! -d .pixi ] || [ -L .pixi ]; then
    echo "Refusing to chown .pixi: must be a real directory, not a symlink" >&2
    exit 1
  fi

  PIXI_REAL="$(realpath -e .pixi)"
  WORKSPACE_REAL="$(realpath -e .)"

  case "$PIXI_REAL" in
    "$WORKSPACE_REAL"|"$WORKSPACE_REAL"/*)
      sudo chown -R --no-dereference vscode:vscode "$PIXI_REAL"
      ;;
    *)
      echo "Refusing to chown .pixi: resolved path is outside the workspace" >&2
      exit 1
      ;;
  esac
fi

pixi install --locked

echo ""
echo "Sandbox setup complete."
echo "Next step: open docs/getting-started.md"
echo "Gateway check: pixi run gateway-check"
