module completions {

  # Recursive Language Model inference
  export extern rslm [
    --provider: string        # Override provider (openai | anthropic); default: RSLM_PROVIDER env or openai
    --model: string           # Override model ID; default: RSLM_MODEL env or provider default
    --max-depth: string       # Maximum recursion depth
    --max-iterations: string  # Maximum loop iterations per RLM instance
    --verbose                 # Stream Rhai cells and outputs to terminal
    --store: string           # Path to SQLite chunk store (enables ctx_chunks/ctx_search/ctx_hybrid Rhai functions)
    --doc-id: string          # Document ID in the store (defaults to context file path)
    --embed-model: string     # Embedding model for semantic search (default: text-embedding-3-small)
    --help(-h)                # Print help
  ]

  # Run a single query with context
  export extern "rslm query" [
    --context-file: string    # Read context from file
    --context: string         # Inline context string
    --provider: string        # Override provider (openai | anthropic); default: RSLM_PROVIDER env or openai
    --model: string           # Override model ID; default: RSLM_MODEL env or provider default
    --max-depth: string       # Maximum recursion depth
    --max-iterations: string  # Maximum loop iterations per RLM instance
    --verbose                 # Stream Rhai cells and outputs to terminal
    --store: string           # Path to SQLite chunk store (enables ctx_chunks/ctx_search/ctx_hybrid Rhai functions)
    --doc-id: string          # Document ID in the store (defaults to context file path)
    --embed-model: string     # Embedding model for semantic search (default: text-embedding-3-small)
    --help(-h)                # Print help
    query: string
  ]

  # Interactive mode: prompts for query and context
  export extern "rslm interactive" [
    --provider: string        # Override provider (openai | anthropic); default: RSLM_PROVIDER env or openai
    --model: string           # Override model ID; default: RSLM_MODEL env or provider default
    --max-depth: string       # Maximum recursion depth
    --max-iterations: string  # Maximum loop iterations per RLM instance
    --verbose                 # Stream Rhai cells and outputs to terminal
    --store: string           # Path to SQLite chunk store (enables ctx_chunks/ctx_search/ctx_hybrid Rhai functions)
    --doc-id: string          # Document ID in the store (defaults to context file path)
    --embed-model: string     # Embedding model for semantic search (default: text-embedding-3-small)
    --help(-h)                # Print help
  ]

  # Ingest a document into the chunk store
  export extern "rslm ingest" [
    --context-file: string    # Context file to ingest
    --strategy: string        # Chunking strategy: fixed, paragraph, line
    --doc-id: string          # Document ID (defaults to file path)
    --provider: string        # Override provider (openai | anthropic); default: RSLM_PROVIDER env or openai
    --model: string           # Override model ID; default: RSLM_MODEL env or provider default
    --max-depth: string       # Maximum recursion depth
    --max-iterations: string  # Maximum loop iterations per RLM instance
    --verbose                 # Stream Rhai cells and outputs to terminal
    --store: string           # Path to SQLite chunk store (enables ctx_chunks/ctx_search/ctx_hybrid Rhai functions)
    --embed-model: string     # Embedding model for semantic search (default: text-embedding-3-small)
    --help(-h)                # Print help
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "rslm help" [
  ]

  # Run a single query with context
  export extern "rslm help query" [
  ]

  # Interactive mode: prompts for query and context
  export extern "rslm help interactive" [
  ]

  # Ingest a document into the chunk store
  export extern "rslm help ingest" [
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "rslm help help" [
  ]

}

export use completions *
