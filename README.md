# llmaven-rse-sandbox

This repository contains the sandbox environment for the NAIRR RSE Plugins Demo.

It provides a preconfigured GitHub Codespaces workspace where authorized users can evaluate Research Software Engineering (RSE) AI workflows using GitHub Copilot Chat, the LLMaven Copilot Provider extension, and the UW SSEC RSE Agent Plugins.

## What this repo provides

- A user-facing evaluation environment for RSE AI workflows
- A GitHub Codespaces sandbox with scientific Python tooling managed by Pixi
- A pinned LLMaven Copilot Provider extension for routing Copilot-compatible requests through the LLMaven / LiteLLM gateway
- Workspace recommendations for UW SSEC RSE Agent Plugins
- Guided documentation for first-time demo users

## How the pieces fit together

The sandbox uses three layers:

```text
GitHub Codespaces
  → provides the reproducible development environment

LLMaven Copilot Provider
  → routes Copilot Chat model requests through the LLMaven / LiteLLM gateway

RSE Agent Plugins
  → provide RSE-specific skills, agents, and workflows inside Copilot Chat
```

See the [three-layer sandbox view](docs/assets/sandbox-three-layer-view.png), which shows the RSE Agent Plugins list, the LLMaven Copilot Provider extension, and the Copilot Chat model picker in one VS Code workspace.

![Three-layer sandbox view showing RSE Agent Plugins, the LLMaven Copilot Provider, and Copilot Chat](docs/assets/sandbox-three-layer-view.png)

The Copilot provider extension and the RSE Agent Plugins are separate. The provider handles model routing. The plugins provide the research software engineering capabilities.

## Sandbox walkthrough

Follow these steps to go from opening the sandbox to your first successful RSE workflow interaction.

### Step 1 — Open the Codespace

Start from the authorized onboarding flow or from the repository page and open a GitHub Codespace for this repository.

During first launch, the devcontainer automatically:

- prepares the Pixi Python environment
- downloads and verifies the pinned LLMaven Copilot Provider VSIX
- installs the provider extension and configures it to route through the LLMaven / LiteLLM gateway
- installs the Copilot CLI with the RSE plugin marketplace registered

You will see setup output in the terminal during first launch. Wait for it to complete before continuing.

### Step 2 — Start with Copilot Chat (chat-first)

**Begin in Copilot Chat, not the CLI.** Chat is the fastest way to verify that the full stack is working end-to-end before switching to command-line workflows.

Open the Copilot Chat panel in VS Code (the speech-bubble icon in the Activity Bar, or `Ctrl+Shift+I`).

Try a simple prompt to confirm the connection is live:

```text
What is this repository for?
```

If Copilot Chat responds with a description of the sandbox, the provider and gateway are working.

### Step 3 — Select a model

Open the model picker inside Copilot Chat (the model name shown near the input box).

OAI-compatible models routed through the LLMaven gateway will appear alongside standard GitHub Copilot models. Select one of the OAI-compatible models to route requests through the LLMaven / LiteLLM gateway.

See the [Copilot model picker screenshot](docs/assets/copilot-model-picker.png).

![Copilot Chat model picker showing OAI-compatible models](docs/assets/copilot-model-picker.png)

**If no OAI-compatible models appear:**

1. Open the Extensions view and search for `LLMaven Copilot Provider`. Confirm it is installed and enabled.
2. Check the VS Code Output panel for any activation errors from the provider extension.
3. If startup logged `Warning: OAI_API_KEY is not set`, the gateway credential is missing — recreate the Codespace from the authorized onboarding flow.
4. If the extension is installed but models still do not appear, try reloading the VS Code window (`Ctrl+Shift+P` → **Developer: Reload Window**) and reopening the model picker.
5. If the issue persists, open a new Codespace from the onboarding flow rather than reconnecting to an existing one.

### Step 4 — Install the recommended RSE Agent Plugins

Open the Extensions view (`Ctrl+Shift+X`) and search:

```text
@agentPlugins @recommended
```

You will see the UW SSEC RSE plugins recommended from the `rse-plugins` marketplace. Install the plugins you want to use.

See the [recommended RSE Agent Plugins screenshot](docs/assets/recommended-rse-agent-plugins.png).

![Recommended RSE Agent Plugins in VS Code](docs/assets/recommended-rse-agent-plugins.png)

Recommended plugins include:

- `scientific-domain-applications`
- `scientific-python-development`
- `holoviz-visualization`
- `ai-research-workflows`
- `project-management`
- `zarr-data-format`
- `research-software-design`

### Step 5 — Try an RSE workflow in Copilot Chat

With the plugins installed and a model selected, try a workflow prompt in Copilot Chat:

```text
Use the scientific-python-development plugin to review this repository for testing, dependency, and API design issues.
```

```text
Use the project-management plugin to assess onboarding and handoff readiness for this repository.
```

```text
Use the research-software-design plugin to identify user, workflow, and design risks in this project.
```

The plugin provides RSE-specific skills, agents, or slash commands that appear inside Copilot Chat.

### Step 6 — Move to the Copilot CLI for scripted workflows

Once the Chat interaction is working, use the Copilot CLI for workflows that benefit from shell integration, file output, or scripted repetition.

**When to stay in Chat:**

- Exploring unfamiliar code or tooling
- Interactive back-and-forth questions
- Plugin discovery and testing new workflows

**When to move to the CLI:**

- Automating a repeated workflow across multiple files or repositories
- Piping Copilot output into other shell tools
- Running plugin-backed tasks non-interactively in a script or CI context

The Copilot CLI is installed in the devcontainer and the RSE plugin marketplace is pre-registered. Run `gh copilot --help` to see available commands and `gh copilot suggest` or `gh copilot explain` for common entry points.

For the full setup details and troubleshooting, see [docs/getting-started.md](docs/getting-started.md).

## Saving your work

This repository is intended as a managed sandbox. Demo users should fork this repository if they want to preserve changes outside the provided environment.

See:

```text
docs/save-your-work.md
```

## Data and evaluation notes

AI interactions in this environment may be routed through the LLMaven / LiteLLM gateway for research and evaluation purposes.

See:

```text
docs/data-collection.md
```

## Trust assumptions

This sandbox installs a pinned LLMaven Copilot Provider VSIX during devcontainer setup. The VSIX is verified against a SHA256 value committed in this repository before installation.

The provider extension uses a gateway credential provisioned through the authorized onboarding flow. Use this sandbox only from trusted Codespace sessions created through that flow.
