# Getting Started

Welcome to the LLMaven RSE Sandbox.

## Goal

This sandbox is a preconfigured Codespaces environment for trying GitHub Copilot and RSE-oriented plugin-assisted workflows on simple scientific code.

## First steps

1. Open `samples/climate_model.py`
2. Ask Copilot to explain what the script does
3. Ask for a refactor that improves readability
4. Open `samples/climate_data_analysis.py`
5. Ask for a small analysis improvement
6. Open `samples/model_visualization.py`
7. Ask for a plotting enhancement

## What to pay attention to

- Is the environment easy to understand?
- Are the plugin-assisted suggestions useful?
- Does the setup feel ready-to-go?
- Are there any obvious points of confusion?

## Environment management

This Codespaces environment uses pixi for package and environment management.

To verify the gateway connection, run:

```bash
pixi run gateway-check
```

If you need troubleshooting output, run:

```bash
pixi run gateway-check --debug
```

## Running sample scripts

This sandbox uses pixi for environment management. Run sample scripts through pixi:

```bash
pixi run python samples/climate_model.py
pixi run python samples/climate_data_analysis.py
pixi run python samples/model_visualization.py
```

## How credentials are provided

This repository declares the names of the required runtime secrets in devcontainer.json (LITELLM_GATEWAY_URL and LITELLM_API_KEY).

### Current implementation
The actual secret values are not stored in the repository. They are provided through GitHub Codespaces development environment secrets (user-level, repository-level, or organization-level).

When a codespace is created, GitHub can prompt for any recommended secrets that are missing. Once configured, those secrets are injected into the codespace as environment variables and are available to lifecycle scripts, terminals, and compatible extensions.

### How this evolves later

As onboarding/provisioning becomes more complete, the goal is to preserve the same runtime contract (LITELLM_GATEWAY_URL and LITELLM_API_KEY) while reducing manual setup for users. The sandbox should continue reading the same environment variables even if the delivery mechanism becomes more automated later.

### Extension trust model

This sandbox installs a minimal extension set. One third-party extension is currently required for OpenAI-compatible routing and should be treated as a deliberate trust assumption for the demo.

## Notes

If the LiteLLM gateway or related configuration is not available in your environment yet, some AI-assisted functionality may be limited.
