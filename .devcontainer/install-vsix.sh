#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=/dev/null
source "${SCRIPT_DIR}/oai-compatible-copilot-vsix.env"

VSIX_DIR="${HOME}/.cache/oai-compatible-copilot"
VSIX_PATH="${VSIX_DIR}/${VSIX_FILENAME}"
EXTENSION_ID="uw-ssec.oai-compatible-copilot"

log() {
  echo "[post-attach] $*"
}

error() {
  echo "[post-attach] ERROR: $*" >&2
}

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    error "required command not found: $1"
    return 1
  fi
}

verify_required_vars() {
  if [ -z "${VSIX_FILENAME:-}" ]; then
    error "VSIX_FILENAME is not set"
    return 1
  fi

  if [ -z "${EXPECTED_VSIX_SHA256:-}" ]; then
    error "EXPECTED_VSIX_SHA256 is not set"
    return 1
  fi

  if [ "${EXPECTED_VSIX_SHA256}" = "REPLACE_WITH_FULL_64_CHARACTER_SHA256" ]; then
    error "EXPECTED_VSIX_SHA256 still contains placeholder value"
    return 1
  fi

  if ! printf '%s' "${EXPECTED_VSIX_SHA256}" | grep -Eq '^[a-fA-F0-9]{64}$'; then
    error "EXPECTED_VSIX_SHA256 must be a 64-character hex SHA256"
    return 1
  fi
}

verify_sha256() {
  local actual_sha256

  actual_sha256="$(sha256sum "${VSIX_PATH}" | awk '{print $1}')"

  if [ "${actual_sha256}" != "${EXPECTED_VSIX_SHA256}" ]; then
    error "VSIX SHA256 mismatch."
    error "Expected: ${EXPECTED_VSIX_SHA256}"
    error "Actual:   ${actual_sha256}"
    return 1
  fi
}

main_install() {
  log "Checking OAI-compatible Copilot extension..."

  verify_required_vars || return 1

  require_cmd code || return 1
  require_cmd grep || return 1
  require_cmd sha256sum || return 1
  require_cmd awk || return 1

  if [ ! -f "${VSIX_PATH}" ]; then
    error "VSIX not found at ${VSIX_PATH}"
    error "Expected post-create.sh to download and verify the pinned VSIX first."
    return 1
  fi

  log "Verifying VSIX SHA256 before install..."
  verify_sha256 || return 1

  if code --list-extensions | grep -qx "${EXTENSION_ID}"; then
    log "Extension already installed: ${EXTENSION_ID}"
    return 0
  fi

  log "Installing extension from verified VSIX: ${VSIX_PATH}"
  code --install-extension "${VSIX_PATH}"

  if ! code --list-extensions | grep -qx "${EXTENSION_ID}"; then
    error "extension was not installed: ${EXTENSION_ID}"
    return 1
  fi

  log "OAI-compatible Copilot extension installed: ${EXTENSION_ID}"
}

if ! main_install; then
  echo "" >&2
  echo "FATAL: Failed to install required OAI-compatible Copilot extension." >&2
  echo "The VSIX must match the pinned SHA256 before installation." >&2
  echo "Please check logs above." >&2
  exit 1
fi
