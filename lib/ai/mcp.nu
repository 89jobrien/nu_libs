# Helpers for managing the numcp MCP server process.
#
# numcp currently supports stdio transport only (v1). In stdio mode, the
# nu-ai-daemon spawns numcp directly — Nu does not need to manage the process.
# Pass --mcp-command / --mcp-config to baml-agent-run instead.
#
# mcp-start / mcp-stop exist for future TCP transport (v2), where a shared
# numcp instance serves multiple daemon connections. They also serve as a
# config-injection point: setting $env.NU_MCP_COMMAND / $env.NU_MCP_CONFIG
# so baml-agent-run picks them up without per-call flags.
#
# See: docs/plans/2026-06-09-baml-agent-daemon.md

# Configure numcp for this session.
# Sets env vars that baml-agent-run reads as defaults.
# Does NOT spawn a process (stdio mode — daemon manages the subprocess).
export def --env mcp-start [
    --config: string = "numcp.toml"  # path to numcp.toml
    --command: string = "numcp"      # path to numcp binary
] {
    $env.NU_MCP_COMMAND = $command
    $env.NU_MCP_CONFIG  = $config
    # TODO(v2): spawn numcp with TCP transport and store PID in $env.NU_MCP_PID
    print $"[mcp] configured: ($command) serve --config ($config)"
}

# Clear numcp session config (and stop background process when TCP transport added).
export def --env mcp-stop [] {
    let pid = $env.NU_MCP_PID?
    if ($pid | is-not-empty) {
        # TODO(v2): kill $pid
        $env.NU_MCP_PID = null
    }
    $env.NU_MCP_COMMAND = null
    $env.NU_MCP_CONFIG  = null
    print "[mcp] cleared"
}

# Return the active MCP server address (TCP transport, v2).
# Returns empty string in v1 stdio mode.
export def mcp-addr [] {
    $env.NU_MCP_SERVER? | default ""
}

# Return the numcp command and config currently configured for this session.
export def mcp-status [] {
    {
        command: ($env.NU_MCP_COMMAND? | default "numcp")
        config:  ($env.NU_MCP_CONFIG?  | default "numcp.toml")
        pid:     ($env.NU_MCP_PID?     | default null)
        server:  ($env.NU_MCP_SERVER?  | default null)
    }
}
