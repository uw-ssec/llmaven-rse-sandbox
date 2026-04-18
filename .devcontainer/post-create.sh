#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=/dev/null
source "${SCRIPT_DIR}/oai-compatible-copilot-vsix.env"

VSIX_URL="https://github.com/uw-ssec/oai-compatible-copilot/releases/download/${VSIX_RELEASE_TAG}/${VSIX_FILENAME}"

VSIX_DIR="${HOME}/.cache/oai-compatible-copilot"
VSIX_PATH="${VSIX_DIR}/${VSIX_FILENAME}"

log() {
  echo "[post-create] $*"
}

error() {
  echo "[post-create] ERROR: $*" >&2
}

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    error "required command not found: $1"
    return 1
  fi
}

verify_required_vars() {
  if [ -z "${VSIX_RELEASE_TAG:-}" ]; then
    error "VSIX_RELEASE_TAG is not set"
    return 1
  fi

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

main_download() {
  log "Preparing prebuilt OAI-compatible Copilot VSIX..."

  verify_required_vars || return 1

  require_cmd curl || return 1
  require_cmd grep || return 1
  require_cmd sha256sum || return 1
  require_cmd awk || return 1

  mkdir -p "${VSIX_DIR}"

  log "Release tag: ${VSIX_RELEASE_TAG}"
  if [ -n "${VSIX_SOURCE_COMMIT:-}" ]; then
    log "Source commit metadata: ${VSIX_SOURCE_COMMIT}"
  fi

  log "Downloading ${VSIX_URL}"
  curl -fsSL \
    --retry 3 \
    --retry-delay 2 \
    --proto '=https' \
    --tlsv1.2 \
    -o "${VSIX_PATH}" \
    "${VSIX_URL}"

  log "Verifying VSIX SHA256 against pinned in-repo value..."
  verify_sha256 || return 1

  chmod 0644 "${VSIX_PATH}"

  log "VSIX ready: ${VSIX_PATH}"
}

if ! main_download; then
  echo "" >&2
  echo "FATAL: Failed to prepare required OAI-compatible Copilot extension VSIX." >&2
  echo "This sandbox is designed to demonstrate that extension." >&2
  echo "Please check logs above." >&2
  exit 1
fi
