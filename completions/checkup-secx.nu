module completions {

  # Security scanning orchestrator
  export extern secx [
    --help(-h)                # Print help
  ]

  def "nu-complete secx scan category" [] {
    [ "static" "dynamic" "web" "network" "infra" ]
  }

  def "nu-complete secx scan format" [] {
    [ "json" "sarif" "text" ]
  }

  def "nu-complete secx scan fail_on" [] {
    [ "critical" "high" "medium" "low" "info" ]
  }

  # Run security scanners against a target
  export extern "secx scan" [
    --category: string@"nu-complete secx scan category" # Filter to specific categories (comma-separated)
    --tool: string            # Run only named tools (comma-separated)
    --strict                  # Fail on missing tools
    --sequential              # Run scanners sequentially
    --timeout: string         # Per-tool timeout in seconds
    --format: string@"nu-complete secx scan format" # Output format
    --output: path            # Write output to file
    --fail-on: string@"nu-complete secx scan fail_on" # Exit 1 if findings at or above this severity
    --no-cache                # Disable caching
    --help(-h)                # Print help
    target: string            # Target directory, URL, or host
  ]

  # List all available scanners
  export extern "secx list" [
    --help(-h)                # Print help
  ]

  # Check which tools are installed
  export extern "secx check" [
    --help(-h)                # Print help
  ]

  # Cache management
  export extern "secx cache" [
    --help(-h)                # Print help
  ]

  # Show cache stats
  export extern "secx cache info" [
    --help(-h)                # Print help
  ]

  # Clear all cached results
  export extern "secx cache clear" [
    --help(-h)                # Print help
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "secx cache help" [
  ]

  # Show cache stats
  export extern "secx cache help info" [
  ]

  # Clear all cached results
  export extern "secx cache help clear" [
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "secx cache help help" [
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "secx help" [
  ]

  # Run security scanners against a target
  export extern "secx help scan" [
  ]

  # List all available scanners
  export extern "secx help list" [
  ]

  # Check which tools are installed
  export extern "secx help check" [
  ]

  # Cache management
  export extern "secx help cache" [
  ]

  # Show cache stats
  export extern "secx help cache info" [
  ]

  # Clear all cached results
  export extern "secx help cache clear" [
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "secx help help" [
  ]

}

export use completions *
