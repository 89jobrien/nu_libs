module completions {

  # YAML-driven developer preflight checks
  export extern hooklings [
    --help(-h)                # Print help
  ]

  def "nu-complete hooklings preflight emit" [] {
    [ "json" "table" "both" ]
  }

  # Run all enabled checks in the configured pipeline
  export extern "hooklings preflight" [
    --emit: string@"nu-complete hooklings preflight emit"
    --pipeline: path          # Override pipeline file
    --help(-h)                # Print help
  ]

  # Run a single named check
  export extern "hooklings check" [
    --help(-h)                # Print help
    name: string
  ]

  # Print the merged effective config
  export extern "hooklings config" [
    --help(-h)                # Print help
  ]

  export extern "hooklings config show" [
    --help(-h)                # Print help
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "hooklings config help" [
  ]

  export extern "hooklings config help show" [
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "hooklings config help help" [
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "hooklings help" [
  ]

  # Run all enabled checks in the configured pipeline
  export extern "hooklings help preflight" [
  ]

  # Run a single named check
  export extern "hooklings help check" [
  ]

  # Print the merged effective config
  export extern "hooklings help config" [
  ]

  export extern "hooklings help config show" [
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "hooklings help help" [
  ]

}

export use completions *
