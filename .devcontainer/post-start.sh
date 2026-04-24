#!/usr/bin/env bash
set -euo pipefail

SESSION_DIR="${XDG_RUNTIME_DIR:-$HOME/.cache/llmaven}"
SESSION_FILE="${SESSION_DIR}/session_id"

mkdir -p "$SESSION_DIR"
chmod 700 "$SESSION_DIR"

if [ ! -f "$SESSION_FILE" ]; then
  TMP_SESSION_FILE="$(mktemp "${SESSION_DIR}/session_id.XXXXXX")"
  trap 'rm -f "$TMP_SESSION_FILE"' EXIT

  cat /proc/sys/kernel/random/uuid > "$TMP_SESSION_FILE"

  chmod 600 "$TMP_SESSION_FILE"
  mv "$TMP_SESSION_FILE" "$SESSION_FILE"
  trap - EXIT
fi

chmod 600 "$SESSION_FILE" || true
SESSION_ID="$(cat "$SESSION_FILE")"
SHORT_SESSION_ID="${SESSION_ID%%-*}"

echo ""
echo "LLMaven session initialized: ${SHORT_SESSION_ID}..."

LLMAVEN_BASE_URL_ENV_NAME="LITELLM_BASE_URL"
if [ -z "${!LLMAVEN_BASE_URL_ENV_NAME:-}" ]; then
  echo "Warning: $LLMAVEN_BASE_URL_ENV_NAME is not set."
fi

LLMAVEN_API_KEY_ENV_NAME="LITELLM_API_KEY"
if [ -z "${!LLMAVEN_API_KEY_ENV_NAME:-}" ]; then
  echo "Warning: $LLMAVEN_API_KEY_ENV_NAME is not set."
fi

OAI_API_KEY_ENV_NAME="OAI_API_KEY"
if [ -z "${!OAI_API_KEY_ENV_NAME:-}" ]; then
  echo "Warning: $OAI_API_KEY_ENV_NAME is not set."
fi

VSIX_PATH="${HOME}/.cache/oai-compatible-copilot/oai-compatible-copilot-sandbox.vsix"

echo ""
echo "[post-start] Extension inventory (copilot/oai/compatible):"
if command -v code >/dev/null 2>&1; then
  code --list-extensions | grep -Ei "copilot|oai|compatible" || true
else
  echo "[post-start] 'code' CLI not found; skipping extension listing."
fi

if [ -f "${VSIX_PATH}" ]; then
  echo "[post-start] VSIX present: ${VSIX_PATH}"
else
  echo "[post-start] Warning: VSIX not found at ${VSIX_PATH}"
fi

if [ -n "${LITELLM_BASE_URL:-}" ]; then
  echo "[post-start] Base URL: ${LITELLM_BASE_URL}"
fi

if [ -n "${LITELLM_API_KEY:-}" ]; then
  echo "[post-start] LiteLLM API key: detected"
fi

if [ -n "${OAI_API_KEY:-}" ]; then
  echo "[post-start] OAI API key alias: detected"
fi

if [ -n "${LITELLM_BASE_URL:-}" ] && [ -n "${LITELLM_API_KEY:-}" ]; then
  echo "[post-start] Running gateway smoke test via pixi run gateway-check"
  if command -v pixi >/dev/null 2>&1; then
    if ! pixi run gateway-check; then
      echo "[post-start] Warning: gateway-check failed"
    fi
  else
    echo "[post-start] Warning: pixi not found; skipping gateway-check"
  fi
fi
