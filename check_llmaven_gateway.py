import argparse
import json
import os
import sys
from urllib.parse import urlparse

import requests

# Only allow connections to the approved LLMaven gateway host
APPROVED_GATEWAY_HOST = "ssec-uw-llmaven.hf.space"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Validate LLMaven gateway connectivity")
    parser.add_argument(
        "--debug",
        action="store_true",
        help="Print safe structured diagnostics for troubleshooting",
    )
    parser.add_argument(
        "--unsafe-debug-body",
        action="store_true",
        help="Print raw response body preview (may expose sensitive details)",
    )
    return parser.parse_args()


def validate_gateway_url(gateway: str) -> str:
    parsed = urlparse(gateway)

    if parsed.scheme.lower() != "https":
        raise ValueError("LITELLM_GATEWAY_URL must use https")
    if not parsed.netloc:
        raise ValueError("LITELLM_GATEWAY_URL must include a host")
    if parsed.netloc != APPROVED_GATEWAY_HOST:
        raise ValueError(
            f"LITELLM_GATEWAY_URL host must be {APPROVED_GATEWAY_HOST}, got {parsed.netloc}"
        )
    if parsed.username or parsed.password:
        raise ValueError("LITELLM_GATEWAY_URL must not contain embedded credentials")
    if parsed.fragment:
        raise ValueError("LITELLM_GATEWAY_URL must not include a URL fragment")

    return gateway.rstrip("/")


def main() -> None:
    args = parse_args()
    gateway = os.getenv("LITELLM_GATEWAY_URL", "").strip()
    api_key = os.getenv("LITELLM_API_KEY")

    if not gateway:
        print("Missing LITELLM_GATEWAY_URL")
        sys.exit(1)

    if not api_key:
        print("Missing LITELLM_API_KEY")
        sys.exit(1)

    try:
        gateway = validate_gateway_url(gateway)
    except ValueError as err:
        print(f"Invalid LITELLM_GATEWAY_URL: {err}")
        sys.exit(1)

    url = gateway + "/v1/models"

    resp = requests.get(
        url,
        headers={"Authorization": f"Bearer {api_key}"},
        timeout=20,
    )

    print(f"GET {url} -> {resp.status_code}")

    payload = None
    try:
        payload = resp.json()
    except ValueError:
        payload = None

    if args.debug:
        print(f"content-type: {resp.headers.get('content-type', '<missing>')}")
        print(f"response-bytes: {len(resp.content)}")
        
        if isinstance(payload, dict):
            print(f"json-keys: {json.dumps(sorted(payload.keys()))}")
            if isinstance(payload.get("data"), list):
                print(f"model-count: {len(payload['data'])}")
        elif isinstance(payload, list):
            print("json-root-type: list")
            print(f"json-list-length: {len(payload)}")
        else:
            print("response-json: unavailable")

    if args.unsafe_debug_body:
        print("--- raw-body-preview-start ---")
        print(resp.text[:1000])
        print("--- raw-body-preview-end ---")

    resp.raise_for_status()

    if isinstance(payload, dict) and isinstance(payload.get("data"), list):
        print(f"Models returned: {len(payload['data'])}")


if __name__ == "__main__":
    main()
