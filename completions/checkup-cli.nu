module completions {

  # Workspace health and conformance checks
  export extern checkup [
    --help(-h)                # Print help
  ]

  # Scan test coverage across the workspace (default)
  export extern "checkup scan" [
    --json                    # Emit JSON instead of human-readable summary
    --help(-h)                # Print help
    root?: path               # Workspace root (defaults to cwd)
  ]

  # Analyze module structure
  export extern "checkup analyze" [
    --help(-h)                # Print help
    root?: path               # Workspace root (defaults to cwd)
  ]

  # Print low-coverage report
  export extern "checkup report" [
    --help(-h)                # Print help
    root?: path               # Workspace root (defaults to cwd)
  ]

  # Validate test counts
  export extern "checkup validate" [
    --help(-h)                # Print help
    root?: path               # Workspace root (defaults to cwd)
  ]

  # Check CI status across repos
  export extern "checkup ci-status" [
    --json                    # Emit JSON instead of human-readable output
    --help(-h)                # Print help
    root?: path               # Workspace root (defaults to cwd)
  ]

  # Detect drift between Linear and GitHub issues
  export extern "checkup linear-sync" [
    --project: string         # Linear project ID
    --repo: string            # GitHub repo (owner/name)
    --help(-h)                # Print help
  ]

  # Audit workspace for obfsck secret scan results
  export extern "checkup obfsck-audit" [
    --exclude: string         # Exclude paths (comma-separated)
    --json                    # Emit JSON instead of human-readable output
    --help(-h)                # Print help
    root?: path               # Workspace root (defaults to cwd)
  ]

  # Scan for migration schema health
  export extern "checkup migration-health" [
    --help(-h)                # Print help
    root?: path               # Workspace root (defaults to cwd)
  ]

  # Scan for hj→doob migration surface
  export extern "checkup hj-migration" [
    --json                    # Emit JSON instead of human-readable output
    --help(-h)                # Print help
    root?: path               # Workspace root (defaults to cwd)
  ]

  # Validate plugin conformance
  export extern "checkup plugin-conformance" [
    --help(-h)                # Print help
    root?: path               # Plugin root (defaults to cwd)
  ]

  # Run security scanners
  export extern "checkup security" [
    --help(-h)                # Print help
  ]

  def "nu-complete checkup security scan category" [] {
    [ "static" "dynamic" "web" "network" "infra" ]
  }

  def "nu-complete checkup security scan format" [] {
    [ "json" "sarif" "text" ]
  }

  def "nu-complete checkup security scan fail_on" [] {
    [ "critical" "high" "medium" "low" "info" ]
  }

  # Run security scanners against a target
  export extern "checkup security scan" [
    --category: string@"nu-complete checkup security scan category" # Filter to specific categories (comma-separated)
    --tool: string            # Run only named tools (comma-separated)
    --strict                  # Fail on missing tools
    --sequential              # Run scanners sequentially
    --timeout: string         # Per-tool timeout in seconds
    --format: string@"nu-complete checkup security scan format" # Output format
    --output: path            # Write output to file
    --fail-on: string@"nu-complete checkup security scan fail_on" # Exit 1 if findings at or above this severity
    --no-cache                # Disable caching
    --help(-h)                # Print help
    target?: string           # Target directory, URL, or host
  ]

  # List all available scanners
  export extern "checkup security list" [
    --help(-h)                # Print help
  ]

  # Check which tools are installed
  export extern "checkup security check" [
    --help(-h)                # Print help
  ]

  # Cache management
  export extern "checkup security cache" [
    --help(-h)                # Print help
  ]

  # Show cache stats
  export extern "checkup security cache info" [
    --help(-h)                # Print help
  ]

  # Clear all cached results
  export extern "checkup security cache clear" [
    --help(-h)                # Print help
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "checkup security cache help" [
  ]

  # Show cache stats
  export extern "checkup security cache help info" [
  ]

  # Clear all cached results
  export extern "checkup security cache help clear" [
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "checkup security cache help help" [
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "checkup security help" [
  ]

  # Run security scanners against a target
  export extern "checkup security help scan" [
  ]

  # List all available scanners
  export extern "checkup security help list" [
  ]

  # Check which tools are installed
  export extern "checkup security help check" [
  ]

  # Cache management
  export extern "checkup security help cache" [
  ]

  # Show cache stats
  export extern "checkup security help cache info" [
  ]

  # Clear all cached results
  export extern "checkup security help cache clear" [
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "checkup security help help" [
  ]

  # Audit dependency advisories and duplicate versions
  export extern "checkup dep-health" [
    --json                    # Emit JSON instead of human-readable output
    --help(-h)                # Print help
    root?: path               # Workspace root (defaults to cwd)
  ]

  # Find dead code across the workspace via clippy
  export extern "checkup dead-code" [
    --json                    # Emit JSON instead of human-readable output
    --help(-h)                # Print help
    root?: path               # Workspace root (defaults to cwd)
  ]

  # Check git health across repos (dirty trees, stale worktrees, branches without PRs)
  export extern "checkup git-health" [
    --json                    # Emit JSON instead of human-readable output
    --help(-h)                # Print help
    root?: path               # Workspace root (defaults to cwd)
  ]

  # Scan TODO/FIXME comments and correlate with doob items
  export extern "checkup todo-drift" [
    --json                    # Emit JSON instead of human-readable output
    --help(-h)                # Print help
    root?: path               # Workspace root (defaults to cwd)
  ]

  # Enforce per-crate line coverage thresholds via cargo-llvm-cov
  export extern "checkup coverage-gate" [
    --threshold: string       # Minimum line coverage percentage (default: 80)
    --json                    # Emit JSON instead of human-readable output
    --help(-h)                # Print help
    root?: path               # Workspace root (defaults to cwd)
  ]

  # Run lintx (rustqual) code quality analysis; passes remaining args through
  export extern "checkup lint" [
    --help(-h)                # Print help
    path?: path               # Target path (defaults to cwd)
    ...args: string           # Extra args forwarded verbatim to lintx
  ]

  # Aggregate insightx session-facet reports
  export extern "checkup insights" [
    --json                    # Emit JSON instead of text summary
    --help(-h)                # Print help
    dir?: path                # Directory containing .facet.json files (defaults to cwd)
  ]

  # Parse and summarise Claude Code session-meta files (parsex)
  export extern "checkup sessions" [
    --help(-h)                # Print help
    ...args: string           # Extra args forwarded verbatim to parsex
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "checkup help" [
  ]

  # Scan test coverage across the workspace (default)
  export extern "checkup help scan" [
  ]

  # Analyze module structure
  export extern "checkup help analyze" [
  ]

  # Print low-coverage report
  export extern "checkup help report" [
  ]

  # Validate test counts
  export extern "checkup help validate" [
  ]

  # Check CI status across repos
  export extern "checkup help ci-status" [
  ]

  # Detect drift between Linear and GitHub issues
  export extern "checkup help linear-sync" [
  ]

  # Audit workspace for obfsck secret scan results
  export extern "checkup help obfsck-audit" [
  ]

  # Scan for migration schema health
  export extern "checkup help migration-health" [
  ]

  # Scan for hj→doob migration surface
  export extern "checkup help hj-migration" [
  ]

  # Validate plugin conformance
  export extern "checkup help plugin-conformance" [
  ]

  # Run security scanners
  export extern "checkup help security" [
  ]

  # Run security scanners against a target
  export extern "checkup help security scan" [
  ]

  # List all available scanners
  export extern "checkup help security list" [
  ]

  # Check which tools are installed
  export extern "checkup help security check" [
  ]

  # Cache management
  export extern "checkup help security cache" [
  ]

  # Show cache stats
  export extern "checkup help security cache info" [
  ]

  # Clear all cached results
  export extern "checkup help security cache clear" [
  ]

  # Audit dependency advisories and duplicate versions
  export extern "checkup help dep-health" [
  ]

  # Find dead code across the workspace via clippy
  export extern "checkup help dead-code" [
  ]

  # Check git health across repos (dirty trees, stale worktrees, branches without PRs)
  export extern "checkup help git-health" [
  ]

  # Scan TODO/FIXME comments and correlate with doob items
  export extern "checkup help todo-drift" [
  ]

  # Enforce per-crate line coverage thresholds via cargo-llvm-cov
  export extern "checkup help coverage-gate" [
  ]

  # Run lintx (rustqual) code quality analysis; passes remaining args through
  export extern "checkup help lint" [
  ]

  # Aggregate insightx session-facet reports
  export extern "checkup help insights" [
  ]

  # Parse and summarise Claude Code session-meta files (parsex)
  export extern "checkup help sessions" [
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "checkup help help" [
  ]

}

export use completions *
