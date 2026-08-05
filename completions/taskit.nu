module completions {

  def "nu-complete taskit output" [] {
    [ "human" "compact" "json" "github" "junit" "diagnostic" "sarif" ]
  }

  # Config-driven CI pipeline runner
  export extern taskit [
    --dry-run                 # Print commands without executing them
    --output: string@"nu-complete taskit output" # Output format: human (default), json, github, junit
    --help(-h)                # Print help (see more with '--help')
  ]

  def "nu-complete taskit fmt output" [] {
    [ "human" "compact" "json" "github" "junit" "diagnostic" "sarif" ]
  }

  # Format all Rust code
  export extern "taskit fmt" [
    --check                   # Check only, don't modify files
    --affected                # Only format affected crates (git diff vs origin/main)
    --dry-run                 # Print commands without executing them
    --output: string@"nu-complete taskit fmt output" # Output format: human (default), json, github, junit
    --help(-h)                # Print help (see more with '--help')
  ]

  def "nu-complete taskit lint output" [] {
    [ "human" "compact" "json" "github" "junit" "diagnostic" "sarif" ]
  }

  # Run clippy lints
  export extern "taskit lint" [
    --crate-name: string      # Lint a specific crate
    --affected                # Only lint affected crates (git diff vs origin/main)
    --continue-on-error       # Continue linting remaining crates even if one fails
    --dry-run                 # Print commands without executing them
    --output: string@"nu-complete taskit lint output" # Output format: human (default), json, github, junit
    --help(-h)                # Print help (see more with '--help')
  ]

  def "nu-complete taskit test output" [] {
    [ "human" "compact" "json" "github" "junit" "diagnostic" "sarif" ]
  }

  # Run tests via nextest
  export extern "taskit test" [
    --crate-name: string
    --affected
    --continue-on-error       # Continue testing remaining crates even if one fails (implies --no-fail-fast)
    --offline                 # Skip tests that require external network access or credentials
    --dry-run                 # Print commands without executing them
    --output: string@"nu-complete taskit test output" # Output format: human (default), json, github, junit
    --help(-h)                # Print help (see more with '--help')
  ]

  def "nu-complete taskit coverage output" [] {
    [ "human" "compact" "json" "github" "junit" "diagnostic" "sarif" ]
  }

  # Run tests with coverage
  export extern "taskit coverage" [
    --crate-name: string
    --threshold: string
    --dry-run                 # Print commands without executing them
    --output: string@"nu-complete taskit coverage output" # Output format: human (default), json, github, junit
    --help(-h)                # Print help (see more with '--help')
  ]

  def "nu-complete taskit check-protocol-drift output" [] {
    [ "human" "compact" "json" "github" "junit" "diagnostic" "sarif" ]
  }

  # Check protocol drift of core contract surfaces
  export extern "taskit check-protocol-drift" [
    --update
    --warn-only
    --hook
    --dry-run                 # Print commands without executing them
    --output: string@"nu-complete taskit check-protocol-drift output" # Output format: human (default), json, github, junit
    --help(-h)                # Print help (see more with '--help')
  ]

  def "nu-complete taskit check-protocol-sites output" [] {
    [ "human" "compact" "json" "github" "junit" "diagnostic" "sarif" ]
  }

  # Count construction sites for key structs
  export extern "taskit check-protocol-sites" [
    --file: string            # File to scan
    --pattern: string         # Pattern to search for
    --expected: string        # Expected count
    --warn-only
    --dry-run                 # Print commands without executing them
    --output: string@"nu-complete taskit check-protocol-sites output" # Output format: human (default), json, github, junit
    --help(-h)                # Print help (see more with '--help')
  ]

  def "nu-complete taskit quick output" [] {
    [ "human" "compact" "json" "github" "junit" "diagnostic" "sarif" ]
  }

  # Fast local feedback: fmt-check + lint + compile-tests + test (affected crates, offline)
  export extern "taskit quick" [
    --dry-run                 # Print commands without executing them
    --output: string@"nu-complete taskit quick output" # Output format: human (default), json, github, junit
    --help(-h)                # Print help (see more with '--help')
  ]

  def "nu-complete taskit ci output" [] {
    [ "human" "compact" "json" "github" "junit" "diagnostic" "sarif" ]
  }

  # Run full local CI (all checks with summary table)
  export extern "taskit ci" [
    --fail-fast               # Stop immediately after the first failed step
    --include-network         # Include tests that require external network access or credentials (excluded by default)
    --dry-run                 # Print commands without executing them
    --output: string@"nu-complete taskit ci output" # Output format: human (default), json, github, junit
    --help(-h)                # Print help (see more with '--help')
  ]

  def "nu-complete taskit compile-tests output" [] {
    [ "human" "compact" "json" "github" "junit" "diagnostic" "sarif" ]
  }

  # Compile all test binaries without running them
  export extern "taskit compile-tests" [
    --dry-run                 # Print commands without executing them
    --output: string@"nu-complete taskit compile-tests output" # Output format: human (default), json, github, junit
    --help(-h)                # Print help (see more with '--help')
  ]

  def "nu-complete taskit check-deps output" [] {
    [ "human" "compact" "json" "github" "junit" "diagnostic" "sarif" ]
  }

  # Check for unused dependencies
  export extern "taskit check-deps" [
    --dry-run                 # Print commands without executing them
    --output: string@"nu-complete taskit check-deps output" # Output format: human (default), json, github, junit
    --help(-h)                # Print help (see more with '--help')
  ]

  def "nu-complete taskit check-freshness output" [] {
    [ "human" "compact" "json" "github" "junit" "diagnostic" "sarif" ]
  }

  # Check schema + protocol drift freshness
  export extern "taskit check-freshness" [
    --dry-run                 # Print commands without executing them
    --output: string@"nu-complete taskit check-freshness output" # Output format: human (default), json, github, junit
    --help(-h)                # Print help (see more with '--help')
  ]

  def "nu-complete taskit pre-commit output" [] {
    [ "human" "compact" "json" "github" "junit" "diagnostic" "sarif" ]
  }

  # Run pre-commit checks (Rust formatting)
  export extern "taskit pre-commit" [
    --dry-run                 # Print commands without executing them
    --output: string@"nu-complete taskit pre-commit output" # Output format: human (default), json, github, junit
    --help(-h)                # Print help (see more with '--help')
  ]

  def "nu-complete taskit pre-push output" [] {
    [ "human" "compact" "json" "github" "junit" "diagnostic" "sarif" ]
  }

  # Run pre-push checks (affected crate lint + test + coverage + drift)
  export extern "taskit pre-push" [
    --dry-run                 # Print commands without executing them
    --output: string@"nu-complete taskit pre-push output" # Output format: human (default), json, github, junit
    --help(-h)                # Print help (see more with '--help')
  ]

  def "nu-complete taskit install-hooks output" [] {
    [ "human" "compact" "json" "github" "junit" "diagnostic" "sarif" ]
  }

  # Install git hooks that delegate to taskit
  export extern "taskit install-hooks" [
    --dry-run                 # Print commands without executing them
    --output: string@"nu-complete taskit install-hooks output" # Output format: human (default), json, github, junit
    --help(-h)                # Print help (see more with '--help')
  ]

  def "nu-complete taskit install output" [] {
    [ "human" "compact" "json" "github" "junit" "diagnostic" "sarif" ]
  }

  # Install hooks and dev tools (workspace bootstrap)
  export extern "taskit install" [
    --dry-run                 # Print commands without executing them
    --output: string@"nu-complete taskit install output" # Output format: human (default), json, github, junit
    --help(-h)                # Print help (see more with '--help')
  ]

  def "nu-complete taskit update output" [] {
    [ "human" "compact" "json" "github" "junit" "diagnostic" "sarif" ]
  }

  # Update Cargo.lock dependencies
  export extern "taskit update" [
    --aggressive              # Update to latest versions, ignoring semver compatibility
    --dry-run                 # Print commands without executing them
    --output: string@"nu-complete taskit update output" # Output format: human (default), json, github, junit
    --help(-h)                # Print help (see more with '--help')
  ]

  def "nu-complete taskit patch output" [] {
    [ "human" "compact" "json" "github" "junit" "diagnostic" "sarif" ]
  }

  # Bump the patch version across all workspace Cargo.toml files
  export extern "taskit patch" [
    --dry-run                 # Print commands without executing them
    --output: string@"nu-complete taskit patch output" # Output format: human (default), json, github, junit
    --help(-h)                # Print help (see more with '--help')
  ]

  def "nu-complete taskit minor output" [] {
    [ "human" "compact" "json" "github" "junit" "diagnostic" "sarif" ]
  }

  # Bump the minor version across all workspace Cargo.toml files
  export extern "taskit minor" [
    --dry-run                 # Print commands without executing them
    --output: string@"nu-complete taskit minor output" # Output format: human (default), json, github, junit
    --help(-h)                # Print help (see more with '--help')
  ]

  def "nu-complete taskit major output" [] {
    [ "human" "compact" "json" "github" "junit" "diagnostic" "sarif" ]
  }

  # Bump the major version across all workspace Cargo.toml files
  export extern "taskit major" [
    --dry-run                 # Print commands without executing them
    --output: string@"nu-complete taskit major output" # Output format: human (default), json, github, junit
    --help(-h)                # Print help (see more with '--help')
  ]

  def "nu-complete taskit audit output" [] {
    [ "human" "compact" "json" "github" "junit" "diagnostic" "sarif" ]
  }

  # Run cargo-deny (advisories, licenses, bans)
  export extern "taskit audit" [
    --dry-run                 # Print commands without executing them
    --output: string@"nu-complete taskit audit output" # Output format: human (default), json, github, junit
    --help(-h)                # Print help (see more with '--help')
  ]

  def "nu-complete taskit clean output" [] {
    [ "human" "compact" "json" "github" "junit" "diagnostic" "sarif" ]
  }

  # Clean build artifacts
  export extern "taskit clean" [
    --older-than: string
    --dry-run                 # Print commands without executing them
    --output: string@"nu-complete taskit clean output" # Output format: human (default), json, github, junit
    --help(-h)                # Print help (see more with '--help')
  ]

  def "nu-complete taskit version output" [] {
    [ "human" "compact" "json" "github" "junit" "diagnostic" "sarif" ]
  }

  # Show workspace crate versions
  export extern "taskit version" [
    --dry-run                 # Print commands without executing them
    --output: string@"nu-complete taskit version output" # Output format: human (default), json, github, junit
    --help(-h)                # Print help (see more with '--help')
  ]

  def "nu-complete taskit dev-setup output" [] {
    [ "human" "compact" "json" "github" "junit" "diagnostic" "sarif" ]
  }

  # Install development tools
  export extern "taskit dev-setup" [
    --dry-run                 # Print commands without executing them
    --output: string@"nu-complete taskit dev-setup output" # Output format: human (default), json, github, junit
    --help(-h)                # Print help (see more with '--help')
  ]

  def "nu-complete taskit self-check output" [] {
    [ "human" "compact" "json" "github" "junit" "diagnostic" "sarif" ]
  }

  # Verify required tools are installed
  export extern "taskit self-check" [
    --dry-run                 # Print commands without executing them
    --output: string@"nu-complete taskit self-check output" # Output format: human (default), json, github, junit
    --help(-h)                # Print help (see more with '--help')
  ]

  def "nu-complete taskit self-test output" [] {
    [ "human" "compact" "json" "github" "junit" "diagnostic" "sarif" ]
  }

  # Run taskit's own test suite (hash-cached: skipped when source is unchanged)
  export extern "taskit self-test" [
    --dry-run                 # Print commands without executing them
    --output: string@"nu-complete taskit self-test output" # Output format: human (default), json, github, junit
    --help(-h)                # Print help (see more with '--help')
  ]

  def "nu-complete taskit update-claude-version output" [] {
    [ "human" "compact" "json" "github" "junit" "diagnostic" "sarif" ]
  }

  # Update pinned Claude Code version
  export extern "taskit update-claude-version" [
    --dry-run                 # Print commands without executing them
    --output: string@"nu-complete taskit update-claude-version output" # Output format: human (default), json, github, junit
    --help(-h)                # Print help (see more with '--help')
    version: string           # Version string (e.g., "2.1.50")
  ]

  def "nu-complete taskit proptest output" [] {
    [ "human" "compact" "json" "github" "junit" "diagnostic" "sarif" ]
  }

  # Run property-based tests
  export extern "taskit proptest" [
    --crate-name: string      # Package to run proptests for (required)
    --dry-run                 # Print commands without executing them
    --output: string@"nu-complete taskit proptest output" # Output format: human (default), json, github, junit
    --help(-h)                # Print help (see more with '--help')
  ]

  def "nu-complete taskit fuzz output" [] {
    [ "human" "compact" "json" "github" "junit" "diagnostic" "sarif" ]
  }

  # Run cargo-fuzz on a target
  export extern "taskit fuzz" [
    --duration: string        # Duration in seconds
    --dry-run                 # Print commands without executing them
    --output: string@"nu-complete taskit fuzz output" # Output format: human (default), json, github, junit
    --help(-h)                # Print help (see more with '--help')
    target: string            # Fuzz target name
  ]

  def "nu-complete taskit bench output" [] {
    [ "human" "compact" "json" "github" "junit" "diagnostic" "sarif" ]
  }

  # Run criterion benchmarks
  export extern "taskit bench" [
    --crate-name: string
    --save-baseline
    --dry-run                 # Print commands without executing them
    --output: string@"nu-complete taskit bench output" # Output format: human (default), json, github, junit
    --help(-h)                # Print help (see more with '--help')
  ]

  def "nu-complete taskit test-report output" [] {
    [ "human" "compact" "json" "github" "junit" "diagnostic" "sarif" ]
  }

  # Generate unified coverage report
  export extern "taskit test-report" [
    --dry-run                 # Print commands without executing them
    --output: string@"nu-complete taskit test-report output" # Output format: human (default), json, github, junit
    --help(-h)                # Print help (see more with '--help')
  ]

  def "nu-complete taskit snapshot-review output" [] {
    [ "human" "compact" "json" "github" "junit" "diagnostic" "sarif" ]
  }

  # Review pending insta snapshots
  export extern "taskit snapshot-review" [
    --dry-run                 # Print commands without executing them
    --output: string@"nu-complete taskit snapshot-review output" # Output format: human (default), json, github, junit
    --help(-h)                # Print help (see more with '--help')
  ]

  def "nu-complete taskit health output" [] {
    [ "human" "compact" "json" "github" "junit" "diagnostic" "sarif" ]
  }

  # Measure codebase health and compare against baseline
  export extern "taskit health" [
    --update                  # Write current metrics to .health-baseline.json
    --dry-run                 # Print commands without executing them
    --output: string@"nu-complete taskit health output" # Output format: human (default), json, github, junit
    --help(-h)                # Print help (see more with '--help')
  ]

  def "nu-complete taskit drift output" [] {
    [ "human" "compact" "json" "github" "junit" "diagnostic" "sarif" ]
  }

  # Compare a telemetry metric's latest reading against its historical baseline
  export extern "taskit drift" [
    --metric: string          # Metric name (e.g. "ci_duration_ms")
    --window: string          # Lookback window in days
    --dry-run                 # Print commands without executing them
    --output: string@"nu-complete taskit drift output" # Output format: human (default), json, github, junit
    --help(-h)                # Print help (see more with '--help')
  ]

  def "nu-complete taskit inspect output" [] {
    [ "human" "compact" "json" "github" "junit" "diagnostic" "sarif" ]
  }

  # Check workspace metrics against thresholds (pass/fail)
  export extern "taskit inspect" [
    --max-warnings: string    # Maximum allowed clippy warnings (default: from config, or 0)
    --max-todo: string        # Maximum allowed unresolved code markers (unchecked if omitted)
    --dry-run                 # Print commands without executing them
    --output: string@"nu-complete taskit inspect output" # Output format: human (default), json, github, junit
    --help(-h)                # Print help (see more with '--help')
  ]

  def "nu-complete taskit publish output" [] {
    [ "human" "compact" "json" "github" "junit" "diagnostic" "sarif" ]
  }

  # Generate docs and publish workspace crates to crates.io
  export extern "taskit publish" [
    --skip-docs               # Skip documentation generation
    --allow-dirty             # Allow publishing with uncommitted changes
    --dry-run                 # Print commands without executing them
    --output: string@"nu-complete taskit publish output" # Output format: human (default), json, github, junit
    --help(-h)                # Print help (see more with '--help')
  ]

  def "nu-complete taskit release output" [] {
    [ "human" "compact" "json" "github" "junit" "diagnostic" "sarif" ]
  }

  # Create a GitHub release for a tagged version
  export extern "taskit release" [
    --notes-file: string      # Path to release notes file (uses --generate-notes if omitted)
    --dry-run                 # Print commands without executing them
    --output: string@"nu-complete taskit release output" # Output format: human (default), json, github, junit
    --help(-h)                # Print help (see more with '--help')
    tag: string               # Git tag for the release (e.g. v0.7.0)
  ]

  def "nu-complete taskit flow output" [] {
    [ "human" "compact" "json" "github" "junit" "diagnostic" "sarif" ]
  }

  # Git branching workflow: main -> staging -> release -> main
  export extern "taskit flow" [
    --dry-run                 # Print commands without executing them
    --output: string@"nu-complete taskit flow output" # Output format: human (default), json, github, junit
    --help(-h)                # Print help (see more with '--help')
  ]

  def "nu-complete taskit flow status output" [] {
    [ "human" "compact" "json" "github" "junit" "diagnostic" "sarif" ]
  }

  # Show branch positions and ahead/behind counts
  export extern "taskit flow status" [
    --dry-run                 # Print commands without executing them
    --output: string@"nu-complete taskit flow status output" # Output format: human (default), json, github, junit
    --help(-h)                # Print help (see more with '--help')
  ]

  def "nu-complete taskit flow sync output" [] {
    [ "human" "compact" "json" "github" "junit" "diagnostic" "sarif" ]
  }

  # Merge main into develop (bring in latest stable)
  export extern "taskit flow sync" [
    --dry-run                 # Print commands without executing them
    --output: string@"nu-complete taskit flow sync output" # Output format: human (default), json, github, junit
    --help(-h)                # Print help (see more with '--help')
  ]

  def "nu-complete taskit flow promote output" [] {
    [ "human" "compact" "json" "github" "junit" "diagnostic" "sarif" ]
  }

  # Advance current branch one stage: develop→staging, staging→release, release→main
  export extern "taskit flow promote" [
    --dry-run                 # Print commands without executing them
    --output: string@"nu-complete taskit flow promote output" # Output format: human (default), json, github, junit
    --help(-h)                # Print help (see more with '--help')
  ]

  def "nu-complete taskit flow auto output" [] {
    [ "human" "compact" "json" "github" "junit" "diagnostic" "sarif" ]
  }

  # Run the full pipeline across all stages with CI gate (conflict resolution requires BAML)
  export extern "taskit flow auto" [
    --dry-run                 # Print commands without executing them
    --output: string@"nu-complete taskit flow auto output" # Output format: human (default), json, github, junit
    --help(-h)                # Print help (see more with '--help')
  ]

  def "nu-complete taskit flow guard output" [] {
    [ "human" "compact" "json" "github" "junit" "diagnostic" "sarif" ]
  }

  # Validate current branch is not protected (for pre-commit hooks)
  export extern "taskit flow guard" [
    --dry-run                 # Print commands without executing them
    --output: string@"nu-complete taskit flow guard output" # Output format: human (default), json, github, junit
    --help(-h)                # Print help (see more with '--help')
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "taskit flow help" [
  ]

  # Show branch positions and ahead/behind counts
  export extern "taskit flow help status" [
  ]

  # Merge main into develop (bring in latest stable)
  export extern "taskit flow help sync" [
  ]

  # Advance current branch one stage: develop→staging, staging→release, release→main
  export extern "taskit flow help promote" [
  ]

  # Run the full pipeline across all stages with CI gate (conflict resolution requires BAML)
  export extern "taskit flow help auto" [
  ]

  # Validate current branch is not protected (for pre-commit hooks)
  export extern "taskit flow help guard" [
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "taskit flow help help" [
  ]

  def "nu-complete taskit dashboard output" [] {
    [ "human" "compact" "json" "github" "junit" "diagnostic" "sarif" ]
  }

  # Live terminal dashboard: workspace health, CI telemetry, and drift
  export extern "taskit dashboard" [
    --dry-run                 # Print commands without executing them
    --output: string@"nu-complete taskit dashboard output" # Output format: human (default), json, github, junit
    --help(-h)                # Print help (see more with '--help')
  ]

  def "nu-complete taskit init output" [] {
    [ "human" "compact" "json" "github" "junit" "diagnostic" "sarif" ]
  }

  # Generate taskit.toml and Cruxfile for the current workspace
  export extern "taskit init" [
    --force                   # Overwrite existing taskit.toml
    --interactive             # Interactive mode with prompts
    --dry-run                 # Print commands without executing them
    --output: string@"nu-complete taskit init output" # Output format: human (default), json, github, junit
    --help(-h)                # Print help (see more with '--help')
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "taskit help" [
  ]

  # Format all Rust code
  export extern "taskit help fmt" [
  ]

  # Run clippy lints
  export extern "taskit help lint" [
  ]

  # Run tests via nextest
  export extern "taskit help test" [
  ]

  # Run tests with coverage
  export extern "taskit help coverage" [
  ]

  # Check protocol drift of core contract surfaces
  export extern "taskit help check-protocol-drift" [
  ]

  # Count construction sites for key structs
  export extern "taskit help check-protocol-sites" [
  ]

  # Fast local feedback: fmt-check + lint + compile-tests + test (affected crates, offline)
  export extern "taskit help quick" [
  ]

  # Run full local CI (all checks with summary table)
  export extern "taskit help ci" [
  ]

  # Compile all test binaries without running them
  export extern "taskit help compile-tests" [
  ]

  # Check for unused dependencies
  export extern "taskit help check-deps" [
  ]

  # Check schema + protocol drift freshness
  export extern "taskit help check-freshness" [
  ]

  # Run pre-commit checks (Rust formatting)
  export extern "taskit help pre-commit" [
  ]

  # Run pre-push checks (affected crate lint + test + coverage + drift)
  export extern "taskit help pre-push" [
  ]

  # Install git hooks that delegate to taskit
  export extern "taskit help install-hooks" [
  ]

  # Install hooks and dev tools (workspace bootstrap)
  export extern "taskit help install" [
  ]

  # Update Cargo.lock dependencies
  export extern "taskit help update" [
  ]

  # Bump the patch version across all workspace Cargo.toml files
  export extern "taskit help patch" [
  ]

  # Bump the minor version across all workspace Cargo.toml files
  export extern "taskit help minor" [
  ]

  # Bump the major version across all workspace Cargo.toml files
  export extern "taskit help major" [
  ]

  # Run cargo-deny (advisories, licenses, bans)
  export extern "taskit help audit" [
  ]

  # Clean build artifacts
  export extern "taskit help clean" [
  ]

  # Show workspace crate versions
  export extern "taskit help version" [
  ]

  # Install development tools
  export extern "taskit help dev-setup" [
  ]

  # Verify required tools are installed
  export extern "taskit help self-check" [
  ]

  # Run taskit's own test suite (hash-cached: skipped when source is unchanged)
  export extern "taskit help self-test" [
  ]

  # Update pinned Claude Code version
  export extern "taskit help update-claude-version" [
  ]

  # Run property-based tests
  export extern "taskit help proptest" [
  ]

  # Run cargo-fuzz on a target
  export extern "taskit help fuzz" [
  ]

  # Run criterion benchmarks
  export extern "taskit help bench" [
  ]

  # Generate unified coverage report
  export extern "taskit help test-report" [
  ]

  # Review pending insta snapshots
  export extern "taskit help snapshot-review" [
  ]

  # Measure codebase health and compare against baseline
  export extern "taskit help health" [
  ]

  # Compare a telemetry metric's latest reading against its historical baseline
  export extern "taskit help drift" [
  ]

  # Check workspace metrics against thresholds (pass/fail)
  export extern "taskit help inspect" [
  ]

  # Generate docs and publish workspace crates to crates.io
  export extern "taskit help publish" [
  ]

  # Create a GitHub release for a tagged version
  export extern "taskit help release" [
  ]

  # Git branching workflow: main -> staging -> release -> main
  export extern "taskit help flow" [
  ]

  # Show branch positions and ahead/behind counts
  export extern "taskit help flow status" [
  ]

  # Merge main into develop (bring in latest stable)
  export extern "taskit help flow sync" [
  ]

  # Advance current branch one stage: develop→staging, staging→release, release→main
  export extern "taskit help flow promote" [
  ]

  # Run the full pipeline across all stages with CI gate (conflict resolution requires BAML)
  export extern "taskit help flow auto" [
  ]

  # Validate current branch is not protected (for pre-commit hooks)
  export extern "taskit help flow guard" [
  ]

  # Live terminal dashboard: workspace health, CI telemetry, and drift
  export extern "taskit help dashboard" [
  ]

  # Generate taskit.toml and Cruxfile for the current workspace
  export extern "taskit help init" [
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "taskit help help" [
  ]

}

export use completions *
