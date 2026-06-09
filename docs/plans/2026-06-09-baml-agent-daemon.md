# BAML Agent Daemon

**Date**: 2026-06-09
**Status**: design

## Goal

Replace the hand-rolled LLM call stack in `lib/ai/clients/` with a persistent Rust daemon
that owns the multi-turn agent loop. BAML defines typed prompts and structured outputs per
agent. Tools are exposed via MCP and executed locally in Nushell. The daemon is the MCP
client; Nu (or a dedicated MCP server project) is the MCP server.

## Motivation

The existing `clients/openai.nu` manually constructs HTTP requests, parses SSE streams, and
manages tool-call merging in Nushell. The `ai-send` loop in `base.nu` drives multi-turn
tool use from Nu. This works but has two problems at scale:

1. Every LLM call is a new HTTP connection from Nu — no connection pooling.
2. The tool-use loop runs in Nu, which is not suited for high-throughput agentic workloads.

The daemon moves both concerns to Rust: persistent HTTP client, connection pool, and a
tight BAML-driven tool loop. Nu retains ownership of tool execution (kubectl, ragit, shop,
etc.) via the MCP protocol.

## Architecture

```
Nu (caller)                 nu-ai-daemon (Rust)          LLM API
───────────                 ──────────────────────       ────────
baml-agent-run "research"
  POST /agent/deep_research
                            BAML: render prompt
                            POST /chat/completions ─────→
                                                   ←───── tool_calls
                            MCP client: tools/call
  ←── MCP request ─────────
  execute tool closure
  MCP result ─────────────→
                            continue loop
                            POST /chat/completions ─────→
                                                   ←───── content
  ←── {content, output} ───
```

## Components

### 1. `nu-ai-daemon` (new Rust crate, `crates/nu-ai-daemon/`)

A long-running binary. Responsibilities:

- Axum HTTP server: `POST /agent/{name}` → runs a full agent session
- BAML client: one `baml::function` per agent, defining system prompt + output schema
- MCP client: connects to the registered MCP server for tool execution
- Persistent `reqwest` client with connection pool for LLM API calls
- Session state: tracks message history within a single `/agent` call

**Request shape:**

```json
{
  "message": "research quantum computing trends",
  "mcp_command": "/usr/local/bin/numcp",
  "mcp_args": ["serve", "--config", "numcp.toml"],
  "provider": "openai",
  "model": "gpt-4o"
}
```

**Response shape:**

```json
{
  "content": "...",
  "output": { ... },
  "turns": 4,
  "tokens": 1823
}
```

**BAML functions** (one per agent, in `baml_src/`):

- `DeepResearch(topic: string) -> ResearchReport`
- `KubernetesExpert(query: string) -> TroubleshootingPlan`
- `ShopAssistant(query: string) -> ShopResponse`
- `ProjectManager(request: string) -> ProjectPlan`

Each function declares the tools it may call. BAML handles prompt rendering and output
parsing. The daemon's tool-use loop calls tools via MCP until the LLM stops requesting them.

**Dependencies:** `axum`, `tokio`, `baml`, `baml_client` (generated), `rmcp`, `reqwest`,
`serde_json`

---

### 2. MCP server (separate project: `numcp`, repo `~/dev/numcp`)

A standalone Rust binary that wraps Nu tool closures as MCP-compatible tool handlers.
Separate repo because it is independently useful beyond `nu_libs` and `nu-ai-daemon`.

**Built on `nu-mcp`** — the official Nushell project already ships `nu-mcp` (crates.io,
v0.113.1, `nushell/nushell/crates/nu-mcp`): "Modules to run a model context protocol
(MCP) server that provides Nushell as a tool." `numcp` depends on `nu-mcp` rather than
re-implementing Nu engine embedding. This also means `nu-mcp-engine` embedding is handled
by the upstream crate.

`numcp` adds:

- A config-file-driven tool registration layer (maps Nu commands → MCP tool schemas)
- A CLI entry point (`numcp serve --config numcp.toml`)
- Optional TCP transport alongside the default stdio transport
- Tool definitions sourced from `$env.AI_TOOLS`-compatible TOML/YAML config

---

### 3. `lib/ai/clients/baml.nu` (new file in this repo)

Thin Nu wrapper over the daemon HTTP API.

```nushell
# Start the MCP tool server (background) and run an agent session.
export def baml-agent-run [
    agent: string        # agent name: deep_research, kubernetes_expert, shop, ...
    message: string
    --provider: string
    --model: string
    --mcp: string        # MCP server address, defaults to $env.NU_MCP_SERVER
] {
    let addr = $mcp | default $env.NU_MCP_SERVER
    http post $"($env.NU_AI_DAEMON)/agent/($agent)" {
        message: $message
        mcp_server: $addr
        provider: $provider
        model: $model
    }
}
```

