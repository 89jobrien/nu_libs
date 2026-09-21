module completions {

  # Claude Code course-correction hook pipeline
  export extern coursers [
    --help(-h)                # Print help
  ]

  # PreToolUse hook — reads JSON payload from stdin, writes hook response to stdout
  export extern "coursers pre" [
    --profile: string         # Named profile (resolves to ~/.config/coursers/profiles/<name>/)
    --rules: path             # Override rules file path
    --state: path             # Override global state file path
    --help(-h)                # Print help
  ]

  # PostToolUse hook — reads JSON payload from stdin, records failures
  export extern "coursers post" [
    --profile: string         # Named profile (resolves to ~/.config/coursers/profiles/<name>/)
    --rules: path             # Override rules file path
    --state: path             # Override global state file path
    --help(-h)                # Print help
  ]

  # Filter PostToolUse output — reads hook JSON from stdin, emits hook response to stdout
  export extern "coursers filter" [
    --profile: string
    --rules: path
    --state: path
    --help(-h)                # Print help
  ]

  # Rewrite a PreToolUse command — reads hook JSON from stdin, emits rewritten command or exits 1
  export extern "coursers rewrite" [
    --profile: string
    --rules: path
    --help(-h)                # Print help
  ]

  # Discover missed savings from Claude Code session history
  export extern "coursers discover" [
    --profile: string
    --rules: path
    --all(-a)
    --limit(-l): string
    --since(-s): string
    --format(-f): string
    --generate-filters
    --min-count: string
    --help(-h)                # Print help
  ]

  # Validate rules: check patterns compile, examples fire, exceptions work
  export extern "coursers validate" [
    --profile: string
    --rules: path
    --help(-h)                # Print help
  ]

  # Probe a command against all rules — reads command from stdin
  export extern "coursers probe" [
    --profile: string
    --rules: path
    --help(-h)                # Print help
  ]

  # Show cumulative block counts by rule
  export extern "coursers stats" [
    --profile: string
    --help(-h)                # Print help
  ]

  # Analyze session facets enriched with git context
  export extern "coursers insights" [
    --format(-f): string
    --since(-s): string
    --repo(-r): string
    --help(-h)                # Print help
  ]

  # Show rx prefix learning state
  export extern "coursers audit" [
    --remove: string
    --help(-h)                # Print help
  ]

  # Suggest new rules from unhandled commands
  export extern "coursers suggest" [
    --profile: string
    --rules: path
    --all(-a)
    --since(-s): string
    --limit(-l): string
    --format(-f): string
    --help(-h)                # Print help
  ]

  # Show recent blocked commands
  export extern "coursers history" [
    --limit(-l): string
    --rule(-r): string
    --format(-f): string
    --help(-h)                # Print help
  ]

  # Dump rules + stats + state as portable JSON
  export extern "coursers export" [
    --out(-o): string
    --help(-h)                # Print help
  ]

  # Run the generic hook pipeline for a hook event
  export extern "coursers hook" [
    --target: string
    --help(-h)                # Print help
    event: string
  ]

  # Validate hook pipeline config
  export extern "coursers validate-hooks" [
    --target: string
    --help(-h)                # Print help
  ]

  # Query the hook execution log
  export extern "coursers log" [
    --limit(-l): string
    --event(-e): string
    --outcome(-o): string
    --format(-f): string
    --prune-hours: string
    --help(-h)                # Print help
  ]

  # Show heatmap of rule firings
  export extern "coursers heat" [
    --rule(-r): string
    --help(-h)                # Print help
  ]

  # Replay a session's Bash commands through the current ruleset
  export extern "coursers replay" [
    --session(-s): string
    --format(-f): string
    --help(-h)                # Print help
  ]

  # Validate nu scripts using `nu --ide-check`
  export extern "coursers nu-check" [
    --hooks
    --nu-libs
    --help(-h)                # Print help
    ...files: string
  ]

}

export use completions *
