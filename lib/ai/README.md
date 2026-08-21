# lib/ai

LLM agent primitives — a vendored copy of the `ai_nu` repo. **Not a git
submodule**: edit these files directly.

```nu
use lib/ai *
```

This is the only category with subdirectories, and the only one whose `mod.nu`
is mostly an `export-env` block rather than a list of re-exports. Loading it
initializes `$env.AI_CONFIG`, `$env.AI_PROMPTS`, and `$env.AI_TOOLS`, and
registers the default tool schemas.

## Layers

```
mod.nu ──► export-env: seeds $env.AI_CONFIG / AI_PROMPTS / AI_TOOLS
   │
call.nu ──────► ai-new-session, ai-chat, ai-do, ai-assistant, ai-embed
   │
base.nu ──────► ai-req (build) → ai-call (execute + record) → ai-send (multi-turn + tools)
   │
clients/ ─────► openai.nu (SSE streaming, tool-call merging), gemini.nu, baml.nu
   │
data.nu ──────► session/message persistence
sqlite.nu ────► the SQLite behind it
```

All dispatch funnels through `ai-req` / `ai-call`. If you're adding a provider,
that's the seam.

## Commands by file

| File            | Exports                                                                 |
| --------------- | ----------------------------------------------------------------------- |
| `base.nu`       | `ai-req`, `ai-call`, `ai-send`, `ai-models`, `req-restore`              |
| `call.nu`       | `ai-new-session`, `ai-chat`, `ai-do`, `ai-assistant`, `ai-editor-run`, `ai-embed`, `similarity cosine` |
| `config.nu`     | `ai-session`, `ai-switch-provider\|model\|temperature`, `ai-config-upsert-provider\|prompt\|model`, `ai-config-alloc-tools`, `ai-config-env-prompts\|tools`, `ai-history-assistant\|do\|scratch` |
| `data.nu`       | `init`, `make-session`, `session`, `record`, `messages`, `tools`, `role`, `seed`, `upsert-*` |
| `sqlite.nu`     | `sqlx`, `init-db`, `db-upsert`, `table-merge`, `table-upsert`, `insert-prompt-tools` |
| `function.nu`   | `closure-list`, `closure-run`, `extract`, `prompts-call`                |
| `mcp.nu`        | `mcp-start`, `mcp-stop`, `mcp-addr`, `mcp-status`                       |
| `common.nu`     | `render`, `block-edit`, `try_json`, `json-to-string`                    |
| `completion.nu` | `cmpl-*` completion callbacks for the commands above                    |
| `shortcut.nu`   | `aa`                                                                    |
| `list-hooks.nu` | `main`                                                                  |

`function.nu` is the tool-dispatch bridge: `closure-list` turns Nu closures
into tool schemas, `closure-run` executes what the model calls back.

## Subdirectories

- **`clients/`** — `openai.nu` (`req`, `call`, `raw-call`, `merge-tools`,
  `models`, `req-restore`), `gemini.nu`, and `baml.nu` (`baml-agent-run`,
  `baml-local-chat`, `baml-quick-summarize`, `baml-extract-decisions`,
  `baml-summarize-conversation`, `baml-local-agent-summary`, `baml-warm`,
  `baml-health`, `baml-use-daemon`).
- **`integration/`** — `ollama.nu` (`ollama-gen`, `ollama-embed`,
  `ollama-info`, `ollama-delete`, `ollama-export`, `ollama-import`,
  `gguf-to-ollama`), plus `local.nu`, `audio.nu`, `web.nu`.
- **`agents/`** — `research.nu`, `ragit.nu`, `kubernetes.nu`, `shop.nu`,
  `project-manager.nu`. These **export no commands**. Each is a script that
  registers a prompt and allocates tools at load time via
  `ai-config-upsert-prompt` / `ai-config-alloc-tools`. Loading one adds a named
  prompt to `$env.AI_PROMPTS`; it does not give you a command to call.
- **`data/tools/`** — `os.nu`, `git.nu`, `web.nu`, `programming.nu`,
  `clipboard.nu`. Same pattern: `export-env` blocks calling `ai-config-env-tools`
  to register JSON tool schemas into `$env.AI_TOOLS`. No commands either.
- **`data/assistant/supervisor/`** — supervisor prompt module, loaded by `mod.nu`.

## Not loaded by `mod.nu`

`data/tools/web.nu` is deliberately commented out — it uses
`query web 'selector'`, whose API changed across Nushell versions. Load it
directly if you need it and your version agrees.

`clients/gemini.nu` defines no `export def`; `mod.nu` does not glob it.

## Requires

Provider credentials in `$env.AI_CONFIG`, `sqlite` for persistence, and
`ollama` for the integration commands. `mcp.nu` holds client stubs for a future
daemon; `clients/baml.nu` targets the planned `nu-ai-daemon` described in
`docs/plans/2026-06-09-baml-agent-daemon.md`.
