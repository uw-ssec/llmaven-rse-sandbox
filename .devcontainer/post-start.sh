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

if [ -z "${LITELLM_GATEWAY_URL:-}" ]; then
  echo "Warning: LITELLM_GATEWAY_URL is not set."
fi

if [ -z "${LITELLM_API_KEY:-}" ]; then
  echo "Warning: LITELLM_API_KEY is not set."
fi
