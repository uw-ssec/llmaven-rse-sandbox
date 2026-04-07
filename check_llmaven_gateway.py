import os
import sys
import requests

gateway = os.getenv("LITELLM_GATEWAY_URL")
api_key = os.getenv("LITELLM_API_KEY")

if not gateway:
    print("Missing LITELLM_GATEWAY_URL")
    sys.exit(1)

if not api_key:
    print("Missing LITELLM_API_KEY")
    sys.exit(1)

url = gateway.rstrip("/") + "/v1/models"

resp = requests.get(
    url,
    headers={"Authorization": f"Bearer {api_key}"},
    timeout=20,
)

print(f"GET {url} -> {resp.status_code}")
print(resp.text[:1000])

resp.raise_for_status()