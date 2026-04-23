import argparse
import json
import os
import sys
from urllib.parse import urlparse

import requests


class EnvVar(str):
    """Named type for environment variable identifiers."""

    def __new__(cls, name: str):
        return super().__new__(cls, name)

    def __repr__(self) -> str:
        return f"<EnvVar {super().__repr__()}>"


LITELLM_BASE_URL = EnvVar("LITELLM_BASE_URL")
LITELLM_API_KEY = EnvVar("LITELLM_API_KEY")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Validate LLMaven gateway connectivity"
    )
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


def validate_base_url(base_url: str) -> str:
    """
    Perform minimal sanity checks on the base URL before using it.

    This intentionally avoids host allowlists and only enforces structural safety.
    """
    parsed = urlparse(base_url)

    if parsed.scheme.lower() != "https":
        raise ValueError(f"{LITELLM_BASE_URL} must use https")

    if not parsed.netloc:
        raise ValueError(f"{LITELLM_BASE_URL} must include a host")

    if parsed.username or parsed.password:
        raise ValueError(
            f"{LITELLM_BASE_URL} must not contain embedded credentials"
        )

    if parsed.fragment:
        raise ValueError(f"{LITELLM_BASE_URL} must not include a URL fragment")

    return base_url.rstrip("/")


def main() -> None:
    args = parse_args()

    base_url = os.getenv(LITELLM_BASE_URL, "").strip()
    api_key = os.getenv(LITELLM_API_KEY)

    if not base_url:
        print(f"Missing {LITELLM_BASE_URL}")
        sys.exit(1)

    if not api_key:
        print(f"Missing {LITELLM_API_KEY}")
        sys.exit(1)

    try:
        base_url = validate_base_url(base_url)
    except ValueError as err:
        print(f"Invalid {LITELLM_BASE_URL}: {err}")
        sys.exit(1)

    url = f"{base_url}/v1/models"

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
