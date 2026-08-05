module completions {

  # Rust-native development task graph and session manager
  export extern godmode [
    --json                    # Emit machine-readable JSON instead of human text
    --sarif                   # Emit SARIF v2.1.0 output (verify and review commands)
    --help(-h)                # Print help
    --version(-V)             # Print version
  ]

  # Print triage summary at session start
  export extern "godmode handon" [
    --compact                 # Emit a single-line summary instead of the full triage
    --json                    # Emit machine-readable JSON instead of human text
    --sarif                   # Emit SARIF v2.1.0 output (verify and review commands)
    --help(-h)                # Print help
  ]

  # Validate session state at session end
  export extern "godmode handoff" [
    --json                    # Emit machine-readable JSON instead of human text
    --sarif                   # Emit SARIF v2.1.0 output (verify and review commands)
    --help(-h)                # Print help
  ]

  # Session file management (pruning, etc.)
  export extern "godmode session" [
    --json                    # Emit machine-readable JSON instead of human text
    --sarif                   # Emit SARIF v2.1.0 output (verify and review commands)
    --help(-h)                # Print help
  ]

  # Delete session JSONL files older than N days
  export extern "godmode session prune" [
    --older-than: string      # Delete files older than this many days
    --dry-run                 # Print what would be deleted without removing anything
    --json                    # Emit machine-readable JSON instead of human text
    --sarif                   # Emit SARIF v2.1.0 output (verify and review commands)
    --help(-h)                # Print help
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "godmode session help" [
  ]

  # Delete session JSONL files older than N days
  export extern "godmode session help prune" [
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "godmode session help help" [
  ]

  # Task graph management
  export extern "godmode task" [
    --json                    # Emit machine-readable JSON instead of human text
    --sarif                   # Emit SARIF v2.1.0 output (verify and review commands)
    --help(-h)                # Print help
  ]

  # List all tasks with status
  export extern "godmode task list" [
    --priority: string        # Filter to tasks with a specific priority (high, normal, low)
    --filter: string          # Case-insensitive keyword filter on title, crate_name, and notes
    --json                    # Emit machine-readable JSON instead of human text
    --sarif                   # Emit SARIF v2.1.0 output (verify and review commands)
    --help(-h)                # Print help
  ]

  # Add a new task. Omit ID to auto-assign the next available "tN" slot
  export extern "godmode task add" [
    --id: string              # Task ID (e.g. t5). Auto-assigned if omitted
    --depends-on: string
    --crate-name: string
    --json                    # Emit machine-readable JSON instead of human text
    --sarif                   # Emit SARIF v2.1.0 output (verify and review commands)
    --help(-h)                # Print help
    title: string             # Task title (required)
  ]

  # Mark a task as running
  export extern "godmode task start" [
    --json                    # Emit machine-readable JSON instead of human text
    --sarif                   # Emit SARIF v2.1.0 output (verify and review commands)
    --help(-h)                # Print help
    id: string
  ]

  # Mark a running task as done
  export extern "godmode task done" [
    --commit: string
    --notes: string
    --json                    # Emit machine-readable JSON instead of human text
    --sarif                   # Emit SARIF v2.1.0 output (verify and review commands)
    --help(-h)                # Print help
    id: string
  ]

  # Mark a task as blocked
  export extern "godmode task block" [
    --json                    # Emit machine-readable JSON instead of human text
    --sarif                   # Emit SARIF v2.1.0 output (verify and review commands)
    --help(-h)                # Print help
    id: string
    reason: string
  ]

  # Unblock a blocked task (resets to pending)
  export extern "godmode task unblock" [
    --json                    # Emit machine-readable JSON instead of human text
    --sarif                   # Emit SARIF v2.1.0 output (verify and review commands)
    --help(-h)                # Print help
    id: string
  ]

  # Remove a task
  export extern "godmode task remove" [
    --json                    # Emit machine-readable JSON instead of human text
    --sarif                   # Emit SARIF v2.1.0 output (verify and review commands)
    --help(-h)                # Print help
    id: string
  ]

  # Clear tasks from the graph
  export extern "godmode task clear" [
    --done                    # Remove only completed (done) tasks
    --all                     # Remove all tasks
    --json                    # Emit machine-readable JSON instead of human text
    --sarif                   # Emit SARIF v2.1.0 output (verify and review commands)
    --help(-h)                # Print help
  ]

  # Show the next runnable task(s)
  export extern "godmode task next" [
    --priority: string        # Filter to runnable tasks with a specific priority (high, normal, low)
    --json                    # Emit machine-readable JSON instead of human text
    --sarif                   # Emit SARIF v2.1.0 output (verify and review commands)
    --help(-h)                # Print help
  ]

  # Run the shell command attached to a task's `run:` field
  export extern "godmode task run" [
    --auto-done               # Automatically mark the task done if the command exits 0
    --json                    # Emit machine-readable JSON instead of human text
    --sarif                   # Emit SARIF v2.1.0 output (verify and review commands)
    --help(-h)                # Print help
    id: string
  ]

  # Pull pending todos/issues into the task graph
  export extern "godmode task pull" [
    --project: string         # Doob project name (defaults to Cargo.toml package name)
    --github                  # Pull from GitHub Issues instead of doob
    --repo: string            # GitHub repo (owner/repo) — defaults to current repo
    --label: string           # Filter by label (GitHub only)
    --json                    # Emit machine-readable JSON instead of human text
    --sarif                   # Emit SARIF v2.1.0 output (verify and review commands)
    --help(-h)                # Print help
  ]

  # Mark completed tasks as done in doob (uses `doob:` UUID in notes field)
  export extern "godmode task push-done" [
    --json                    # Emit machine-readable JSON instead of human text
    --sarif                   # Emit SARIF v2.1.0 output (verify and review commands)
    --help(-h)                # Print help
  ]

  # Reset all blocked tasks to pending in one operation
  export extern "godmode task unblock-all" [
    --json                    # Emit machine-readable JSON instead of human text
    --sarif                   # Emit SARIF v2.1.0 output (verify and review commands)
    --help(-h)                # Print help
  ]

  # Apply a template to the task graph
  export extern "godmode task apply" [
    --var: string             # Variable substitutions in key=value format
    --json                    # Emit machine-readable JSON instead of human text
    --sarif                   # Emit SARIF v2.1.0 output (verify and review commands)
    --help(-h)                # Print help
    name: string              # Template name (looks in templates/ then ~/.config/godmode/templates/)
  ]

  # List available templates
  export extern "godmode task list-templates" [
    --json                    # Emit machine-readable JSON instead of human text
    --sarif                   # Emit SARIF v2.1.0 output (verify and review commands)
    --help(-h)                # Print help
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "godmode task help" [
  ]

  # List all tasks with status
  export extern "godmode task help list" [
  ]

  # Add a new task. Omit ID to auto-assign the next available "tN" slot
  export extern "godmode task help add" [
  ]

  # Mark a task as running
  export extern "godmode task help start" [
  ]

  # Mark a running task as done
  export extern "godmode task help done" [
  ]

  # Mark a task as blocked
  export extern "godmode task help block" [
  ]

  # Unblock a blocked task (resets to pending)
  export extern "godmode task help unblock" [
  ]

  # Remove a task
  export extern "godmode task help remove" [
  ]

  # Clear tasks from the graph
  export extern "godmode task help clear" [
  ]

  # Show the next runnable task(s)
  export extern "godmode task help next" [
  ]

  # Run the shell command attached to a task's `run:` field
  export extern "godmode task help run" [
  ]

  # Pull pending todos/issues into the task graph
  export extern "godmode task help pull" [
  ]

  # Mark completed tasks as done in doob (uses `doob:` UUID in notes field)
  export extern "godmode task help push-done" [
  ]

  # Reset all blocked tasks to pending in one operation
  export extern "godmode task help unblock-all" [
  ]

  # Apply a template to the task graph
  export extern "godmode task help apply" [
  ]

  # List available templates
  export extern "godmode task help list-templates" [
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "godmode task help help" [
  ]

  # Plan operations
  export extern "godmode plan" [
    --json                    # Emit machine-readable JSON instead of human text
    --sarif                   # Emit SARIF v2.1.0 output (verify and review commands)
    --help(-h)                # Print help
  ]

  # Parse a plan markdown file and populate the task graph
  export extern "godmode plan ingest" [
    --json                    # Emit machine-readable JSON instead of human text
    --sarif                   # Emit SARIF v2.1.0 output (verify and review commands)
    --help(-h)                # Print help
    path: string              # Path to the plan markdown file
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "godmode plan help" [
  ]

  # Parse a plan markdown file and populate the task graph
  export extern "godmode plan help ingest" [
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "godmode plan help help" [
  ]

  # Show independent chains ready for parallel agent dispatch (JSON)
  export extern "godmode dispatch" [
    --max: string             # Maximum concurrent agents
    --critical-path           # Show the critical path instead of independent chains
    --json                    # Emit machine-readable JSON instead of human text
    --sarif                   # Emit SARIF v2.1.0 output (verify and review commands)
    --help(-h)                # Print help
  ]

  # Emit full session context for hooks and subagents
  export extern "godmode context" [
    --json                    # Emit machine-readable JSON instead of human text
    --sarif                   # Emit SARIF v2.1.0 output (verify and review commands)
    --help(-h)                # Print help
  ]

  # Show graph counts and next runnable task(s) — fast mid-session state check
  export extern "godmode status" [
    --compact                 # Emit the old single-line summary instead of the sectioned view
    --json                    # Emit machine-readable JSON instead of human text
    --sarif                   # Emit SARIF v2.1.0 output (verify and review commands)
    --help(-h)                # Print help
  ]

  # Agent operations: list installed agents, generate index, or dispatch a plan
  export extern "godmode agent" [
    --json                    # Emit machine-readable JSON instead of human text
    --sarif                   # Emit SARIF v2.1.0 output (verify and review commands)
    --help(-h)                # Print help
  ]

  # List available agents (table or JSON)
  export extern "godmode agent list" [
    --filter: string          # Filter by name or description keyword (case-insensitive)
    --json                    # Emit machine-readable JSON instead of human text
    --sarif                   # Emit SARIF v2.1.0 output (verify and review commands)
    --help(-h)                # Print help
  ]

  # Regenerate agents/INDEX.md
  export extern "godmode agent index" [
    --json                    # Emit machine-readable JSON instead of human text
    --sarif                   # Emit SARIF v2.1.0 output (verify and review commands)
    --help(-h)                # Print help
  ]

  # Ingest a plan file and emit an orca-strait dispatch payload
  export extern "godmode agent dispatch" [
    --max: string             # Maximum concurrent agent chains
    --json                    # Emit machine-readable JSON instead of human text
    --sarif                   # Emit SARIF v2.1.0 output (verify and review commands)
    --help(-h)                # Print help
    path: string              # Path to the plan markdown file
  ]

  # Generate .md from agent YAML definitions
  export extern "godmode agent generate" [
    --all                     # Generate .md for all agents/*.yaml files
    --json                    # Emit machine-readable JSON instead of human text
    --sarif                   # Emit SARIF v2.1.0 output (verify and review commands)
    --help(-h)                # Print help
    name?: string             # Name of a single agent YAML to generate (stem, no extension). Omit for --all
  ]

  # Migrate agents/*.md frontmatter to agents/*.yaml stubs
  export extern "godmode agent migrate" [
    --all                     # Migrate all agents/*.md files
    --json                    # Emit machine-readable JSON instead of human text
    --sarif                   # Emit SARIF v2.1.0 output (verify and review commands)
    --help(-h)                # Print help
    name?: string             # Name of a single agent .md to migrate (stem, no extension). Omit for --all
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "godmode agent help" [
  ]

  # List available agents (table or JSON)
  export extern "godmode agent help list" [
  ]

  # Regenerate agents/INDEX.md
  export extern "godmode agent help index" [
  ]

  # Ingest a plan file and emit an orca-strait dispatch payload
  export extern "godmode agent help dispatch" [
  ]

  # Generate .md from agent YAML definitions
  export extern "godmode agent help generate" [
  ]

  # Migrate agents/*.md frontmatter to agents/*.yaml stubs
  export extern "godmode agent help migrate" [
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "godmode agent help help" [
  ]

  # Run verification gate: nextest + clippy + fmt + non-empty git log
  export extern "godmode verify" [
    --crate-name: string      # Scope to a single crate instead of --workspace
    --json                    # Emit machine-readable JSON instead of human text
    --sarif                   # Emit SARIF v2.1.0 output (verify and review commands)
    --help(-h)                # Print help
  ]

  # Wave state management for parallel agent sessions
  export extern "godmode wave" [
    --json                    # Emit machine-readable JSON instead of human text
    --sarif                   # Emit SARIF v2.1.0 output (verify and review commands)
    --help(-h)                # Print help
  ]

  # Initialise a new wave state file
  export extern "godmode wave init" [
    --wave: string
    --agents: string          # Comma-separated agent/crate names
    --json                    # Emit machine-readable JSON instead of human text
    --sarif                   # Emit SARIF v2.1.0 output (verify and review commands)
    --help(-h)                # Print help
  ]

  # Show current wave status
  export extern "godmode wave status" [
    --json                    # Emit machine-readable JSON instead of human text
    --sarif                   # Emit SARIF v2.1.0 output (verify and review commands)
    --help(-h)                # Print help
  ]

  # Mark an agent slot as done
  export extern "godmode wave done" [
    --commits: string
    --json                    # Emit machine-readable JSON instead of human text
    --sarif                   # Emit SARIF v2.1.0 output (verify and review commands)
    --help(-h)                # Print help
    agent: string
  ]

  # Mark an agent slot as blocked
  export extern "godmode wave block" [
    --json                    # Emit machine-readable JSON instead of human text
    --sarif                   # Emit SARIF v2.1.0 output (verify and review commands)
    --help(-h)                # Print help
    agent: string
  ]

  # Exit 1 if any slot is still pending
  export extern "godmode wave check" [
    --json                    # Emit machine-readable JSON instead of human text
    --sarif                   # Emit SARIF v2.1.0 output (verify and review commands)
    --help(-h)                # Print help
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "godmode wave help" [
  ]

  # Initialise a new wave state file
  export extern "godmode wave help init" [
  ]

  # Show current wave status
  export extern "godmode wave help status" [
  ]

  # Mark an agent slot as done
  export extern "godmode wave help done" [
  ]

  # Mark an agent slot as blocked
  export extern "godmode wave help block" [
  ]

  # Exit 1 if any slot is still pending
  export extern "godmode wave help check" [
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "godmode wave help help" [
  ]

  # Git worktree lifecycle management
  export extern "godmode worktree" [
    --json                    # Emit machine-readable JSON instead of human text
    --sarif                   # Emit SARIF v2.1.0 output (verify and review commands)
    --help(-h)                # Print help
  ]

  # Create a worktree for a branch (optionally linked to a GH issue)
  export extern "godmode worktree add" [
    --issue: string
    --json                    # Emit machine-readable JSON instead of human text
    --sarif                   # Emit SARIF v2.1.0 output (verify and review commands)
    --help(-h)                # Print help
    branch: string
  ]

  # Remove a worktree after verifying its branch is merged into main
  export extern "godmode worktree remove" [
    --json                    # Emit machine-readable JSON instead of human text
    --sarif                   # Emit SARIF v2.1.0 output (verify and review commands)
    --help(-h)                # Print help
    branch: string
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "godmode worktree help" [
  ]

  # Create a worktree for a branch (optionally linked to a GH issue)
  export extern "godmode worktree help add" [
  ]

  # Remove a worktree after verifying its branch is merged into main
  export extern "godmode worktree help remove" [
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "godmode worktree help help" [
  ]

  # CI failure triage
  export extern "godmode ci" [
    --json                    # Emit machine-readable JSON instead of human text
    --sarif                   # Emit SARIF v2.1.0 output (verify and review commands)
    --help(-h)                # Print help
  ]

  # Fetch latest failed CI run and classify root cause
  export extern "godmode ci triage" [
    --run-id: string
    --json                    # Emit machine-readable JSON instead of human text
    --sarif                   # Emit SARIF v2.1.0 output (verify and review commands)
    --help(-h)                # Print help
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "godmode ci help" [
  ]

  # Fetch latest failed CI run and classify root cause
  export extern "godmode ci help triage" [
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "godmode ci help help" [
  ]

  # GitHub issue operations
  export extern "godmode issue" [
    --json                    # Emit machine-readable JSON instead of human text
    --sarif                   # Emit SARIF v2.1.0 output (verify and review commands)
    --help(-h)                # Print help
  ]

  # List open GitHub issues
  export extern "godmode issue list" [
    --repo: string
    --label: string
    --json                    # Emit machine-readable JSON instead of human text
    --sarif                   # Emit SARIF v2.1.0 output (verify and review commands)
    --help(-h)                # Print help
  ]

  # Close a GitHub issue with a commit reference
  export extern "godmode issue close" [
    --repo: string
    --commit: string
    --json                    # Emit machine-readable JSON instead of human text
    --sarif                   # Emit SARIF v2.1.0 output (verify and review commands)
    --help(-h)                # Print help
    number: string
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "godmode issue help" [
  ]

  # List open GitHub issues
  export extern "godmode issue help list" [
  ]

  # Close a GitHub issue with a commit reference
  export extern "godmode issue help close" [
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "godmode issue help help" [
  ]

  # Interactive or file-driven task graph construction
  export extern "godmode graph" [
    --json                    # Emit machine-readable JSON instead of human text
    --sarif                   # Emit SARIF v2.1.0 output (verify and review commands)
    --help(-h)                # Print help
  ]

  # Build a task graph interactively or from a template file
  export extern "godmode graph build" [
    --input: string           # Path to a template YAML file (non-interactive mode)
    --var: string             # Variable substitutions in key=value format (used with --input)
    --json                    # Emit machine-readable JSON instead of human text
    --sarif                   # Emit SARIF v2.1.0 output (verify and review commands)
    --help(-h)                # Print help
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "godmode graph help" [
  ]

  # Build a task graph interactively or from a template file
  export extern "godmode graph help build" [
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "godmode graph help help" [
  ]

  # Hook observability: list, log, and test hooks
  export extern "godmode hook" [
    --json                    # Emit machine-readable JSON instead of human text
    --sarif                   # Emit SARIF v2.1.0 output (verify and review commands)
    --help(-h)                # Print help
  ]

  # List all hooks registered in hooks/hooks.json
  export extern "godmode hook list" [
    --json                    # Emit machine-readable JSON instead of human text
    --sarif                   # Emit SARIF v2.1.0 output (verify and review commands)
    --help(-h)                # Print help
  ]

  # Print the last N lines from .ctx/godmode/traces/hooks.log
  export extern "godmode hook log" [
    --tail: string            # Number of lines to show (default 20)
    --json                    # Emit machine-readable JSON instead of human text
    --sarif                   # Emit SARIF v2.1.0 output (verify and review commands)
    --help(-h)                # Print help
  ]

  # Run a hook script with synthetic stdin JSON and show exit code + stderr
  export extern "godmode hook test" [
    --json                    # Emit machine-readable JSON instead of human text
    --sarif                   # Emit SARIF v2.1.0 output (verify and review commands)
    --help(-h)                # Print help
    script: string            # Path to the hook script to test
  ]

  # Run all numbered migration scripts in hooks/migrations/
  export extern "godmode hook migrate" [
    --json                    # Emit machine-readable JSON instead of human text
    --sarif                   # Emit SARIF v2.1.0 output (verify and review commands)
    --help(-h)                # Print help
  ]

  # Run a built-in hook by name (Rust implementation)
  export extern "godmode hook run" [
    --json                    # Emit machine-readable JSON instead of human text
    --sarif                   # Emit SARIF v2.1.0 output (verify and review commands)
    --help(-h)                # Print help
    name: string              # Hook name: stop-guard, auto-block, pre-commit, quality-gate
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "godmode hook help" [
  ]

  # List all hooks registered in hooks/hooks.json
  export extern "godmode hook help list" [
  ]

  # Print the last N lines from .ctx/godmode/traces/hooks.log
  export extern "godmode hook help log" [
  ]

  # Run a hook script with synthetic stdin JSON and show exit code + stderr
  export extern "godmode hook help test" [
  ]

  # Run all numbered migration scripts in hooks/migrations/
  export extern "godmode hook help migrate" [
  ]

  # Run a built-in hook by name (Rust implementation)
  export extern "godmode hook help run" [
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "godmode hook help help" [
  ]

  # Skill registry management
  export extern "godmode skill" [
    --json                    # Emit machine-readable JSON instead of human text
    --sarif                   # Emit SARIF v2.1.0 output (verify and review commands)
    --help(-h)                # Print help
  ]

  # List all registered skills
  export extern "godmode skill list" [
    --json                    # Emit machine-readable JSON instead of human text
    --sarif                   # Emit SARIF v2.1.0 output (verify and review commands)
    --help(-h)                # Print help
  ]

  # Install a skill from a local directory path
  export extern "godmode skill install" [
    --json                    # Emit machine-readable JSON instead of human text
    --sarif                   # Emit SARIF v2.1.0 output (verify and review commands)
    --help(-h)                # Print help
    path: string              # Absolute path to the skill directory
  ]

  # Remove a skill from the registry by name
  export extern "godmode skill uninstall" [
    --json                    # Emit machine-readable JSON instead of human text
    --sarif                   # Emit SARIF v2.1.0 output (verify and review commands)
    --help(-h)                # Print help
    name: string              # Skill name to remove
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "godmode skill help" [
  ]

  # List all registered skills
  export extern "godmode skill help list" [
  ]

  # Install a skill from a local directory path
  export extern "godmode skill help install" [
  ]

  # Remove a skill from the registry by name
  export extern "godmode skill help uninstall" [
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "godmode skill help help" [
  ]

  # Plugin conformance and consistency auditing
  export extern "godmode review" [
    --json                    # Emit machine-readable JSON instead of human text
    --sarif                   # Emit SARIF v2.1.0 output (verify and review commands)
    --help(-h)                # Print help
  ]

  # Run all conformance checks (skills + agents + plugin.json)
  export extern "godmode review self" [
    --json                    # Emit machine-readable JSON instead of human text
    --sarif                   # Emit SARIF v2.1.0 output (verify and review commands)
    --help(-h)                # Print help
  ]

  # Check skill dirs for SKILL.md, frontmatter, and link integrity
  export extern "godmode review skills" [
    --json                    # Emit machine-readable JSON instead of human text
    --sarif                   # Emit SARIF v2.1.0 output (verify and review commands)
    --help(-h)                # Print help
  ]

  # Check agent frontmatter completeness
  export extern "godmode review agents" [
    --json                    # Emit machine-readable JSON instead of human text
    --sarif                   # Emit SARIF v2.1.0 output (verify and review commands)
    --help(-h)                # Print help
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "godmode review help" [
  ]

  # Run all conformance checks (skills + agents + plugin.json)
  export extern "godmode review help self" [
  ]

  # Check skill dirs for SKILL.md, frontmatter, and link integrity
  export extern "godmode review help skills" [
  ]

  # Check agent frontmatter completeness
  export extern "godmode review help agents" [
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "godmode review help help" [
  ]

  # Plugin release: bump version, tag, push
  export extern "godmode release" [
    --json                    # Emit machine-readable JSON instead of human text
    --sarif                   # Emit SARIF v2.1.0 output (verify and review commands)
    --help(-h)                # Print help
  ]

  # Show current plugin version
  export extern "godmode release current" [
    --json                    # Emit machine-readable JSON instead of human text
    --sarif                   # Emit SARIF v2.1.0 output (verify and review commands)
    --help(-h)                # Print help
  ]

  # Increment patch version in all files listed in .version-bump.json
  export extern "godmode release bump" [
    --version: string         # Set an explicit version instead of auto-incrementing
    --json                    # Emit machine-readable JSON instead of human text
    --sarif                   # Emit SARIF v2.1.0 output (verify and review commands)
    --help(-h)                # Print help
  ]

  # Create annotated git tag for the current version
  export extern "godmode release tag" [
    --json                    # Emit machine-readable JSON instead of human text
    --sarif                   # Emit SARIF v2.1.0 output (verify and review commands)
    --help(-h)                # Print help
  ]

  # Push current branch and version tag to origin
  export extern "godmode release push" [
    --json                    # Emit machine-readable JSON instead of human text
    --sarif                   # Emit SARIF v2.1.0 output (verify and review commands)
    --help(-h)                # Print help
  ]

  # Generate and prepend a changelog entry from commits since last tag
  export extern "godmode release changelog" [
    --json                    # Emit machine-readable JSON instead of human text
    --sarif                   # Emit SARIF v2.1.0 output (verify and review commands)
    --help(-h)                # Print help
  ]

  # Cross-check plugin.json, Cargo.toml, and git tag versions
  export extern "godmode release validate" [
    --json                    # Emit machine-readable JSON instead of human text
    --sarif                   # Emit SARIF v2.1.0 output (verify and review commands)
    --help(-h)                # Print help
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "godmode release help" [
  ]

  # Show current plugin version
  export extern "godmode release help current" [
  ]

  # Increment patch version in all files listed in .version-bump.json
  export extern "godmode release help bump" [
  ]

  # Create annotated git tag for the current version
  export extern "godmode release help tag" [
  ]

  # Push current branch and version tag to origin
  export extern "godmode release help push" [
  ]

  # Generate and prepend a changelog entry from commits since last tag
  export extern "godmode release help changelog" [
  ]

  # Cross-check plugin.json, Cargo.toml, and git tag versions
  export extern "godmode release help validate" [
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "godmode release help help" [
  ]

  # Workflow DAG execution per agent
  export extern "godmode workflow" [
    --json                    # Emit machine-readable JSON instead of human text
    --sarif                   # Emit SARIF v2.1.0 output (verify and review commands)
    --help(-h)                # Print help
  ]

  # Execute a workflow DAG for an agent
  export extern "godmode workflow run" [
    --json                    # Emit machine-readable JSON instead of human text
    --sarif                   # Emit SARIF v2.1.0 output (verify and review commands)
    --help(-h)                # Print help
    agent: string             # Agent name (used to locate the workflow in agents/<agent>.yaml)
    workflow: string          # Workflow name (must match a workflows[] entry in the agent YAML)
  ]

  # List workflows for an agent (or all agents)
  export extern "godmode workflow list" [
    --agent: string           # Filter to a specific agent name
    --json                    # Emit machine-readable JSON instead of human text
    --sarif                   # Emit SARIF v2.1.0 output (verify and review commands)
    --help(-h)                # Print help
  ]

  # Show current state of a named workflow from .ctx/workflow-<name>.json
  export extern "godmode workflow status" [
    --json                    # Emit machine-readable JSON instead of human text
    --sarif                   # Emit SARIF v2.1.0 output (verify and review commands)
    --help(-h)                # Print help
    name: string              # Workflow name
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "godmode workflow help" [
  ]

  # Execute a workflow DAG for an agent
  export extern "godmode workflow help run" [
  ]

  # List workflows for an agent (or all agents)
  export extern "godmode workflow help list" [
  ]

  # Show current state of a named workflow from .ctx/workflow-<name>.json
  export extern "godmode workflow help status" [
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "godmode workflow help help" [
  ]

  # Render the task graph as DOT or SVG
  export extern "godmode visualize-graph" [
    --format: string          # Output format: dot or svg
    --out: string             # Write output to this file instead of stdout
    --json                    # Emit machine-readable JSON instead of human text
    --sarif                   # Emit SARIF v2.1.0 output (verify and review commands)
    --help(-h)                # Print help
  ]

  # Memory banking: persistent source-backed project context
  export extern "godmode memory-banking" [
    --json                    # Emit machine-readable JSON instead of human text
    --sarif                   # Emit SARIF v2.1.0 output (verify and review commands)
    --help(-h)                # Print help
  ]

  # Print memory-bank contents for context injection (SessionStart hook)
  export extern "godmode memory-banking inject" [
    --json                    # Emit machine-readable JSON instead of human text
    --sarif                   # Emit SARIF v2.1.0 output (verify and review commands)
    --help(-h)                # Print help
  ]

  # Print update reminder if session had commits (Stop hook)
  export extern "godmode memory-banking remind" [
    --json                    # Emit machine-readable JSON instead of human text
    --sarif                   # Emit SARIF v2.1.0 output (verify and review commands)
    --help(-h)                # Print help
  ]

  # Create .ctx/memory-banking/ with empty template files
  export extern "godmode memory-banking init" [
    --json                    # Emit machine-readable JSON instead of human text
    --sarif                   # Emit SARIF v2.1.0 output (verify and review commands)
    --help(-h)                # Print help
  ]

  # Show memory-banking status and staleness
  export extern "godmode memory-banking status" [
    --json                    # Emit machine-readable JSON instead of human text
    --sarif                   # Emit SARIF v2.1.0 output (verify and review commands)
    --help(-h)                # Print help
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "godmode memory-banking help" [
  ]

  # Print memory-bank contents for context injection (SessionStart hook)
  export extern "godmode memory-banking help inject" [
  ]

  # Print update reminder if session had commits (Stop hook)
  export extern "godmode memory-banking help remind" [
  ]

  # Create .ctx/memory-banking/ with empty template files
  export extern "godmode memory-banking help init" [
  ]

  # Show memory-banking status and staleness
  export extern "godmode memory-banking help status" [
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "godmode memory-banking help help" [
  ]

  # Insight capture and retrieval (append-only JSONL)
  export extern "godmode insight" [
    --json                    # Emit machine-readable JSON instead of human text
    --sarif                   # Emit SARIF v2.1.0 output (verify and review commands)
    --help(-h)                # Print help
  ]

  # Record a new insight
  export extern "godmode insight add" [
    --body: string            # Insight body text
    --tags: string            # Optional tags (comma-separated)
    --json                    # Emit machine-readable JSON instead of human text
    --sarif                   # Emit SARIF v2.1.0 output (verify and review commands)
    --help(-h)                # Print help
    title: string             # Insight title (short heading)
  ]

  # List recorded insights
  export extern "godmode insight list" [
    --date: string            # Filter to a specific date (YYYY-MM-DD). Defaults to today
    --json                    # Emit machine-readable JSON instead of human text
    --sarif                   # Emit SARIF v2.1.0 output (verify and review commands)
    --help(-h)                # Print help
  ]

  # Render insights to `.ctx/insights-YYYY-MM-DD.md`
  export extern "godmode insight render" [
    --date: string            # Date to render (YYYY-MM-DD). Defaults to today
    --json                    # Emit machine-readable JSON instead of human text
    --sarif                   # Emit SARIF v2.1.0 output (verify and review commands)
    --help(-h)                # Print help
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "godmode insight help" [
  ]

  # Record a new insight
  export extern "godmode insight help add" [
  ]

  # List recorded insights
  export extern "godmode insight help list" [
  ]

  # Render insights to `.ctx/insights-YYYY-MM-DD.md`
  export extern "godmode insight help render" [
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "godmode insight help help" [
  ]

  # Pipeline execution: list, start, advance, and status multi-step pipelines
  export extern "godmode pipeline" [
    --json                    # Emit machine-readable JSON instead of human text
    --sarif                   # Emit SARIF v2.1.0 output (verify and review commands)
    --help(-h)                # Print help
  ]

  # List all available pipelines with name and description
  export extern "godmode pipeline list" [
    --json                    # Emit machine-readable JSON instead of human text
    --sarif                   # Emit SARIF v2.1.0 output (verify and review commands)
    --help(-h)                # Print help
  ]

  # Show steps for a pipeline, marking current position if active
  export extern "godmode pipeline show" [
    --json                    # Emit machine-readable JSON instead of human text
    --sarif                   # Emit SARIF v2.1.0 output (verify and review commands)
    --help(-h)                # Print help
    name: string              # Pipeline name (stem of the YAML file in pipelines/)
  ]

  # Start a pipeline, optionally from a named entry-point skill
  export extern "godmode pipeline start" [
    --from: string            # Entry-point skill to start from (must be a valid entry_point)
    --json                    # Emit machine-readable JSON instead of human text
    --sarif                   # Emit SARIF v2.1.0 output (verify and review commands)
    --help(-h)                # Print help
    name: string              # Pipeline name to activate
  ]

  # Mark current step done and advance to the next step
  export extern "godmode pipeline next" [
    --json                    # Emit machine-readable JSON instead of human text
    --sarif                   # Emit SARIF v2.1.0 output (verify and review commands)
    --help(-h)                # Print help
  ]

  # Skip current step and advance without marking it done
  export extern "godmode pipeline skip" [
    --json                    # Emit machine-readable JSON instead of human text
    --sarif                   # Emit SARIF v2.1.0 output (verify and review commands)
    --help(-h)                # Print help
  ]

  # Deactivate the current pipeline (clear saved state)
  export extern "godmode pipeline stop" [
    --json                    # Emit machine-readable JSON instead of human text
    --sarif                   # Emit SARIF v2.1.0 output (verify and review commands)
    --help(-h)                # Print help
  ]

  # Show the active pipeline name, current step, and progress
  export extern "godmode pipeline status" [
    --json                    # Emit machine-readable JSON instead of human text
    --sarif                   # Emit SARIF v2.1.0 output (verify and review commands)
    --help(-h)                # Print help
  ]

  # Run a pipeline headlessly — walk task graph, execute run: fields
  export extern "godmode pipeline run" [
    --from: string            # Skill to start from (must be a valid entry_point)
    --fail-fast               # Stop on first task failure
    --json                    # Emit machine-readable JSON instead of human text
    --sarif                   # Emit SARIF v2.1.0 output (verify and review commands)
    --help(-h)                # Print help
    name: string              # Pipeline name to run
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "godmode pipeline help" [
  ]

  # List all available pipelines with name and description
  export extern "godmode pipeline help list" [
  ]

  # Show steps for a pipeline, marking current position if active
  export extern "godmode pipeline help show" [
  ]

  # Start a pipeline, optionally from a named entry-point skill
  export extern "godmode pipeline help start" [
  ]

  # Mark current step done and advance to the next step
  export extern "godmode pipeline help next" [
  ]

  # Skip current step and advance without marking it done
  export extern "godmode pipeline help skip" [
  ]

  # Deactivate the current pipeline (clear saved state)
  export extern "godmode pipeline help stop" [
  ]

  # Show the active pipeline name, current step, and progress
  export extern "godmode pipeline help status" [
  ]

  # Run a pipeline headlessly — walk task graph, execute run: fields
  export extern "godmode pipeline help run" [
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "godmode pipeline help help" [
  ]

  # Governance policy management: resolve, check, list, audit
  export extern "godmode policy" [
    --json                    # Emit machine-readable JSON instead of human text
    --sarif                   # Emit SARIF v2.1.0 output (verify and review commands)
    --help(-h)                # Print help
  ]

  # Resolve the effective policy for an agent
  export extern "godmode policy resolve" [
    --level: string           # Governance level override (open/standard/strict/locked)
    --json                    # Emit machine-readable JSON instead of human text
    --sarif                   # Emit SARIF v2.1.0 output (verify and review commands)
    --help(-h)                # Print help
    agent: string             # Agent name (matches agents/cfg/<name>.cfg.yaml)
  ]

  # Check if a tool call is allowed by an agent's policy
  export extern "godmode policy check" [
    --input: string           # Content to check against blocked patterns
    --level: string           # Governance level override
    --json                    # Emit machine-readable JSON instead of human text
    --sarif                   # Emit SARIF v2.1.0 output (verify and review commands)
    --help(-h)                # Print help
    agent: string             # Agent name
    tool: string              # Tool name to check (Read, Write, Edit, Bash, Glob, Grep, Agent)
  ]

  # List all available policies (default, categories, levels)
  export extern "godmode policy list" [
    --json                    # Emit machine-readable JSON instead of human text
    --sarif                   # Emit SARIF v2.1.0 output (verify and review commands)
    --help(-h)                # Print help
  ]

  # Show governance audit trail
  export extern "godmode policy audit" [
    --date: string            # Filter to a specific date (YYYY-MM-DD). Defaults to today
    --json                    # Emit machine-readable JSON instead of human text
    --sarif                   # Emit SARIF v2.1.0 output (verify and review commands)
    --help(-h)                # Print help
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "godmode policy help" [
  ]

  # Resolve the effective policy for an agent
  export extern "godmode policy help resolve" [
  ]

  # Check if a tool call is allowed by an agent's policy
  export extern "godmode policy help check" [
  ]

  # List all available policies (default, categories, levels)
  export extern "godmode policy help list" [
  ]

  # Show governance audit trail
  export extern "godmode policy help audit" [
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "godmode policy help help" [
  ]

  # Pin the session to a specific repo root path
  export extern "godmode pin" [
    --json                    # Emit machine-readable JSON instead of human text
    --sarif                   # Emit SARIF v2.1.0 output (verify and review commands)
    --help(-h)                # Print help
    path?: string             # Path to pin (defaults to current directory)
  ]

  # Remove the pinned root from the session
  export extern "godmode unpin" [
    --json                    # Emit machine-readable JSON instead of human text
    --sarif                   # Emit SARIF v2.1.0 output (verify and review commands)
    --help(-h)                # Print help
  ]

  # First-time setup: create global config and project state dirs
  export extern "godmode init" [
    --json                    # Emit machine-readable JSON instead of human text
    --sarif                   # Emit SARIF v2.1.0 output (verify and review commands)
    --help(-h)                # Print help
  ]

  # Validate environment: required tools, 1Password auth, worktrees
  export extern "godmode doctor" [
    --json                    # Emit machine-readable JSON instead of human text
    --sarif                   # Emit SARIF v2.1.0 output (verify and review commands)
    --help(-h)                # Print help
  ]

  # Generate a test module stub for a crate and testing dimension
  export extern "godmode scaffold" [
    --json                    # Emit machine-readable JSON instead of human text
    --sarif                   # Emit SARIF v2.1.0 output (verify and review commands)
    --help(-h)                # Print help
    crate_name: string        # Crate name (e.g. godmode-core)
    dimension: string         # Testing dimension: unit, property, fuzz, conformance, integration, regression
  ]

  # Check whether a Rust source file has associated tests
  export extern "godmode test-check" [
    --json                    # Emit machine-readable JSON instead of human text
    --sarif                   # Emit SARIF v2.1.0 output (verify and review commands)
    --help(-h)                # Print help
    path: string              # Path to the .rs file to check
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "godmode help" [
  ]

  # Print triage summary at session start
  export extern "godmode help handon" [
  ]

  # Validate session state at session end
  export extern "godmode help handoff" [
  ]

  # Session file management (pruning, etc.)
  export extern "godmode help session" [
  ]

  # Delete session JSONL files older than N days
  export extern "godmode help session prune" [
  ]

  # Task graph management
  export extern "godmode help task" [
  ]

  # List all tasks with status
  export extern "godmode help task list" [
  ]

  # Add a new task. Omit ID to auto-assign the next available "tN" slot
  export extern "godmode help task add" [
  ]

  # Mark a task as running
  export extern "godmode help task start" [
  ]

  # Mark a running task as done
  export extern "godmode help task done" [
  ]

  # Mark a task as blocked
  export extern "godmode help task block" [
  ]

  # Unblock a blocked task (resets to pending)
  export extern "godmode help task unblock" [
  ]

  # Remove a task
  export extern "godmode help task remove" [
  ]

  # Clear tasks from the graph
  export extern "godmode help task clear" [
  ]

  # Show the next runnable task(s)
  export extern "godmode help task next" [
  ]

  # Run the shell command attached to a task's `run:` field
  export extern "godmode help task run" [
  ]

  # Pull pending todos/issues into the task graph
  export extern "godmode help task pull" [
  ]

  # Mark completed tasks as done in doob (uses `doob:` UUID in notes field)
  export extern "godmode help task push-done" [
  ]

  # Reset all blocked tasks to pending in one operation
  export extern "godmode help task unblock-all" [
  ]

  # Apply a template to the task graph
  export extern "godmode help task apply" [
  ]

  # List available templates
  export extern "godmode help task list-templates" [
  ]

  # Plan operations
  export extern "godmode help plan" [
  ]

  # Parse a plan markdown file and populate the task graph
  export extern "godmode help plan ingest" [
  ]

  # Show independent chains ready for parallel agent dispatch (JSON)
  export extern "godmode help dispatch" [
  ]

  # Emit full session context for hooks and subagents
  export extern "godmode help context" [
  ]

  # Show graph counts and next runnable task(s) — fast mid-session state check
  export extern "godmode help status" [
  ]

  # Agent operations: list installed agents, generate index, or dispatch a plan
  export extern "godmode help agent" [
  ]

  # List available agents (table or JSON)
  export extern "godmode help agent list" [
  ]

  # Regenerate agents/INDEX.md
  export extern "godmode help agent index" [
  ]

  # Ingest a plan file and emit an orca-strait dispatch payload
  export extern "godmode help agent dispatch" [
  ]

  # Generate .md from agent YAML definitions
  export extern "godmode help agent generate" [
  ]

  # Migrate agents/*.md frontmatter to agents/*.yaml stubs
  export extern "godmode help agent migrate" [
  ]

  # Run verification gate: nextest + clippy + fmt + non-empty git log
  export extern "godmode help verify" [
  ]

  # Wave state management for parallel agent sessions
  export extern "godmode help wave" [
  ]

  # Initialise a new wave state file
  export extern "godmode help wave init" [
  ]

  # Show current wave status
  export extern "godmode help wave status" [
  ]

  # Mark an agent slot as done
  export extern "godmode help wave done" [
  ]

  # Mark an agent slot as blocked
  export extern "godmode help wave block" [
  ]

  # Exit 1 if any slot is still pending
  export extern "godmode help wave check" [
  ]

  # Git worktree lifecycle management
  export extern "godmode help worktree" [
  ]

  # Create a worktree for a branch (optionally linked to a GH issue)
  export extern "godmode help worktree add" [
  ]

  # Remove a worktree after verifying its branch is merged into main
  export extern "godmode help worktree remove" [
  ]

  # CI failure triage
  export extern "godmode help ci" [
  ]

  # Fetch latest failed CI run and classify root cause
  export extern "godmode help ci triage" [
  ]

  # GitHub issue operations
  export extern "godmode help issue" [
  ]

  # List open GitHub issues
  export extern "godmode help issue list" [
  ]

  # Close a GitHub issue with a commit reference
  export extern "godmode help issue close" [
  ]

  # Interactive or file-driven task graph construction
  export extern "godmode help graph" [
  ]

  # Build a task graph interactively or from a template file
  export extern "godmode help graph build" [
  ]

  # Hook observability: list, log, and test hooks
  export extern "godmode help hook" [
  ]

  # List all hooks registered in hooks/hooks.json
  export extern "godmode help hook list" [
  ]

  # Print the last N lines from .ctx/godmode/traces/hooks.log
  export extern "godmode help hook log" [
  ]

  # Run a hook script with synthetic stdin JSON and show exit code + stderr
  export extern "godmode help hook test" [
  ]

  # Run all numbered migration scripts in hooks/migrations/
  export extern "godmode help hook migrate" [
  ]

  # Run a built-in hook by name (Rust implementation)
  export extern "godmode help hook run" [
  ]

  # Skill registry management
  export extern "godmode help skill" [
  ]

  # List all registered skills
  export extern "godmode help skill list" [
  ]

  # Install a skill from a local directory path
  export extern "godmode help skill install" [
  ]

  # Remove a skill from the registry by name
  export extern "godmode help skill uninstall" [
  ]

  # Plugin conformance and consistency auditing
  export extern "godmode help review" [
  ]

  # Run all conformance checks (skills + agents + plugin.json)
  export extern "godmode help review self" [
  ]

  # Check skill dirs for SKILL.md, frontmatter, and link integrity
  export extern "godmode help review skills" [
  ]

  # Check agent frontmatter completeness
  export extern "godmode help review agents" [
  ]

  # Plugin release: bump version, tag, push
  export extern "godmode help release" [
  ]

  # Show current plugin version
  export extern "godmode help release current" [
  ]

  # Increment patch version in all files listed in .version-bump.json
  export extern "godmode help release bump" [
  ]

  # Create annotated git tag for the current version
  export extern "godmode help release tag" [
  ]

  # Push current branch and version tag to origin
  export extern "godmode help release push" [
  ]

  # Generate and prepend a changelog entry from commits since last tag
  export extern "godmode help release changelog" [
  ]

  # Cross-check plugin.json, Cargo.toml, and git tag versions
  export extern "godmode help release validate" [
  ]

  # Workflow DAG execution per agent
  export extern "godmode help workflow" [
  ]

  # Execute a workflow DAG for an agent
  export extern "godmode help workflow run" [
  ]

  # List workflows for an agent (or all agents)
  export extern "godmode help workflow list" [
  ]

  # Show current state of a named workflow from .ctx/workflow-<name>.json
  export extern "godmode help workflow status" [
  ]

  # Render the task graph as DOT or SVG
  export extern "godmode help visualize-graph" [
  ]

  # Memory banking: persistent source-backed project context
  export extern "godmode help memory-banking" [
  ]

  # Print memory-bank contents for context injection (SessionStart hook)
  export extern "godmode help memory-banking inject" [
  ]

  # Print update reminder if session had commits (Stop hook)
  export extern "godmode help memory-banking remind" [
  ]

  # Create .ctx/memory-banking/ with empty template files
  export extern "godmode help memory-banking init" [
  ]

  # Show memory-banking status and staleness
  export extern "godmode help memory-banking status" [
  ]

  # Insight capture and retrieval (append-only JSONL)
  export extern "godmode help insight" [
  ]

  # Record a new insight
  export extern "godmode help insight add" [
  ]

  # List recorded insights
  export extern "godmode help insight list" [
  ]

  # Render insights to `.ctx/insights-YYYY-MM-DD.md`
  export extern "godmode help insight render" [
  ]

  # Pipeline execution: list, start, advance, and status multi-step pipelines
  export extern "godmode help pipeline" [
  ]

  # List all available pipelines with name and description
  export extern "godmode help pipeline list" [
  ]

  # Show steps for a pipeline, marking current position if active
  export extern "godmode help pipeline show" [
  ]

  # Start a pipeline, optionally from a named entry-point skill
  export extern "godmode help pipeline start" [
  ]

  # Mark current step done and advance to the next step
  export extern "godmode help pipeline next" [
  ]

  # Skip current step and advance without marking it done
  export extern "godmode help pipeline skip" [
  ]

  # Deactivate the current pipeline (clear saved state)
  export extern "godmode help pipeline stop" [
  ]

  # Show the active pipeline name, current step, and progress
  export extern "godmode help pipeline status" [
  ]

  # Run a pipeline headlessly — walk task graph, execute run: fields
  export extern "godmode help pipeline run" [
  ]

  # Governance policy management: resolve, check, list, audit
  export extern "godmode help policy" [
  ]

  # Resolve the effective policy for an agent
  export extern "godmode help policy resolve" [
  ]

  # Check if a tool call is allowed by an agent's policy
  export extern "godmode help policy check" [
  ]

  # List all available policies (default, categories, levels)
  export extern "godmode help policy list" [
  ]

  # Show governance audit trail
  export extern "godmode help policy audit" [
  ]

  # Pin the session to a specific repo root path
  export extern "godmode help pin" [
  ]

  # Remove the pinned root from the session
  export extern "godmode help unpin" [
  ]

  # First-time setup: create global config and project state dirs
  export extern "godmode help init" [
  ]

  # Validate environment: required tools, 1Password auth, worktrees
  export extern "godmode help doctor" [
  ]

  # Generate a test module stub for a crate and testing dimension
  export extern "godmode help scaffold" [
  ]

  # Check whether a Rust source file has associated tests
  export extern "godmode help test-check" [
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "godmode help help" [
  ]

}

export use completions *
