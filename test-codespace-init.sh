#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}"

WORKSPACE_FOLDER="${WORKSPACE_FOLDER:-$(pwd)}"
SKIP_GATEWAY_CHECK="${SKIP_GATEWAY_CHECK:-0}"

echo "[codespace-init-test] Workspace: ${WORKSPACE_FOLDER}"

require_host_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "[codespace-init-test] ERROR: required host command not found: $1" >&2
    exit 1
  fi
}

require_host_cmd docker
require_host_cmd devcontainer

echo ""
echo "[codespace-init-test] Removing existing devcontainer for this workspace, if any..."
existing_containers="$(docker ps -aq --filter "label=devcontainer.local_folder=${WORKSPACE_FOLDER}")"

if [ -n "${existing_containers}" ]; then
  docker rm -f ${existing_containers}
else
  echo "[codespace-init-test] No existing devcontainer found."
fi

echo ""
echo "[codespace-init-test] Starting fresh devcontainer init..."
devcontainer up \
  --workspace-folder "${WORKSPACE_FOLDER}"

echo ""
echo "[codespace-init-test] Verifying required tools..."
devcontainer exec \
  --workspace-folder "${WORKSPACE_FOLDER}" \
  bash -lc 'set -euo pipefail; command -v git; command -v node; command -v npm; command -v code; command -v pixi'

echo ""
echo "[codespace-init-test] Verifying extension install..."
devcontainer exec \
  --workspace-folder "${WORKSPACE_FOLDER}" \
  bash -lc 'set -euo pipefail; code --list-extensions | grep -Ei "copilot|oai|compatible"'

echo ""
echo "[codespace-init-test] Running post-start check..."
devcontainer exec \
  --workspace-folder "${WORKSPACE_FOLDER}" \
  bash -lc 'set -euo pipefail; bash .devcontainer/post-start.sh'

if [ "${SKIP_GATEWAY_CHECK}" = "1" ]; then
  echo ""
  echo "[codespace-init-test] Skipping gateway check because SKIP_GATEWAY_CHECK=1"
else
  echo ""
  echo "[codespace-init-test] Verifying gateway secrets and connectivity..."
  devcontainer exec \
    --workspace-folder "${WORKSPACE_FOLDER}" \
    bash -lc '
      set -euo pipefail

      if [ -z "${LITELLM_BASE_URL:-}" ]; then
        echo "[codespace-init-test] ERROR: LITELLM_BASE_URL is not set." >&2
        exit 1
      fi

      if [ -z "${LITELLM_API_KEY:-}" ]; then
        echo "[codespace-init-test] ERROR: LITELLM_API_KEY is not set." >&2
        exit 1
      fi

      if [ -z "${OAI_API_KEY:-}" ]; then
        echo "[codespace-init-test] ERROR: OAI_API_KEY is not set." >&2
        exit 1
      fi

      if [ "${OAI_API_KEY}" != "${LITELLM_API_KEY}" ]; then
        echo "[codespace-init-test] ERROR: OAI_API_KEY must alias LITELLM_API_KEY." >&2
        exit 1
      fi

      pixi run gateway-check
    '
fi

echo ""
echo "[codespace-init-test] Fresh init test passed."
