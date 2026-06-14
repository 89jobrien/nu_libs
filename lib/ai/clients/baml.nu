# Nu wrappers around the `bamlish` CLI binary.
#
# bamlish calls BAML functions: cloud functions use OpenAI/Anthropic,
# local functions use Ollama (magistral:latest at localhost:11434).
#
# Prerequisites:
#   - bamlish binary on PATH  (cargo install --path ~/dev/bamlish)
#   - Cloud functions: OPENAI_API_KEY or ANTHROPIC_API_KEY in env
#   - Local functions: Ollama running (`ollama serve`)
#
# See: ~/dev/bamlish

# ── Helpers ──────────────────────────────────────────────────────────────────

def bamlish-call [subcommand: string, payload: record] {
    # BAML_LOG=info emits structured log lines before the JSON output.
    # Filter to the line that starts with '{' to get just the result.
    $payload | to json | BAML_LOG=error bamlish $subcommand | lines | where {|l| $l | str starts-with "{"} | last | from json
}

# ── Cloud functions ───────────────────────────────────────────────────────────

# Quick-summarize a Claude session from first/last message excerpts.
# Returns: {summary: string}
export def baml-quick-summarize [
    first_messages: string
    last_messages: string
    tool_count: int = 0
] {
    bamlish-call "quick-summarize" {
        first_messages: $first_messages
        last_messages: $last_messages
        tool_count: $tool_count
    }
}

# Extract key decisions from a conversation excerpt.
# Returns: list of decision records
export def baml-extract-decisions [
    conversation_excerpt: string
] {
    bamlish-call "extract-decisions" {conversation_excerpt: $conversation_excerpt}
}

# Summarize a full Claude conversation transcript.
# Returns: ConversationSummary record
export def baml-summarize-conversation [
    transcript_excerpt: string
    session_id: string = ""
    total_messages: int = 0
    total_tool_uses: int = 0
] {
    bamlish-call "summarize-conversation" {
        transcript_excerpt: $transcript_excerpt
        session_id: $session_id
        total_messages: $total_messages
        total_tool_uses: $total_tool_uses
    }
}

# ── Local / Ollama functions ──────────────────────────────────────────────────

# Send a message to the local Ollama model via bamlish.
# Returns: {response: string}
export def baml-local-chat [
    message: string
] {
    bamlish-call "local-chat" {message: $message}
}

# Analyze agent state strings with the local Ollama model.
# Returns: {summary: string}
export def baml-local-agent-summary [
    agents: string
] {
    bamlish-call "local-agent-summary" {agents: $agents}
}

# ── Daemon functions (kept for compatibility) ─────────────────────────────────
# These require the nu-ai-daemon HTTP server (see docs/plans/2026-06-09-baml-agent-daemon.md).

# Run an agent session via the BAML daemon.
export def baml-agent-run [
    agent: string
    message: string
    --provider: string
    --model: string
    --mcp-command: string  # numcp binary path; falls back to $env.NU_MCP_COMMAND, then "numcp"
    --mcp-config: string   # numcp config path; falls back to $env.NU_MCP_CONFIG, then "numcp.toml"
] {
    let daemon = $env.NU_AI_DAEMON? | default "http://127.0.0.1:9876"
    let cmd    = $mcp_command | default ($env.NU_MCP_COMMAND? | default "numcp")
    let cfg    = $mcp_config  | default ($env.NU_MCP_CONFIG?  | default "numcp.toml")
    mut body = {
        message:     $message
        mcp_command: $cmd
        mcp_args:    ["serve" "--config" $cfg]
    }
    if ($provider | is-not-empty) { $body = $body | insert provider $provider }
    if ($model | is-not-empty)    { $body = $body | insert model $model }
    http post --content-type application/json $"($daemon)/agent/($agent)" $body
}

# Trigger daemon warm-up: skill discovery, BAML function registration, connection pool priming.
# Returns a status record: {agents, tools, providers, mcp, duration_ms}.
export def baml-warm [] {
    let daemon = $env.NU_AI_DAEMON? | default "http://127.0.0.1:9876"
    http post --content-type application/json $"($daemon)/warm" {}
}

# Check whether the BAML daemon is reachable.
export def baml-health [] {
    let daemon = $env.NU_AI_DAEMON? | default "http://127.0.0.1:9876"
    try {
        http get $"($daemon)/health" | ignore
        true
    } catch {
        false
    }
}

# Configure the daemon address for this session.
export def --env baml-use-daemon [addr: string] {
    $env.NU_AI_DAEMON = $addr
}
