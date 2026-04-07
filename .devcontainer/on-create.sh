#!/usr/bin/env bash
set -euo pipefail

if [ -d .pixi ]; then
  sudo chown -R vscode:vscode .pixi || true
fi

pixi install

echo ""
echo "Sandbox setup complete."
echo "Next step: open docs/getting-started.md"
echo "Gateway check: pixi run gateway-check"
