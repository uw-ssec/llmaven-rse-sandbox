# llmaven-rse-sandbox

This repository contains the sandbox environment for the NAIRR RSE Plugins Demo.

It is a preconfigured GitHub Codespaces workspace where authorized users can explore and evaluate Research Software Engineering (RSE) AI plugins using GitHub Copilot, with model requests routed through the LLMaven AI gateway.

## What this repo is

- A user-facing evaluation environment
- A prebuilt Codespace with Copilot-compatible AI tooling, sample scientific code, and guided docs
- A read-only source repository for demo users

## How it fits into the system

1. Users authenticate and register through the onboarding app
2. They are granted read-only access to this repository
3. They open a Codespace from this repo
4. They use the sandbox to try plugin-assisted workflows

## Start here

Open this repo in GitHub Codespaces, then open `docs/getting-started.md`.

## Saving your work

Demo users should fork this repository to save work. See `docs/save-your-work.md`.

## Notes

AI interactions in this environment may be routed through the LLMaven gateway for research and evaluation purposes. See `docs/data-collection.md`.

This sandbox auto-installs a minimal extension set. One third-party extension is currently required for OpenAI-compatible routing and should be treated as a deliberate trust assumption for the demo.
