module completions {

  # Publish crates through configurable promotion pipelines
  export extern cargo-promote [
    --help(-h)                # Print help
  ]

  # Publish a crate to the first stage of a pipeline
  export extern "cargo-promote publish" [
    --path(-p): path
    --package(-p): string
    --allow-dirty
    --pipeline: string
    --registry: string
    --force                   # Publish even if the version already exists in the registry
    --help(-h)                # Print help
  ]

  # Promote a crate from one pipeline stage to the next
  export extern "cargo-promote promote" [
    --package(-p): string
    --path(-p): path
    --yes(-y)
    --dry-run
    --pipeline: string
    --from: string
    --help(-h)                # Print help
  ]

  # Run all stages of a pipeline
  export extern "cargo-promote ship" [
    --package(-p): string
    --path(-p): path
    --allow-dirty
    --yes(-y)
    --pipeline: string
    --force                   # Publish even if versions already exist in registries
    --help(-h)                # Print help
  ]

  # List crates in a registry
  export extern "cargo-promote list" [
    --registry: string
    --help(-h)                # Print help
  ]

  # Show local crate versions
  export extern "cargo-promote status" [
    --path(-p): path
    --help(-h)                # Print help
  ]

  # Publish all crates under a directory in dependency order
  export extern "cargo-promote publish-all" [
    --path(-p): path          # Root directory to scan (defaults to ~/dev)
    --allow-dirty             # Allow dirty working directories
    --dry-run                 # Dry run -- show publish order without publishing
    --registry: string        # Registry to publish to (defaults to pipeline first stage)
    --skip: string            # Repos to skip (comma-separated)
    --force                   # Publish even if versions already exist in registries
    --help(-h)                # Print help
  ]

  # Bump version and create promote.lock
  export extern "cargo-promote bump" [
    --path(-p): path
    --package(-p): string
    --help(-h)                # Print help
  ]

  # Branch from one stage to the next
  export extern "cargo-promote branch" [
    --path(-p): path
    --from: string
    --to: string              # Target stage (defaults to next stage in pipeline)
    --tag                     # After the final branch merge, tag the release
    --help(-h)                # Print help
  ]

  # CI promote: FF-merge develop → main, rail patch bump, push commit + tags
  export extern "cargo-promote ci-promote" [
    --remote: string          # Git remote name
    --from: string            # Source branch (default: develop)
    --to: string              # Target branch (default: main)
    --package: string         # Crate / package name to pass to cargo-rail
    --path(-p): path
    --dry-run(-n)             # Print plan, make no changes
    --help(-h)                # Print help
  ]

  # Defer promotion to the next stage (provisional, pending confirmation)
  export extern "cargo-promote defer" [
    --package: string
    --path: path
    --from: string
    --pipeline: string
    --branch                  # Defer a branch pipeline merge instead of a registry publish
    --command: string         # Notification command to fire (non-blocking)
    --help(-h)                # Print help
  ]

  # Confirm a pending deferral
  export extern "cargo-promote confirm" [
    --path(-p): path
    --reason: string
    --help(-h)                # Print help
    ticket: string            # Deferral ticket ID
  ]

  # Reject a pending deferral
  export extern "cargo-promote reject" [
    --path(-p): path
    --reason: string
    --help(-h)                # Print help
    ticket: string            # Deferral ticket ID
  ]

  # List deferrals
  export extern "cargo-promote deferrals" [
    --path(-p): path
    --pending                 # Show only pending deferrals
    --help(-h)                # Print help
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "cargo-promote help" [
  ]

  # Publish a crate to the first stage of a pipeline
  export extern "cargo-promote help publish" [
  ]

  # Promote a crate from one pipeline stage to the next
  export extern "cargo-promote help promote" [
  ]

  # Run all stages of a pipeline
  export extern "cargo-promote help ship" [
  ]

  # List crates in a registry
  export extern "cargo-promote help list" [
  ]

  # Show local crate versions
  export extern "cargo-promote help status" [
  ]

  # Publish all crates under a directory in dependency order
  export extern "cargo-promote help publish-all" [
  ]

  # Bump version and create promote.lock
  export extern "cargo-promote help bump" [
  ]

  # Branch from one stage to the next
  export extern "cargo-promote help branch" [
  ]

  # CI promote: FF-merge develop → main, rail patch bump, push commit + tags
  export extern "cargo-promote help ci-promote" [
  ]

  # Defer promotion to the next stage (provisional, pending confirmation)
  export extern "cargo-promote help defer" [
  ]

  # Confirm a pending deferral
  export extern "cargo-promote help confirm" [
  ]

  # Reject a pending deferral
  export extern "cargo-promote help reject" [
  ]

  # List deferrals
  export extern "cargo-promote help deferrals" [
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "cargo-promote help help" [
  ]

}

export use completions *
