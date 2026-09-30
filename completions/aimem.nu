module completions {

  export extern aimem [
    --help(-h)                # Print help
    --db-path: string         # Explicit path to the Turso DB file.
    --verbose(-v)             # Increase log verbosity (-v, -vv).
  ]

  export extern "aimem mine" [
    --help(-h)                # Print help
  ]

  export extern "aimem search" [
    --help(-h)                # Print help
  ]

  export extern "aimem status" [
    --help(-h)                # Print help
  ]

  export extern "aimem wake-up" [
    --help(-h)                # Print help
  ]

}

export use completions *
