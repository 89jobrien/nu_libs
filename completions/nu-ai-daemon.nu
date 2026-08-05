module completions {

  # BAML agent daemon with numcp MCP tool execution
  export extern nu-ai-daemon [
    --config(-c): string      # Path to config file
    --mock                    # Use mock LLM backend (for testing, no API key required)
    --help(-h)                # Print help
  ]

}

export use completions *
