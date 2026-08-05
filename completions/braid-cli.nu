module completions {

  export extern braid-cli [
    --help(-h)                # Print help
  ]

  # Run a session against a provider
  export extern "braid-cli run" [
    --provider: string        # Provider to use (ollama or openai; default: auto-detect)
    --model: string           # Model name
    --help(-h)                # Print help
    prompt?: string           # Prompt text (reads stdin if omitted)
  ]

  # Check environment health
  export extern "braid-cli doctor" [
    --help(-h)                # Print help
  ]

  # Set up local braid environment (~/.braid/)
  export extern "braid-cli setup" [
    --help(-h)                # Print help
  ]

  # Start MCP server over stdio
  export extern "braid-cli mcp" [
    --help(-h)                # Print help
  ]

  # Manage stored sessions
  export extern "braid-cli sessions" [
    --help(-h)                # Print help
  ]

  # List session IDs, newest first
  export extern "braid-cli sessions list" [
    --help(-h)                # Print help
  ]

  # Print a session's event timeline
  export extern "braid-cli sessions show" [
    --help(-h)                # Print help
    id: string                # Session ID to display
  ]

  # Delete oldest sessions, keeping N most recent
  export extern "braid-cli sessions prune" [
    --keep: string            # Number of sessions to keep
    --help(-h)                # Print help
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "braid-cli sessions help" [
  ]

  # List session IDs, newest first
  export extern "braid-cli sessions help list" [
  ]

  # Print a session's event timeline
  export extern "braid-cli sessions help show" [
  ]

  # Delete oldest sessions, keeping N most recent
  export extern "braid-cli sessions help prune" [
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "braid-cli sessions help help" [
  ]

  # List installed components
  export extern "braid-cli components" [
    --help(-h)                # Print help
  ]

  # List all installed components
  export extern "braid-cli components list" [
    --dir: string             # Directory to scan (default: ~/.braid/components)
    --help(-h)                # Print help
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "braid-cli components help" [
  ]

  # List all installed components
  export extern "braid-cli components help list" [
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "braid-cli components help help" [
  ]

  # Run as a warpx agent harness (JSON-lines output)
  export extern "braid-cli agent" [
    --prompt: string          # Prompt text (reads stdin if omitted)
    --provider: string        # Provider to use (ollama or openai; default: auto-detect)
    --model: string           # Model name
    --max-turns: string       # Maximum engine turns before stopping
    --help(-h)                # Print help
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "braid-cli help" [
  ]

  # Run a session against a provider
  export extern "braid-cli help run" [
  ]

  # Check environment health
  export extern "braid-cli help doctor" [
  ]

  # Set up local braid environment (~/.braid/)
  export extern "braid-cli help setup" [
  ]

  # Start MCP server over stdio
  export extern "braid-cli help mcp" [
  ]

  # Manage stored sessions
  export extern "braid-cli help sessions" [
  ]

  # List session IDs, newest first
  export extern "braid-cli help sessions list" [
  ]

  # Print a session's event timeline
  export extern "braid-cli help sessions show" [
  ]

  # Delete oldest sessions, keeping N most recent
  export extern "braid-cli help sessions prune" [
  ]

  # List installed components
  export extern "braid-cli help components" [
  ]

  # List all installed components
  export extern "braid-cli help components list" [
  ]

  # Run as a warpx agent harness (JSON-lines output)
  export extern "braid-cli help agent" [
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "braid-cli help help" [
  ]

}

export use completions *
