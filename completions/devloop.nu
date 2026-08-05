module completions {

  def "nu-complete devloop format" [] {
    [ "json" "text" ]
  }

  # devloop — static analysis tool for git repos and Claude Code sessions
  export extern devloop [
    --format: string@"nu-complete devloop format"
    --help(-h)                # Print help
    --version(-V)             # Print version
  ]

  def "nu-complete devloop git format" [] {
    [ "json" "text" ]
  }

  # Repository insights — branches, timeline, analysis
  export extern "devloop git" [
    --format: string@"nu-complete devloop git format"
    --help(-h)                # Print help
  ]

  def "nu-complete devloop git branches format" [] {
    [ "json" "text" ]
  }

  # List all branches with summary info
  export extern "devloop git branches" [
    --format: string@"nu-complete devloop git branches format"
    --help(-h)                # Print help
  ]

  def "nu-complete devloop git branch format" [] {
    [ "json" "text" ]
  }

  # Show detail for a single branch
  export extern "devloop git branch" [
    --format: string@"nu-complete devloop git branch format"
    --help(-h)                # Print help
    name: string              # Branch name
  ]

  def "nu-complete devloop git timeline format" [] {
    [ "json" "text" ]
  }

  # Show timeline of commits and Claude sessions
  export extern "devloop git timeline" [
    --branch: string          # Filter by branch name
    --format: string@"nu-complete devloop git timeline format"
    --help(-h)                # Print help
  ]

  def "nu-complete devloop git analyze format" [] {
    [ "json" "text" ]
  }

  # AI-powered branch analysis (requires InsightProvider)
  export extern "devloop git analyze" [
    --format: string@"nu-complete devloop git analyze format"
    --help(-h)                # Print help
    branch: string            # Branch name to analyze
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "devloop git help" [
  ]

  # List all branches with summary info
  export extern "devloop git help branches" [
  ]

  # Show detail for a single branch
  export extern "devloop git help branch" [
  ]

  # Show timeline of commits and Claude sessions
  export extern "devloop git help timeline" [
  ]

  # AI-powered branch analysis (requires InsightProvider)
  export extern "devloop git help analyze" [
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "devloop git help help" [
  ]

  def "nu-complete devloop gkg format" [] {
    [ "json" "text" ]
  }

  # Code structure — index, query, metrics
  export extern "devloop gkg" [
    --format: string@"nu-complete devloop gkg format"
    --help(-h)                # Print help
  ]

  def "nu-complete devloop gkg metrics format" [] {
    [ "json" "text" ]
  }

  # Show code structure metrics for current repo
  export extern "devloop gkg metrics" [
    --format: string@"nu-complete devloop gkg metrics format"
    --help(-h)                # Print help
  ]

  def "nu-complete devloop gkg index format" [] {
    [ "json" "text" ]
  }

  # Index current repo into GKG (requires gkg CLI)
  export extern "devloop gkg index" [
    --format: string@"nu-complete devloop gkg index format"
    --help(-h)                # Print help
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "devloop gkg help" [
  ]

  # Show code structure metrics for current repo
  export extern "devloop gkg help metrics" [
  ]

  # Index current repo into GKG (requires gkg CLI)
  export extern "devloop gkg help index" [
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "devloop gkg help help" [
  ]

  def "nu-complete devloop pipeline format" [] {
    [ "json" "text" ]
  }

  # Multi-source event aggregation pipeline
  export extern "devloop pipeline" [
    --format: string@"nu-complete devloop pipeline format"
    --help(-h)                # Print help
  ]

  def "nu-complete devloop pipeline start format" [] {
    [ "json" "text" ]
  }

  # Start the data aggregation pipeline
  export extern "devloop pipeline start" [
    --repo: string            # Git repository path to watch
    --transcripts: string     # Claude transcripts directory
    --gkg-url: string         # GKG server URL
    --gkg-poll-interval: string # GKG poll interval in seconds
    --batch-size: string      # Batch size for aggregation
    --batch-timeout-ms: string # Batch timeout in milliseconds
    --format: string@"nu-complete devloop pipeline start format"
    --help(-h)                # Print help
  ]

  def "nu-complete devloop pipeline metrics format" [] {
    [ "json" "text" ]
  }

  # Show pipeline metrics
  export extern "devloop pipeline metrics" [
    --format: string@"nu-complete devloop pipeline metrics format"
    --help(-h)                # Print help
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "devloop pipeline help" [
  ]

  # Start the data aggregation pipeline
  export extern "devloop pipeline help start" [
  ]

  # Show pipeline metrics
  export extern "devloop pipeline help metrics" [
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "devloop pipeline help help" [
  ]

  def "nu-complete devloop mcp-server format" [] {
    [ "json" "text" ]
  }

  # Start MCP server for Claude Code integration
  export extern "devloop mcp-server" [
    --format: string@"nu-complete devloop mcp-server format"
    --help(-h)                # Print help
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "devloop help" [
  ]

  # Repository insights — branches, timeline, analysis
  export extern "devloop help git" [
  ]

  # List all branches with summary info
  export extern "devloop help git branches" [
  ]

  # Show detail for a single branch
  export extern "devloop help git branch" [
  ]

  # Show timeline of commits and Claude sessions
  export extern "devloop help git timeline" [
  ]

  # AI-powered branch analysis (requires InsightProvider)
  export extern "devloop help git analyze" [
  ]

  # Code structure — index, query, metrics
  export extern "devloop help gkg" [
  ]

  # Show code structure metrics for current repo
  export extern "devloop help gkg metrics" [
  ]

  # Index current repo into GKG (requires gkg CLI)
  export extern "devloop help gkg index" [
  ]

  # Multi-source event aggregation pipeline
  export extern "devloop help pipeline" [
  ]

  # Start the data aggregation pipeline
  export extern "devloop help pipeline start" [
  ]

  # Show pipeline metrics
  export extern "devloop help pipeline metrics" [
  ]

  # Start MCP server for Claude Code integration
  export extern "devloop help mcp-server" [
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "devloop help help" [
  ]

}

export use completions *
