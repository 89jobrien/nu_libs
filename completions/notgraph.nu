module completions {

  export extern notgraph [
    --help(-h)                # Print help
    --output: string
    --fail-on-cycles
    --top: string
  ]

}

export use completions *
