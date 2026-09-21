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

  def "nu-complete taskit dev output" [] {
    [ "human" "compact" "json" "github" "junit" "diagnostic" "sarif" ]
  }

  # Build, install, and workspace-setup commands
  export extern "taskit dev" [
    --dry-run                 # Print commands without executing them
    --output: string@"nu-complete taskit dev output" # Output format: human (default), json, github, junit
    --help(-h)                # Print help (see more with '--help')
  ]

  def "nu-complete taskit dev build output" [] {
    [ "human" "compact" "json" "github" "junit" "diagnostic" "sarif" ]
  }

  # Build the workspace (cargo build --workspace)
  export extern "taskit dev build" [
    --release                 # Build in release mode
    --dry-run                 # Print commands without executing them
    --output: string@"nu-complete taskit dev build output" # Output format: human (default), json, github, junit
    --help(-h)                # Print help (see more with '--help')
  ]

  def "nu-complete taskit dev bootstrap output" [] {
    [ "human" "compact" "json" "github" "junit" "diagnostic" "sarif" ]
  }

  # Set up a workspace for development: install git hooks and dev tools
  export extern "taskit dev bootstrap" [
    --dry-run                 # Print commands without executing them
    --output: string@"nu-complete taskit dev bootstrap output" # Output format: human (default), json, github, junit
    --help(-h)                # Print help (see more with '--help')
  ]

  def "nu-complete taskit dev install-hooks output" [] {
    [ "human" "compact" "json" "github" "junit" "diagnostic" "sarif" ]
  }

  # Install git hooks that delegate to taskit
  export extern "taskit dev install-hooks" [
    --dry-run                 # Print commands without executing them
    --output: string@"nu-complete taskit dev install-hooks output" # Output format: human (default), json, github, junit
    --help(-h)                # Print help (see more with '--help')
  ]

  def "nu-complete taskit dev setup output" [] {
    [ "human" "compact" "json" "github" "junit" "diagnostic" "sarif" ]
  }

  # Install development tools
  export extern "taskit dev setup" [
    --dry-run                 # Print commands without executing them
    --output: string@"nu-complete taskit dev setup output" # Output format: human (default), json, github, junit
    --help(-h)                # Print help (see more with '--help')
  ]

  def "nu-complete taskit dev clean output" [] {
    [ "human" "compact" "json" "github" "junit" "diagnostic" "sarif" ]
  }

  # Clean build artifacts
  export extern "taskit dev clean" [
    --older-than: string
    --dry-run                 # Print commands without executing them
    --output: string@"nu-complete taskit dev clean output" # Output format: human (default), json, github, junit
    --help(-h)                # Print help (see more with '--help')
  ]

  def "nu-complete taskit dev update output" [] {
    [ "human" "compact" "json" "github" "junit" "diagnostic" "sarif" ]
  }

  # Update Cargo.lock dependencies
  export extern "taskit dev update" [
    --aggressive              # Update to latest versions, ignoring semver compatibility
    --dry-run                 # Print commands without executing them
    --output: string@"nu-complete taskit dev update output" # Output format: human (default), json, github, junit
    --help(-h)                # Print help (see more with '--help')
  ]

  def "nu-complete taskit dev update-claude-version output" [] {
    [ "human" "compact" "json" "github" "junit" "diagnostic" "sarif" ]
  }

  # Update pinned Claude Code version
  export extern "taskit dev update-claude-version" [
    --dry-run                 # Print commands without executing them
    --output: string@"nu-complete taskit dev update-claude-version output" # Output format: human (default), json, github, junit
    --help(-h)                # Print help (see more with '--help')
    version: string           # Version string (e.g., "2.1.50")
  ]

  def "nu-complete taskit check output" [] {
    [ "human" "compact" "json" "github" "junit" "diagnostic" "sarif" ]
  }

  # Quality gates: fmt, lint, test, CI
  export extern "taskit check" [
    --dry-run                 # Print commands without executing them
    --output: string@"nu-complete taskit check output" # Output format: human (default), json, github, junit
    --help(-h)                # Print help (see more with '--help')
  ]

  def "nu-complete taskit check fmt output" [] {
    [ "human" "compact" "json" "github" "junit" "diagnostic" "sarif" ]
  }

  # Format all Rust code
  export extern "taskit check fmt" [
    --check                   # Check only, don't modify files
    --affected                # Only format affected crates (git diff vs origin/main)
    --dry-run                 # Print commands without executing them
    --output: string@"nu-complete taskit check fmt output" # Output format: human (default), json, github, junit
    --help(-h)                # Print help (see more with '--help')
  ]

  def "nu-complete taskit check lint output" [] {
    [ "human" "compact" "json" "github" "junit" "diagnostic" "sarif" ]
  }

  # Run clippy lints
  export extern "taskit check lint" [
    --crate-name: string      # Lint a specific crate
    --affected                # Only lint affected crates (git diff vs origin/main)
    --continue-on-error       # Continue linting remaining crates even if one fails
    --fix                     # Auto-apply clippy's suggested fixes (--fix --allow-dirty --allow-staged)
    --dry-run                 # Print commands without executing them
    --output: string@"nu-complete taskit check lint output" # Output format: human (default), json, github, junit
    --help(-h)                # Print help (see more with '--help')
  ]

  def "nu-complete taskit check quick output" [] {
    [ "human" "compact" "json" "github" "junit" "diagnostic" "sarif" ]
  }

  # Fast local feedback: fmt-check + lint + compile-tests + test (affected crates, offline)
  export extern "taskit check quick" [
    --dry-run                 # Print commands without executing them
    --output: string@"nu-complete taskit check quick output" # Output format: human (default), json, github, junit
    --help(-h)                # Print help (see more with '--help')
  ]

  def "nu-complete taskit check ci output" [] {
    [ "human" "compact" "json" "github" "junit" "diagnostic" "sarif" ]
  }

  # Run full local CI (all checks with summary table)
  export extern "taskit check ci" [
    --fail-fast               # Stop immediately after the first failed step
    --include-network         # Include tests that require external network access or credentials (excluded by default)
    --dry-run                 # Print commands without executing them
    --output: string@"nu-complete taskit check ci output" # Output format: human (default), json, github, junit
    --help(-h)                # Print help (see more with '--help')
  ]

  def "nu-complete taskit check compile output" [] {
    [ "human" "compact" "json" "github" "junit" "diagnostic" "sarif" ]
  }

  # Compile all test binaries without running them
  export extern "taskit check compile" [
    --dry-run                 # Print commands without executing them
    --output: string@"nu-complete taskit check compile output" # Output format: human (default), json, github, junit
    --help(-h)                # Print help (see more with '--help')
  ]

  def "nu-complete taskit check deps output" [] {
    [ "human" "compact" "json" "github" "junit" "diagnostic" "sarif" ]
  }

  # Check for unused dependencies
  export extern "taskit check deps" [
    --dry-run                 # Print commands without executing them
    --output: string@"nu-complete taskit check deps output" # Output format: human (default), json, github, junit
    --help(-h)                # Print help (see more with '--help')
  ]

  def "nu-complete taskit check pre-commit output" [] {
    [ "human" "compact" "json" "github" "junit" "diagnostic" "sarif" ]
  }

  # Run pre-commit checks (Rust formatting)
  export extern "taskit check pre-commit" [
    --dry-run                 # Print commands without executing them
    --output: string@"nu-complete taskit check pre-commit output" # Output format: human (default), json, github, junit
    --help(-h)                # Print help (see more with '--help')
  ]

  def "nu-complete taskit check pre-push output" [] {
    [ "human" "compact" "json" "github" "junit" "diagnostic" "sarif" ]
  }

  # Run pre-push checks (affected crate lint + test + coverage + drift)
  export extern "taskit check pre-push" [
    --dry-run                 # Print commands without executing them
    --output: string@"nu-complete taskit check pre-push output" # Output format: human (default), json, github, junit
    --help(-h)                # Print help (see more with '--help')
  ]

  def "nu-complete taskit test output" [] {
    [ "human" "compact" "json" "github" "junit" "diagnostic" "sarif" ]
  }

  # Extended testing: coverage, proptest, fuzz, bench
  export extern "taskit test" [
    --dry-run                 # Print commands without executing them
    --output: string@"nu-complete taskit test output" # Output format: human (default), json, github, junit
    --help(-h)                # Print help (see more with '--help')
  ]

  def "nu-complete taskit test run output" [] {
    [ "human" "compact" "json" "github" "junit" "diagnostic" "sarif" ]
  }

  # Run tests via nextest
  export extern "taskit test run" [
    --crate-name: string
    --affected
    --continue-on-error       # Continue testing remaining crates even if one fails (implies --no-fail-fast)
    --offline                 # Skip tests that require external network access or credentials
    --dry-run                 # Print commands without executing them
    --output: string@"nu-complete taskit test run output" # Output format: human (default), json, github, junit
    --help(-h)                # Print help (see more with '--help')
  ]

  def "nu-complete taskit test coverage output" [] {
    [ "human" "compact" "json" "github" "junit" "diagnostic" "sarif" ]
  }

  # Run tests with coverage
  export extern "taskit test coverage" [
    --crate-name: string
    --threshold: string
    --workspace               # Measure coverage across the whole workspace instead of one crate
    --dry-run                 # Print commands without executing them
    --output: string@"nu-complete taskit test coverage output" # Output format: human (default), json, github, junit
    --help(-h)                # Print help (see more with '--help')
  ]

  def "nu-complete taskit test proptest output" [] {
    [ "human" "compact" "json" "github" "junit" "diagnostic" "sarif" ]
  }

  # Run property-based tests
  export extern "taskit test proptest" [
    --crate-name: string      # Package to run proptests for (required)
    --dry-run                 # Print commands without executing them
    --output: string@"nu-complete taskit test proptest output" # Output format: human (default), json, github, junit
    --help(-h)                # Print help (see more with '--help')
  ]

  def "nu-complete taskit test fuzz output" [] {
    [ "human" "compact" "json" "github" "junit" "diagnostic" "sarif" ]
  }

  # Run cargo-fuzz on a target
  export extern "taskit test fuzz" [
    --duration: string        # Duration in seconds
    --dry-run                 # Print commands without executing them
    --output: string@"nu-complete taskit test fuzz output" # Output format: human (default), json, github, junit
    --help(-h)                # Print help (see more with '--help')
    target: string            # Fuzz target name
  ]

  def "nu-complete taskit test bench output" [] {
    [ "human" "compact" "json" "github" "junit" "diagnostic" "sarif" ]
  }

  # Run criterion benchmarks
  export extern "taskit test bench" [
    --crate-name: string
    --save-baseline
    --dry-run                 # Print commands without executing them
    --output: string@"nu-complete taskit test bench output" # Output format: human (default), json, github, junit
    --help(-h)                # Print help (see more with '--help')
  ]

  def "nu-complete taskit test report output" [] {
    [ "human" "compact" "json" "github" "junit" "diagnostic" "sarif" ]
  }

  # Generate unified coverage report
  export extern "taskit test report" [
    --dry-run                 # Print commands without executing them
    --output: string@"nu-complete taskit test report output" # Output format: human (default), json, github, junit
    --help(-h)                # Print help (see more with '--help')
  ]

  def "nu-complete taskit test snapshots output" [] {
    [ "human" "compact" "json" "github" "junit" "diagnostic" "sarif" ]
  }

  # Review pending insta snapshots
  export extern "taskit test snapshots" [
    --dry-run                 # Print commands without executing them
    --output: string@"nu-complete taskit test snapshots output" # Output format: human (default), json, github, junit
    --help(-h)                # Print help (see more with '--help')
  ]

  def "nu-complete taskit health output" [] {
    [ "human" "compact" "json" "github" "junit" "diagnostic" "sarif" ]
  }

  # Codebase health and metrics
  export extern "taskit health" [
    --dry-run                 # Print commands without executing them
    --output: string@"nu-complete taskit health output" # Output format: human (default), json, github, junit
    --help(-h)                # Print help (see more with '--help')
  ]

  def "nu-complete taskit health check output" [] {
    [ "human" "compact" "json" "github" "junit" "diagnostic" "sarif" ]
  }

  # Measure codebase health and compare against baseline
  export extern "taskit health check" [
    --update                  # Write current metrics to .health-baseline.json
    --with-coverage           # Also measure workspace coverage % (expensive: instrumented build)
    --gate                    # Check only unwrap/expect and warn!() counts against the baseline, ignoring tests/clippy/coverage — for use as a CI step
    --dry-run                 # Print commands without executing them
    --output: string@"nu-complete taskit health check output" # Output format: human (default), json, github, junit
    --help(-h)                # Print help (see more with '--help')
  ]

  def "nu-complete taskit health drift output" [] {
    [ "human" "compact" "json" "github" "junit" "diagnostic" "sarif" ]
  }

  # Compare a telemetry metric's latest reading against its historical baseline
  export extern "taskit health drift" [
    --metric: string          # Metric name (e.g. "ci_duration_ms")
    --window: string          # Lookback window in days
    --dry-run                 # Print commands without executing them
    --output: string@"nu-complete taskit health drift output" # Output format: human (default), json, github, junit
    --help(-h)                # Print help (see more with '--help')
  ]

  def "nu-complete taskit health inspect output" [] {
    [ "human" "compact" "json" "github" "junit" "diagnostic" "sarif" ]
  }

  # Check workspace metrics against thresholds (pass/fail)
  export extern "taskit health inspect" [
    --max-warnings: string    # Maximum allowed clippy warnings (default: from config, or 0)
    --max-todo: string        # Maximum allowed unresolved code markers (unchecked if omitted)
    --dry-run                 # Print commands without executing them
    --output: string@"nu-complete taskit health inspect output" # Output format: human (default), json, github, junit
    --help(-h)                # Print help (see more with '--help')
  ]

  def "nu-complete taskit health version output" [] {
    [ "human" "compact" "json" "github" "junit" "diagnostic" "sarif" ]
  }

  # Show workspace crate versions
  export extern "taskit health version" [
    --dry-run                 # Print commands without executing them
    --output: string@"nu-complete taskit health version output" # Output format: human (default), json, github, junit
    --help(-h)                # Print help (see more with '--help')
  ]

  def "nu-complete taskit protocol output" [] {
    [ "human" "compact" "json" "github" "junit" "diagnostic" "sarif" ]
  }

  # Protocol drift, TODO sync, dependency governance
  export extern "taskit protocol" [
    --dry-run                 # Print commands without executing them
    --output: string@"nu-complete taskit protocol output" # Output format: human (default), json, github, junit
    --help(-h)                # Print help (see more with '--help')
  ]

  def "nu-complete taskit protocol drift output" [] {
    [ "human" "compact" "json" "github" "junit" "diagnostic" "sarif" ]
  }

  # Check protocol drift of core contract surfaces
  export extern "taskit protocol drift" [
    --update
    --warn-only
    --hook
    --watch                   # Continuously watch and auto-remediate drift instead of failing
    --interval: string        # Poll interval in seconds for --watch
    --dry-run                 # Print commands without executing them
    --output: string@"nu-complete taskit protocol drift output" # Output format: human (default), json, github, junit
    --help(-h)                # Print help (see more with '--help')
  ]

  def "nu-complete taskit protocol sites output" [] {
    [ "human" "compact" "json" "github" "junit" "diagnostic" "sarif" ]
  }

  # Count construction sites for key structs
  export extern "taskit protocol sites" [
    --file: string            # File to scan
    --pattern: string         # Pattern to search for
    --expected: string        # Expected count
    --warn-only
    --dry-run                 # Print commands without executing them
    --output: string@"nu-complete taskit protocol sites output" # Output format: human (default), json, github, junit
    --help(-h)                # Print help (see more with '--help')
  ]

  def "nu-complete taskit protocol todo-sync output" [] {
    [ "human" "compact" "json" "github" "junit" "diagnostic" "sarif" ]
  }

  # Scan TODO/FIXME markers and sync them to GitHub issues
  export extern "taskit protocol todo-sync" [
    --update
    --warn-only
    --dry-run                 # Print commands without executing them
    --output: string@"nu-complete taskit protocol todo-sync output" # Output format: human (default), json, github, junit
    --help(-h)                # Print help (see more with '--help')
  ]

  def "nu-complete taskit protocol freshness output" [] {
    [ "human" "compact" "json" "github" "junit" "diagnostic" "sarif" ]
  }

  # Check workspace dependency freshness (Cargo.lock vs latest published versions)
  export extern "taskit protocol freshness" [
    --warn-only               # Report outdated dependencies without failing the command
    --dry-run                 # Print commands without executing them
    --output: string@"nu-complete taskit protocol freshness output" # Output format: human (default), json, github, junit
    --help(-h)                # Print help (see more with '--help')
  ]

  def "nu-complete taskit protocol audit output" [] {
    [ "human" "compact" "json" "github" "junit" "diagnostic" "sarif" ]
  }

  # Run cargo-deny (advisories, licenses, bans)
  export extern "taskit protocol audit" [
    --dry-run                 # Print commands without executing them
    --output: string@"nu-complete taskit protocol audit output" # Output format: human (default), json, github, junit
    --help(-h)                # Print help (see more with '--help')
  ]

  def "nu-complete taskit release output" [] {
    [ "human" "compact" "json" "github" "junit" "diagnostic" "sarif" ]
  }

  # Version bumps and publishing
  export extern "taskit release" [
    --dry-run                 # Print commands without executing them
    --output: string@"nu-complete taskit release output" # Output format: human (default), json, github, junit
    --help(-h)                # Print help (see more with '--help')
  ]

  def "nu-complete taskit release patch output" [] {
    [ "human" "compact" "json" "github" "junit" "diagnostic" "sarif" ]
  }

  # Bump the patch version across all workspace Cargo.toml files
  export extern "taskit release patch" [
    --dry-run                 # Print commands without executing them
    --output: string@"nu-complete taskit release patch output" # Output format: human (default), json, github, junit
    --help(-h)                # Print help (see more with '--help')
  ]

  def "nu-complete taskit release minor output" [] {
    [ "human" "compact" "json" "github" "junit" "diagnostic" "sarif" ]
  }

  # Bump the minor version across all workspace Cargo.toml files
  export extern "taskit release minor" [
    --dry-run                 # Print commands without executing them
    --output: string@"nu-complete taskit release minor output" # Output format: human (default), json, github, junit
    --help(-h)                # Print help (see more with '--help')
  ]

  def "nu-complete taskit release major output" [] {
    [ "human" "compact" "json" "github" "junit" "diagnostic" "sarif" ]
  }

  # Bump the major version across all workspace Cargo.toml files
  export extern "taskit release major" [
    --dry-run                 # Print commands without executing them
    --output: string@"nu-complete taskit release major output" # Output format: human (default), json, github, junit
    --help(-h)                # Print help (see more with '--help')
  ]

  def "nu-complete taskit release publish output" [] {
    [ "human" "compact" "json" "github" "junit" "diagnostic" "sarif" ]
  }

  # Generate docs and publish workspace crates to crates.io
  export extern "taskit release publish" [
    --skip-docs               # Skip documentation generation
    --allow-dirty             # Allow publishing with uncommitted changes
    --dry-run                 # Print commands without executing them
    --output: string@"nu-complete taskit release publish output" # Output format: human (default), json, github, junit
    --help(-h)                # Print help (see more with '--help')
  ]

  def "nu-complete taskit release create output" [] {
    [ "human" "compact" "json" "github" "junit" "diagnostic" "sarif" ]
  }

  # Create a GitHub release for a tagged version
  export extern "taskit release create" [
    --notes-file: string      # Path to release notes file (uses --generate-notes if omitted)
    --dry-run                 # Print commands without executing them
    --output: string@"nu-complete taskit release create output" # Output format: human (default), json, github, junit
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

  def "nu-complete taskit self output" [] {
    [ "human" "compact" "json" "github" "junit" "diagnostic" "sarif" ]
  }

  # Operate on the taskit binary itself: install, test, check tooling
  export extern "taskit self" [
    --dry-run                 # Print commands without executing them
    --output: string@"nu-complete taskit self output" # Output format: human (default), json, github, junit
    --help(-h)                # Print help (see more with '--help')
  ]

  def "nu-complete taskit self install output" [] {
    [ "human" "compact" "json" "github" "junit" "diagnostic" "sarif" ]
  }

  # Install the taskit binary itself (cargo install --path . --force)
  export extern "taskit self install" [
    --dry-run                 # Print commands without executing them
    --output: string@"nu-complete taskit self install output" # Output format: human (default), json, github, junit
    --help(-h)                # Print help (see more with '--help')
  ]

  def "nu-complete taskit self test output" [] {
    [ "human" "compact" "json" "github" "junit" "diagnostic" "sarif" ]
  }

  # Run taskit's own test suite (hash-cached: skipped when source is unchanged)
  export extern "taskit self test" [
    --dry-run                 # Print commands without executing them
    --output: string@"nu-complete taskit self test output" # Output format: human (default), json, github, junit
    --help(-h)                # Print help (see more with '--help')
  ]

  def "nu-complete taskit self check output" [] {
    [ "human" "compact" "json" "github" "junit" "diagnostic" "sarif" ]
  }

  # Verify required tools are installed
  export extern "taskit self check" [
    --dry-run                 # Print commands without executing them
    --output: string@"nu-complete taskit self check output" # Output format: human (default), json, github, junit
    --help(-h)                # Print help (see more with '--help')
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

  def "nu-complete taskit changelog output" [] {
    [ "human" "compact" "json" "github" "junit" "diagnostic" "sarif" ]
  }

  # Generate or preview CHANGELOG.md using git-cliff
  export extern "taskit changelog" [
    --dry-run                 # Print commands without executing them
    --output: string@"nu-complete taskit changelog output" # Output format: human (default), json, github, junit
    --help(-h)                # Print help (see more with '--help')
  ]

  def "nu-complete taskit changelog unreleased output" [] {
    [ "human" "compact" "json" "github" "junit" "diagnostic" "sarif" ]
  }

  # Prepend unreleased changes to CHANGELOG.md
  export extern "taskit changelog unreleased" [
    --dry-run                 # Print commands without executing them
    --output: string@"nu-complete taskit changelog unreleased output" # Output format: human (default), json, github, junit
    --help(-h)                # Print help (see more with '--help')
  ]

  def "nu-complete taskit changelog full output" [] {
    [ "human" "compact" "json" "github" "junit" "diagnostic" "sarif" ]
  }

  # Regenerate the complete CHANGELOG.md
  export extern "taskit changelog full" [
    --dry-run                 # Print commands without executing them
    --output: string@"nu-complete taskit changelog full output" # Output format: human (default), json, github, junit
    --help(-h)                # Print help (see more with '--help')
  ]

  def "nu-complete taskit changelog latest output" [] {
    [ "human" "compact" "json" "github" "junit" "diagnostic" "sarif" ]
  }

  # Prepend the latest tagged release to CHANGELOG.md
  export extern "taskit changelog latest" [
    --dry-run                 # Print commands without executing them
    --output: string@"nu-complete taskit changelog latest output" # Output format: human (default), json, github, junit
    --help(-h)                # Print help (see more with '--help')
  ]

  def "nu-complete taskit changelog preview output" [] {
    [ "human" "compact" "json" "github" "junit" "diagnostic" "sarif" ]
  }

  # Print unreleased changes without writing a file
  export extern "taskit changelog preview" [
    --dry-run                 # Print commands without executing them
    --output: string@"nu-complete taskit changelog preview output" # Output format: human (default), json, github, junit
    --help(-h)                # Print help (see more with '--help')
  ]

}

export use completions *
