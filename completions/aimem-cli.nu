module completions {

  # AiMem — give your AI a memory.
  export extern aimem [
    --db-path: path           # Explicit path to the Turso DB file.
    --verbose(-v)             # Increase log verbosity (-v, -vv).
    --help(-h)                # Print help
    --version(-V)             # Print version
  ]

  def "nu-complete aimem mine mode" [] {
    [ "projects" "convos" ]
  }

  # Mine project files or conversation exports into AiMem
  export extern "aimem mine" [
    --mode: string@"nu-complete aimem mine mode"
    --wing: string            # Override wing name. Projects mode otherwise uses aimem.yaml.
    --room: string            # Room for convos mode.
    --agent: string
    --limit: string           # Max files to process (0 = all).
    --dry-run                 # Preview without writing drawers.
    --no-embed                # Store text only without generating embeddings.
    --gemini-key: string      # Use Gemini 2.0 remote embedding.
    --db-path: path           # Explicit path to the Turso DB file.
    --verbose(-v)             # Increase log verbosity (-v, -vv).
    --help(-h)                # Print help
    dir: path                 # Directory to mine
  ]

  # Semantic search over AiMem
  export extern "aimem search" [
    --wing: string
    --room: string
    --results: string
    --gemini-key: string      # Use Gemini 2.0 remote embedding.
    --db-path: path           # Explicit path to the Turso DB file.
    --verbose(-v)             # Increase log verbosity (-v, -vv).
    --help(-h)                # Print help
    query: string             # Query to search for
  ]

  # Render L0 + L1 wake-up context
  export extern "aimem wake-up" [
    --wing: string
    --db-path: path           # Explicit path to the Turso DB file.
    --verbose(-v)             # Increase log verbosity (-v, -vv).
    --help(-h)                # Print help
  ]

  # Show AiMem overview
  export extern "aimem status" [
    --db-path: path           # Explicit path to the Turso DB file.
    --verbose(-v)             # Increase log verbosity (-v, -vv).
    --help(-h)                # Print help
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "aimem help" [
  ]

  # Mine project files or conversation exports into AiMem
  export extern "aimem help mine" [
  ]

  # Semantic search over AiMem
  export extern "aimem help search" [
  ]

  # Render L0 + L1 wake-up context
  export extern "aimem help wake-up" [
  ]

  # Show AiMem overview
  export extern "aimem help status" [
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "aimem help help" [
  ]

}

export use completions *
