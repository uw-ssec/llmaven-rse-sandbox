#!/usr/bin/env bash
set -euo pipefail

echo "[post-create] Bootstrapping custom Copilot-compatible VSIX..."

EXT_REPO_URL="https://github.com/uw-ssec/oai-compatible-copilot.git"
EXT_BRANCH="sandbox"
EXT_REF="${RSE_EXTENSION_REF:-}"

SRC_DIR="/tmp/oai-compatible-copilot"
VSIX_DIR="${HOME}/.cache/oai-compatible-copilot"
VSIX_PATH="${VSIX_DIR}/oai-compatible-copilot-sandbox.vsix"

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "[post-create] ERROR: required command not found: $1" >&2
    exit 1
  fi
}

safe_env() {
  env \
    -u LITELLM_API_KEY \
    -u LITELLM_BASE_URL \
    -u LITELLM_GATEWAY_URL \
    -u OAI_API_KEY \
    "$@"
}

require_cmd git
require_cmd npm
require_cmd code

if [[ ! "${EXT_REF}" =~ ^[0-9a-fA-F]{40}$ ]]; then
  echo "[post-create] ERROR: RSE_EXTENSION_REF must be a full 40-character commit SHA." >&2
  exit 1
fi

mkdir -p "${VSIX_DIR}"
rm -rf "${SRC_DIR}"

echo "[post-create] Cloning ${EXT_REPO_URL} (branch: ${EXT_BRANCH})..."
safe_env git clone --depth 1 --branch "${EXT_BRANCH}" "${EXT_REPO_URL}" "${SRC_DIR}"

cd "${SRC_DIR}"

echo "[post-create] Checking out pinned extension ref: ${EXT_REF}"
safe_env git fetch --depth 1 origin "${EXT_REF}"
safe_env git checkout --detach "${EXT_REF}"

ACTUAL_REF="$(git rev-parse HEAD)"
if [ "${ACTUAL_REF}" != "${EXT_REF}" ]; then
  echo "[post-create] ERROR: checked-out ref mismatch. Expected ${EXT_REF}, got ${ACTUAL_REF}" >&2
  exit 1
fi

if ! git branch -r --contains "${EXT_REF}" | grep -q "origin/${EXT_BRANCH}"; then
  echo "[post-create] ERROR: pinned ref ${EXT_REF} is not contained in origin/${EXT_BRANCH}." >&2
  exit 1
fi

if [ ! -f package-lock.json ]; then
  echo "[post-create] ERROR: package-lock.json is required for reproducible extension install." >&2
  exit 1
fi

echo "[post-create] Installing extension dependencies from package-lock.json..."
safe_env npm ci --ignore-scripts

if [ ! -x ./node_modules/.bin/vsce ]; then
  echo "[post-create] ERROR: local vsce binary not found. Ensure @vscode/vsce is declared in package-lock.json." >&2
  exit 1
fi

echo "[post-create] Packaging VSIX -> ${VSIX_PATH}"
safe_env ./node_modules/.bin/vsce package -o "${VSIX_PATH}"

echo "[post-create] Installing VSIX..."
safe_env code --install-extension "${VSIX_PATH}" --force

echo "[post-create] Installed extensions (filtered):"
code --list-extensions | grep -Ei "copilot|oai|compatible" || true

echo "[post-create] Custom extension install complete."
