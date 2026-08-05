module completions {

  # Install compatible scripts from local or remote sources
  export extern rx [
    --prefix-config: path
    --help(-h)                # Print help
  ]

  export extern "rx install" [
    --install-dir: path
    --prefix-config: path
    --help(-h)                # Print help
    source: string
  ]

  export extern "rx list" [
    --registry-path: path
    --prefix-config: path
    --help(-h)                # Print help
  ]

  export extern "rx run" [
    --registry-path: path
    --prefix-config: path
    --help(-h)                # Print help
    name: string
    ...args: string
  ]

  # Show git status across all repos in the manifest
  export extern "rx status" [
    --manifest: path          # Path to repos.toml manifest
    --scan: path              # Scan a directory for git repos instead of using the manifest
    --filter(-f): string      # Filter repos (e.g. tag=rust, role=lib, name~dev*)
    --json                    # Output JSON instead of a table
    --prefix-config: path
    --help(-h)                # Print help
  ]

  # Show cross-repo Cargo dependency graph
  export extern "rx graph" [
    --manifest: path          # Path to repos.toml manifest
    --scan: path              # Scan a directory for git repos instead of using the manifest
    --filter(-f): string      # Filter repos (e.g. tag=rust, role=lib, name~dev*)
    --who-uses: string        # Show packages that depend on this package
    --deps: string            # Show transitive dependencies of this package
    --format: string          # Output format: tree, json, mermaid
    --prefix-config: path
    --help(-h)                # Print help
  ]

  # Run a command across all repos in the manifest
  export extern "rx fan" [
    --manifest: path          # Path to repos.toml manifest
    --scan: path              # Scan a directory for git repos instead of using the manifest
    --filter(-f): string      # Filter repos (e.g. tag=rust, role=lib, name~dev*)
    --concurrency(-c): string # Number of parallel workers (default: number of CPUs)
    --timeout: string         # Per-repo timeout in seconds
    --fail-fast               # Stop on first failure
    --dry-run                 # Print planned invocations without running
    --output: string          # Output format: grouped (default) or json
    --prefix-config: path
    --help(-h)                # Print help
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "rx help" [
  ]

  export extern "rx help install" [
  ]

  export extern "rx help list" [
  ]

  export extern "rx help run" [
  ]

  # Show git status across all repos in the manifest
  export extern "rx help status" [
  ]

  # Show cross-repo Cargo dependency graph
  export extern "rx help graph" [
  ]

  # Run a command across all repos in the manifest
  export extern "rx help fan" [
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "rx help help" [
  ]

}

export use completions *