Nu is responsible for starting the MCP server process before calling `baml-agent-run`. The
daemon address and MCP server address are configured via env vars or `$env.AI_CONFIG`.

---

### 4. `lib/ai/mcp.nu` (updated)

Helpers for starting/stopping the MCP server process and registering it with the daemon.

```nushell
export def mcp-start [] { ... }   # spawn MCP server, store PID in $env.NU_MCP_PID
export def mcp-stop []  { ... }   # kill by PID
export def mcp-addr []  { ... }   # return current server address
```

## Data Flow (single agent call)

1. Nu calls `mcp-start` — MCP server process starts, listens on stdio or TCP port
2. Nu calls `baml-agent-run "deep_research" "quantum computing"`
3. Daemon receives request, reads MCP server address from payload
4. Daemon connects to MCP server, fetches tool list
5. Daemon calls BAML `DeepResearch("quantum computing")` → renders prompt
6. Daemon POSTs to LLM API (persistent connection)
7. LLM returns tool calls (e.g. `web_search`)
8. Daemon calls MCP `tools/call {name: "web_search", arguments: {...}}`
9. MCP server executes the Nu tool handler, returns result
10. Daemon appends tool result to message history, continues loop
11. When LLM returns final content, BAML parses into `ResearchReport`
12. Daemon returns `{content, output, turns, tokens}` to Nu

## Skill and Agent Discovery

The daemon and `numcp` support loading agents and tools from well-known skill/agent
directories on disk. This allows reuse of existing Claude Code skill definitions without
duplicating prompts or tool schemas in BAML or config.

### Discovery Paths (searched in order, merged)

```
.claude/agents/          # repo-local agent definitions
.claude/skills/          # repo-local skill/tool definitions
~/.claude/agents/        # user-global agents
~/.claude/skills/        # user-global skills
.agents/skills/          # alternate convention
```

Paths are resolved relative to the config file's directory for repo-local entries, and
`$HOME` for global entries. All paths are merged; later entries override earlier ones on
name collision.

### Agent Definition Format

An agent directory entry is a folder with a `agent.toml` (or `SKILL.md` with YAML
frontmatter) containing at minimum:

```toml
name        = "deep_research"
description = "Multi-step web research with source validation"
system      = "path/to/system-prompt.md"   # or inline [system] block
tools       = ["web_search", "web_fetch"]   # MCP tool names to expose
output_type = "ResearchReport"              # BAML output type name
```

The daemon reads these at startup and registers a BAML function per agent. If a BAML
function with the same name already exists in `baml_src/`, the on-disk definition takes
precedence (allows overriding built-ins without recompiling).

### Tool Definition Format

A skill/tool entry exposed via `numcp` is a folder with a `tool.toml` plus a `.nu` handler:

```toml
name        = "web_search"
description = "Search the web for a query"

[parameters.query]
type        = "string"
description = "Search terms"
required    = true
```

```nushell
# handler.nu — receives args as $in record, returns string
let q = $in.query
http get $"https://search.example.com?q=($q | url encode)"
| get results | to yaml
```

`numcp` discovers these and registers them as MCP tools. This is the bridge between
`.claude/skills/` Nu handlers and the MCP tool protocol.

### Reload Behaviour

- Daemon performs discovery at startup only (no hot-reload in v1).
- `numcp` also discovers at startup; restart required to pick up new tools.
- A `--watch` flag is in scope for v2.

### Cache Warm-Up

The daemon exposes a `POST /warm` endpoint (and `nu-ai-daemon warm` CLI subcommand) that
pre-loads all expensive resources so the first agent call is not cold:

1. **Skill/agent discovery** — scan all discovery paths, parse all `agent.toml` and
   `tool.toml` files, compile system prompts into memory
2. **BAML function registration** — register all discovered agents as BAML functions,
   merging with compiled-in definitions
3. **Connection pool priming** — issue a lightweight probe request to each configured
   provider (e.g. `GET /models`) to establish the TCP connection and TLS session
4. **`numcp` spawn** — start the MCP server subprocess if `mcp_command` is configured,
   verify it responds to `initialize`

`POST /warm` returns a JSON status report:

```json
{
  "agents": ["deep_research", "kubernetes_expert", "shop"],
  "tools": ["web_search", "web_fetch", "kubectl"],
  "providers": { "openai": "ok", "gemini": "ok" },
  "mcp": "ready",
  "duration_ms": 312
}
```

Nu wrapper:

```nushell
export def baml-warm [] {
    http post $"($env.NU_AI_DAEMON)/warm" {}
}
```

Warm-up runs automatically at daemon startup (non-blocking, logged). It can also be
triggered manually via `baml-warm` after adding new skills to a discovery path.

## Testing Strategy

Each component maps to the applicable dimensions from the seven-dimension model. Dimensions
are listed in lifecycle order: unit first, integration last.

### `nu-ai-daemon`

