module completions {

  # MCP server exposing Nushell tool handlers
  export extern numcp [
    --help(-h)                # Print help
  ]

  # Start the MCP server (stdio transport)
  export extern "numcp serve" [
    --config(-c): string      # Path to config file
    --help(-h)                # Print help
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "numcp help" [
  ]

  # Start the MCP server (stdio transport)
  export extern "numcp help serve" [
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "numcp help help" [
  ]

}

export use completions *
