module completions {

  # Personal swiss-army CLI
  export extern toolz [
    --help(-h)                # Print help
    --version(-V)             # Print version
  ]

  # System maintenance (brew, docker, git, cargo, cache)
  export extern "toolz sys" [
    --brew                    # Run brew update + cleanup
    --docker                  # Run docker image/container prune
    --git                     # Run git gc in ~/dev repos
    --cargo                   # Run cargo sweep on ~/dev
    --cache                   # Clean npm/uv/system caches
    --dry-run                 # Print what would run without executing
    --help(-h)                # Print help
  ]

  # Log analysis
  export extern "toolz log" [
    --help(-h)                # Print help
  ]

  # Show summary stats for a log file
  export extern "toolz log analyze" [
    --help(-h)                # Print help
    file: string              # Path to the log file
  ]

  # Extract lines matching error/warn patterns
  export extern "toolz log errors" [
    --pattern(-p): string     # Regex pattern (default: error|warn|ERRO|WARN)
    --help(-h)                # Print help
    file: string              # Path to the log file
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "toolz log help" [
  ]

  # Show summary stats for a log file
  export extern "toolz log help analyze" [
  ]

  # Extract lines matching error/warn patterns
  export extern "toolz log help errors" [
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "toolz log help help" [
  ]

  # AI chat and RAG
  export extern "toolz ai" [
    --help(-h)                # Print help
  ]

  # Interactive REPL chat
  export extern "toolz ai chat" [
    --provider: string        # Provider override (openai|gemini|ollama)
    --model: string           # Model override
    --help(-h)                # Print help
  ]

  # RAG operations
  export extern "toolz ai rag" [
    --help(-h)                # Print help
  ]

  # Add a file to the RAG store
  export extern "toolz ai rag add" [
    --help(-h)                # Print help
    path: string              # Path to file or directory
  ]

  # Query the RAG store
  export extern "toolz ai rag query" [
    --top-k(-t): string       # Number of results
    --raw                     # Print matched chunks directly without calling an LLM
    --help(-h)                # Print help
    query: string             # Natural language query
  ]

  # Show RAG store stats
  export extern "toolz ai rag status" [
    --help(-h)                # Print help
  ]

  # Index Claude session metadata from ~/.claude/usage-data/
  export extern "toolz ai rag index-sessions" [
    --help(-h)                # Print help
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "toolz ai rag help" [
  ]

  # Add a file to the RAG store
  export extern "toolz ai rag help add" [
  ]

  # Query the RAG store
  export extern "toolz ai rag help query" [
  ]

  # Show RAG store stats
  export extern "toolz ai rag help status" [
  ]

  # Index Claude session metadata from ~/.claude/usage-data/
  export extern "toolz ai rag help index-sessions" [
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "toolz ai rag help help" [
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "toolz ai help" [
  ]

  # Interactive REPL chat
  export extern "toolz ai help chat" [
  ]

  # RAG operations
  export extern "toolz ai help rag" [
  ]

  # Add a file to the RAG store
  export extern "toolz ai help rag add" [
  ]

  # Query the RAG store
  export extern "toolz ai help rag query" [
  ]

  # Show RAG store stats
  export extern "toolz ai help rag status" [
  ]

  # Index Claude session metadata from ~/.claude/usage-data/
  export extern "toolz ai help rag index-sessions" [
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "toolz ai help help" [
  ]

  # Database management
  export extern "toolz db" [
    --help(-h)                # Print help
  ]

  # List configured connections
  export extern "toolz db list" [
    --help(-h)                # Print help
  ]

  # Open an interactive shell for a connection
  export extern "toolz db connect" [
    --help(-h)                # Print help
    name: string              # Connection name
  ]

  # Run a SQL query against a connection
  export extern "toolz db query" [
    --help(-h)                # Print help
    name: string              # Connection name
    sql: string               # SQL statement
  ]

  # Add a named connection
  export extern "toolz db add" [
    --help(-h)                # Print help
    name: string              # Connection name
    driver: string            # Driver (postgres|mysql|sqlite)
    url: string               # Connection URL
  ]

  # Backup a database
  export extern "toolz db backup" [
    --output(-o): string      # Output file (optional, defaults to name-timestamp.sql)
    --help(-h)                # Print help
    name: string              # Connection name
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "toolz db help" [
  ]

  # List configured connections
  export extern "toolz db help list" [
  ]

  # Open an interactive shell for a connection
  export extern "toolz db help connect" [
  ]

  # Run a SQL query against a connection
  export extern "toolz db help query" [
  ]

  # Add a named connection
  export extern "toolz db help add" [
  ]

  # Backup a database
  export extern "toolz db help backup" [
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "toolz db help help" [
  ]

  # Claude projects directory maintenance
  export extern "toolz proj" [
    --help(-h)                # Print help
  ]

  # Run full cleanup: index transcripts, prune stale dirs, rescue memory
  export extern "toolz proj clean" [
    --help(-h)                # Print help
  ]

  # Dry-run: show what would be deleted without making changes
  export extern "toolz proj status" [
    --help(-h)                # Print help
  ]

  # Show recent cleanup log entries
  export extern "toolz proj log" [
    --help(-h)                # Print help
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "toolz proj help" [
  ]

  # Run full cleanup: index transcripts, prune stale dirs, rescue memory
  export extern "toolz proj help clean" [
  ]

  # Dry-run: show what would be deleted without making changes
  export extern "toolz proj help status" [
  ]

  # Show recent cleanup log entries
  export extern "toolz proj help log" [
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "toolz proj help help" [
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "toolz help" [
  ]

  # System maintenance (brew, docker, git, cargo, cache)
  export extern "toolz help sys" [
  ]

  # Log analysis
  export extern "toolz help log" [
  ]

  # Show summary stats for a log file
  export extern "toolz help log analyze" [
  ]

  # Extract lines matching error/warn patterns
  export extern "toolz help log errors" [
  ]

  # AI chat and RAG
  export extern "toolz help ai" [
  ]

  # Interactive REPL chat
  export extern "toolz help ai chat" [
  ]

  # RAG operations
  export extern "toolz help ai rag" [
  ]

  # Add a file to the RAG store
  export extern "toolz help ai rag add" [
  ]

  # Query the RAG store
  export extern "toolz help ai rag query" [
  ]

  # Show RAG store stats
  export extern "toolz help ai rag status" [
  ]

  # Index Claude session metadata from ~/.claude/usage-data/
  export extern "toolz help ai rag index-sessions" [
  ]

  # Database management
  export extern "toolz help db" [
  ]

  # List configured connections
  export extern "toolz help db list" [
  ]

  # Open an interactive shell for a connection
  export extern "toolz help db connect" [
  ]

  # Run a SQL query against a connection
  export extern "toolz help db query" [
  ]

  # Add a named connection
  export extern "toolz help db add" [
  ]

  # Backup a database
  export extern "toolz help db backup" [
  ]

  # Claude projects directory maintenance
  export extern "toolz help proj" [
  ]

  # Run full cleanup: index transcripts, prune stale dirs, rescue memory
  export extern "toolz help proj clean" [
  ]

  # Dry-run: show what would be deleted without making changes
  export extern "toolz help proj status" [
  ]

  # Show recent cleanup log entries
  export extern "toolz help proj log" [
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "toolz help help" [
  ]

}

export use completions *
