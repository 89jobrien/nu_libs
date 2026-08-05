module completions {

  # Workspace module graph and symbol analysis
  export extern notgraph [
    --output: path
    --fail-on-cycles
    --top: string
    --help(-h)                # Print help
  ]

}

export use completions *
