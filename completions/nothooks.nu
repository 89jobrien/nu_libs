module completions {

  # Bootstrap hook runner
  export extern nothooks [
    --force                   # Force re-run of setup hooks
    --config: path            # Path to hooks config TOML
    --state-dir: path         # Directory for state file (default: current dir)
    --help(-h)                # Print help
  ]

  # Run hooks for a phase
  export extern "nothooks run" [
    --phase: string           # Phase to run: dot or setup
    --force                   # Force re-run of setup hooks
    --config: path            # Path to hooks config TOML
    --state-dir: path         # Directory for state file (default: current dir)
    --help(-h)                # Print help
  ]

}

export use completions *