| Dimension   | What                                                                                                                                                                                   |
| ----------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Unit        | Config parsing, skill discovery path merging, agent registration, warm-up logic                                                                                                        |
| Property    | Discovery path merge is idempotent; later paths always override earlier on collision; warm-up status report counts match loaded counts                                                 |
| Fuzz        | `agent.toml` parser, `tool.toml` parser, `SKILL.md` YAML frontmatter parser — all accept external bytes                                                                                |
| Conformance | `McpClient` trait: every impl satisfies `initialize → tools/list → tools/call` contract; `Provider` trait: every impl returns a non-empty model list and handles auth errors uniformly |
| Integration | Daemon ↔ `numcp` over stdio MCP (real subprocess); daemon ↔ mock LLM HTTP server (wiremock or axum test server)                                                                        |
| Regression  | Every agent loop bug gets a minimal failing test before the fix is applied                                                                                                             |

No model check required: no arithmetic on external inputs, no `unsafe`.

Fuzz targets live in `fuzz/fuzz_targets/` (excluded from workspace). Required targets:

```
fuzz_agent_toml      — arbitrary bytes into agent.toml parser
fuzz_tool_toml       — arbitrary bytes into tool.toml parser
fuzz_skill_frontmatter — arbitrary bytes into SKILL.md YAML header parser
```

Each target must assert lightweight invariants (not just crash-freedom):

- Parsed agent has a non-empty `name`
- Parsed tool `parameters` map has no duplicate keys

### `numcp`

| Dimension   | What                                                                                       |
| ----------- | ------------------------------------------------------------------------------------------ |
| Unit        | Tool schema construction from `tool.toml`, handler dispatch table, argument validation     |
| Property    | Tool argument coercion is lossless for valid inputs; unknown keys are dropped not panicked |
| Fuzz        | MCP `tools/call` message parser — receives arbitrary JSON from the daemon                  |
| Conformance | MCP server protocol: `initialize`, `tools/list`, `tools/call` responses match spec shape   |
| Integration | Full round-trip: daemon sends `tools/call`, `numcp` executes Nu handler, result returned   |
| Regression  | Every misparse of a Nu handler result gets a regression test                               |

Conformance test suite lives in `tests/conformance_mcp_server.rs`, reusable across any
future MCP server impl:

```rust
fn assert_mcp_server_contract<T: McpServer>(server: T) {
    // initialize handshake succeeds
    // tools/list returns non-empty list after warm-up
    // tools/call with unknown tool returns JSON-RPC error -32601
    // tools/call with valid tool returns non-null result
}
```

### `lib/ai/clients/baml.nu`

Nushell has no test framework comparable to Rust's, so tests are structured as executable
Nu scripts under `tests/`:

| Dimension   | What                                                                                           |
| ----------- | ---------------------------------------------------------------------------------------------- |
| Unit        | `baml-agent-run` constructs the correct HTTP payload; `baml-warm` parses the status response   |
| Integration | `baml-agent-run` against a local running daemon instance (test requires daemon binary on PATH) |
| Regression  | Script-level regression for any Nu-side serialisation bug                                      |

Integration tests are gated: `nu tests/integration/baml.nu` only runs when
`$env.NU_AI_DAEMON` is set and reachable.

## Tech Decisions

| Decision            | Choice                  | Reason                                                          |
| ------------------- | ----------------------- | --------------------------------------------------------------- |
| HTTP framework      | Axum                    | Async, ergonomic, standard in this ecosystem                    |
| LLM prompts         | BAML                    | Typed outputs, prompt versioning, test tooling                  |
| Tool protocol       | MCP                     | Standard, composable, solves the Nu callback problem cleanly    |
| MCP transport       | stdio (initial)         | Simplest; upgrade to TCP/SSE for multi-client later             |
| Nu tool server      | `numcp` (separate repo) | Reusable independently; `nu-mcp` crate handles engine embedding |
| Nu engine embedding | via `nu-mcp` upstream   | Official Nushell crate, already solves this problem             |
| Connection pool     | reqwest default         | Persistent client covers the throughput requirement             |
| Daemon port         | config file             | Port, bind address, MCP server path all in `nu-ai-daemon.toml`  |

## Out of Scope

- Replacing `lib/ai/clients/openai.nu` for non-agent use cases (chat, embeddings remain as-is)
- Streaming responses from the daemon to Nu (return only on completion)
- Authentication on the daemon HTTP port (localhost only, no auth)
- Multi-tenant or multi-user session isolation
- BAML test suite (deferred until agent functions are stable)

## Open Questions

1. **`numcp` TCP transport**: when to add TCP alongside stdio — before or after the daemon
   integration is proven?
2. **Config schema**: what fields does `nu-ai-daemon.toml` need on day one (port, bind addr,
   MCP server path, provider defaults)?

## Next Step

Invoke `godmode:writing-plans` to break this into an implementation plan.
