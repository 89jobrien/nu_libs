module completions {

  # Turn any MCP server, OpenAPI spec, or GraphQL endpoint into a shell CLI
  export extern mcpipe [
    --mcp-stdio: string       # MCP server command (stdio)
    --mcp: string             # MCP server URL (HTTP/SSE)
    --spec: string            # OpenAPI spec URL or file path
    --graphql: string         # GraphQL endpoint URL
    --auth-header: string     # Auth header with secret resolution (repeatable)
    --header: string          # Arbitrary HTTP header (repeatable)
    --base-url: string        # Override base URL for OpenAPI spec
    --pretty                  # Pretty-print JSON output
    --raw                     # Print raw string values
    --refresh                 # Bypass cache, re-fetch
    --list                    # List available subcommands
    --scan                    # Auto-discover all API surfaces and print a unified catalog
    --search: string          # Search commands by name/description
    --cache-ttl: string       # Cache TTL in seconds (default: 3600)
    --jq: string              # Filter output through jq
    --head: string            # Limit output to first N array elements
    --fields: string          # Override GraphQL selection set fields
    --cli: string             # CLI tool exposing a `schema` subcommand (e.g. doob)
    --gen-openapi             # Generate OpenAPI 3.1 spec from discovered commands and print to stdout
    --openapi-output: string  # Write generated OpenAPI spec to FILE instead of stdout
    --help(-h)                # Print help
  ]

}

export use completions *
