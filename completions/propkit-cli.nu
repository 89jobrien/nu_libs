module completions {

  # Scan Rust crates and recommend property tests
  export extern propkit [
    --help(-h)                # Print help
  ]

  # Analyze source files and print property test recommendations
  export extern "propkit scan" [
    --help(-h)                # Print help
    path: path                # Path to the crate root
  ]

  # Generate a standalone property test file
  export extern "propkit generate" [
    --dry-run                 # Print to stdout instead of writing a file
    --append                  # Append to existing test file
    --confidence: string      # Minimum confidence level (high, medium, low)
    --exclude: string         # Exclude specific types
    -o: path                  # Custom output path
    --help(-h)                # Print help
    path: path                # Path to the crate root
  ]

  # Scaffold reusable test infrastructure modules
  export extern "propkit scaffold" [
    --help(-h)                # Print help
  ]

  # Generate smolvm test helpers (RAII VM guard, port utils, fixtures)
  export extern "propkit scaffold smolvm" [
    --dry-run                 # Print to stdout instead of writing a file
    -o: path                  # Custom output path
    --crate-name: string      # Crate name for module header
    --help(-h)                # Print help
  ]

  # Generate TestLinux VM runner (cross-compile + QEMU boot)
  export extern "propkit scaffold testlinux" [
    --dry-run                 # Print to stdout instead of writing a file
    -o: path                  # Custom output path
    --crate-name: string      # Crate name for module header
    --help(-h)                # Print help
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "propkit scaffold help" [
  ]

  # Generate smolvm test helpers (RAII VM guard, port utils, fixtures)
  export extern "propkit scaffold help smolvm" [
  ]

  # Generate TestLinux VM runner (cross-compile + QEMU boot)
  export extern "propkit scaffold help testlinux" [
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "propkit scaffold help help" [
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "propkit help" [
  ]

  # Analyze source files and print property test recommendations
  export extern "propkit help scan" [
  ]

  # Generate a standalone property test file
  export extern "propkit help generate" [
  ]

  # Scaffold reusable test infrastructure modules
  export extern "propkit help scaffold" [
  ]

  # Generate smolvm test helpers (RAII VM guard, port utils, fixtures)
  export extern "propkit help scaffold smolvm" [
  ]

  # Generate TestLinux VM runner (cross-compile + QEMU boot)
  export extern "propkit help scaffold testlinux" [
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "propkit help help" [
  ]

}

export use completions *
