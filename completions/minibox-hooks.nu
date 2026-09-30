module completions {

  # Claude Code hook binaries
  export extern minibox-hooks [
    --help(-h)                # Print help
  ]

  # Block sudo usage in shell commands
  export extern "minibox-hooks no-sudo" [
    --help(-h)                # Print help
  ]

  # Validate shell commands against deny rules
  export extern "minibox-hooks validate-shell" [
    --help(-h)                # Print help
  ]

  # Scan file writes for embedded secrets
  export extern "minibox-hooks secret-scanner" [
    --help(-h)                # Print help
  ]

  # Block destructive maestro/docker commands
  export extern "minibox-hooks block-destructive" [
    --help(-h)                # Print help
  ]

  # Guard protected branches from direct commits
  export extern "minibox-hooks branch-guard" [
    --help(-h)                # Print help
  ]

}

export use completions *
