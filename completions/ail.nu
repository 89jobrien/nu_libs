module completions {

  # Agent Improvement Loop — systematic agent behavior improvement from observed traces
  export extern ail [
    --help(-h)                # Print help
  ]

  # Run the improvement loop (all phases or from a specific phase)
  export extern "ail run" [
    --agent: string           # Which agent's traces to analyze
    --since: string           # Days of trace history to scan
    --phase: string           # Start from this phase (1–7)
    --dry-run                 # Print what would be done without writing files or running commands
    --help(-h)                # Print help
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "ail help" [
  ]

  # Run the improvement loop (all phases or from a specific phase)
  export extern "ail help run" [
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "ail help help" [
  ]

}

export use completions *
