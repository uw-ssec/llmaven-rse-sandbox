#!/usr/bin/env bash
set -euo pipefail

echo "[post-create] Bootstrapping custom Copilot-compatible VSIX..."

EXT_REPO_URL="${RSE_EXTENSION_REPO:-https://github.com/uw-ssec/oai-compatible-copilot.git}"
EXT_BRANCH="${RSE_EXTENSION_BRANCH:-sandbox}"
# Optional pin (commit SHA/tag/ref). Empty means branch HEAD.
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

require_cmd git
require_cmd npm
require_cmd code

mkdir -p "${VSIX_DIR}"
rm -rf "${SRC_DIR}"

echo "[post-create] Cloning ${EXT_REPO_URL} (branch: ${EXT_BRANCH})..."
git clone --depth 1 --branch "${EXT_BRANCH}" "${EXT_REPO_URL}" "${SRC_DIR}"

cd "${SRC_DIR}"

if [ -n "${EXT_REF}" ]; then
  echo "[post-create] Pinning extension ref: ${EXT_REF}"
  git fetch --depth 1 origin "${EXT_REF}"
  git checkout "${EXT_REF}"
else
  echo "[post-create] No pinned extension ref set; using branch HEAD: ${EXT_BRANCH}"
fi

echo "[post-create] Installing extension dependencies..."
if [ -f package-lock.json ]; then
  npm ci
elif [ -f pnpm-lock.yaml ]; then
  if ! command -v pnpm >/dev/null 2>&1; then
    echo "[post-create] Installing pnpm..."
    npm install -g pnpm
  fi
  pnpm install --frozen-lockfile
elif [ -f yarn.lock ]; then
  if ! command -v yarn >/dev/null 2>&1; then
    echo "[post-create] Installing yarn..."
    npm install -g yarn
  fi
  yarn install --frozen-lockfile
else
  npm install
fi

echo "[post-create] Packaging VSIX -> ${VSIX_PATH}"
npx @vscode/vsce package -o "${VSIX_PATH}"

echo "[post-create] Installing VSIX..."
code --install-extension "${VSIX_PATH}" --force

echo "[post-create] Installed extensions (filtered):"
code --list-extensions | grep -Ei "copilot|oai|compatible" || true

echo "[post-create] Custom extension install complete."
