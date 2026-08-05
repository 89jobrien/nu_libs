module completions {

  # Recursive Language Model inference
  export extern mlrs [
    --provider: string        # Provider: openai or anthropic (overrides RSLM_PROVIDER)
    --model: string           # Model ID (overrides RSLM_MODEL)
    --max-depth: string       # Maximum recursion depth
    --verbose                 # Stream recursive cell trace to stderr
    --help(-h)                # Print help
  ]

  # Run a query against a context
  export extern "mlrs query" [
    --context: string         # Context string
    --context-file: path      # Path to context file
    --provider: string        # Provider: openai or anthropic (overrides RSLM_PROVIDER)
    --model: string           # Model ID (overrides RSLM_MODEL)
    --max-depth: string       # Maximum recursion depth
    --verbose                 # Stream recursive cell trace to stderr
    --help(-h)                # Print help
    query: string
  ]

  # Interactive REPL mode
  export extern "mlrs interactive" [
    --provider: string        # Provider: openai or anthropic (overrides RSLM_PROVIDER)
    --model: string           # Model ID (overrides RSLM_MODEL)
    --max-depth: string       # Maximum recursion depth
    --verbose                 # Stream recursive cell trace to stderr
    --help(-h)                # Print help
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "mlrs help" [
  ]

  # Run a query against a context
  export extern "mlrs help query" [
  ]

  # Interactive REPL mode
  export extern "mlrs help interactive" [
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "mlrs help help" [
  ]

}

export use completions *
