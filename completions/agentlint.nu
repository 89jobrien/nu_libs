module completions {

  export extern agentlint [
    --help(-h)                # Print help
    --format: string          # Output format: pretty | gnu | json (default: pretty when TTY, gnu when piped)
    --difficulty: string      # Difficulty level: easy | hard | painful (overrides .agentlint.toml)
    --exit-zero               # Always exit 0 (audit mode)
    --quiet(-q)               # Suppress the summary stats table
    --infer-schema            # Infer docs schema from corpus and validate outliers against it
    --emit-schema             # Infer docs schema from corpus and print JSON to stdout (implies --infer-schema)
  ]

}

export use completions *
