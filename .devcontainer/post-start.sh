#!/usr/bin/env bash
set -euo pipefail

SESSION_FILE="/tmp/llmaven_session_id"

if [ ! -f "$SESSION_FILE" ]; then
  python - <<'PY' > "$SESSION_FILE"
import uuid
print(uuid.uuid4())
PY
fi

SESSION_ID="$(cat "$SESSION_FILE")"

echo ""
echo "LLMaven session UUID: $SESSION_ID"

if [ -z "${LITELLM_GATEWAY_URL:-}" ]; then
  echo "Warning: LITELLM_GATEWAY_URL is not set."
fi

if [ -z "${LITELLM_API_KEY:-}" ]; then
  echo "Warning: LITELLM_API_KEY is not set."
fi
