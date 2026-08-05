module completions {

  # Lint AI coding agent harness files
  export extern agentlint [
    --format: string          # Output format: pretty | gnu | json (default: pretty when TTY, gnu when piped)
    --difficulty: string      # Difficulty level: easy | hard | painful (overrides .agentlint.toml)
    --exit-zero               # Always exit 0 (audit mode)
    --quiet(-q)               # Suppress the summary stats table
    --infer-schema            # Infer docs schema from corpus and validate outliers against it
    --emit-schema             # Infer docs schema from corpus and print JSON to stdout (implies --infer-schema)
    --help(-h)                # Print help
    --version(-V)             # Print version
    ...paths: path            # Files or directories to validate (defaults to current directory)
  ]

}

export use completions *
