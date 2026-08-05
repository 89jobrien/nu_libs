module completions {

  # Modern todo management for coding agents
  export extern doob [
    --json                    # Output in JSON format
    --db: string              # Database path
    --help(-h)                # Print help
  ]

  # Manage todos
  export extern "doob todo" [
    --json                    # Output in JSON format
    --db: string              # Database path
    --help(-h)                # Print help
  ]

  # Add todo(s)
  export extern "doob todo add" [
    --priority: string
    --project(-p): string
    --file(-f): string
    --tags(-t): string
    --blocks: string          # UUIDs this todo blocks (comma-separated)
    --blocked-by: string      # UUIDs that block this todo (comma-separated)
    --json                    # Output in JSON format
    --db: string              # Database path
    --help(-h)                # Print help
    ...content: string        # Task description(s)
  ]

  # List todos
  export extern "doob todo list" [
    --status: string
    --project(-p): string
    --limit(-l): string
    --json                    # Output in JSON format
    --db: string              # Database path
    --help(-h)                # Print help
  ]

  # Complete todo(s)
  export extern "doob todo complete" [
    --json                    # Output in JSON format
    --db: string              # Database path
    --help(-h)                # Print help
    ...ids: string            # Todo ID(s)
  ]

  # Remove/delete todo(s)
  export extern "doob todo remove" [
    --json                    # Output in JSON format
    --db: string              # Database path
    --help(-h)                # Print help
    ...ids: string            # Todo ID(s)
  ]

  # Set or clear due date for a todo
  export extern "doob todo due" [
    --json                    # Output in JSON format
    --db: string              # Database path
    --help(-h)                # Print help
    id: string                # Todo ID
    date?: string             # Due date (YYYY-MM-DD or 'clear')
  ]

  # Undo completion (mark as pending)
  export extern "doob todo undo" [
    --json                    # Output in JSON format
    --db: string              # Database path
    --help(-h)                # Print help
    ...ids: string            # Todo ID(s)
  ]

  # Show dependency chain for a todo
  export extern "doob todo deps" [
    --json                    # Output in JSON format
    --db: string              # Database path
    --help(-h)                # Print help
    id: string                # Todo UUID or record ID
  ]

  # Sync todos to GitHub issues
  export extern "doob todo gh-sync" [
    --uuid: string            # Sync a single todo by UUID (used by hook)
    --execute                 # Actually perform the sync (default is dry-run preview)
    --force                   # Re-sync todos already in state file
    --action: string          # Action hint: "add", "complete", or "remove" (used by hook)
    --json                    # Output in JSON format
    --db: string              # Database path
    --help(-h)                # Print help
  ]

  # Update fields of an existing todo in place
  export extern "doob todo update" [
    --priority: string        # Priority (1-5)
    --status: string          # Status: pending | in_progress | completed
    --project(-p): string     # Project name
    --tags(-t): string        # Comma-separated tags (replaces existing tags)
    --content: string         # New todo description
    --json                    # Output in JSON format
    --db: string              # Database path
    --help(-h)                # Print help
    id: string                # Todo UUID or todo:<id> format
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "doob todo help" [
  ]

  # Add todo(s)
  export extern "doob todo help add" [
  ]

  # List todos
  export extern "doob todo help list" [
  ]

  # Complete todo(s)
  export extern "doob todo help complete" [
  ]

  # Remove/delete todo(s)
  export extern "doob todo help remove" [
  ]

  # Set or clear due date for a todo
  export extern "doob todo help due" [
  ]

  # Undo completion (mark as pending)
  export extern "doob todo help undo" [
  ]

  # Show dependency chain for a todo
  export extern "doob todo help deps" [
  ]

  # Sync todos to GitHub issues
  export extern "doob todo help gh-sync" [
  ]

  # Update fields of an existing todo in place
  export extern "doob todo help update" [
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "doob todo help help" [
  ]

  # Manage notes
  export extern "doob note" [
    --json                    # Output in JSON format
    --db: string              # Database path
    --help(-h)                # Print help
  ]

  # Add note(s)
  export extern "doob note add" [
    --project(-p): string
    --file(-f): string
    --tags(-t): string
    --json                    # Output in JSON format
    --db: string              # Database path
    --help(-h)                # Print help
    ...content: string        # Note content
  ]

  # List notes
  export extern "doob note list" [
    --project(-p): string
    --limit(-l): string
    --json                    # Output in JSON format
    --db: string              # Database path
    --help(-h)                # Print help
  ]

  # Remove/delete note(s)
  export extern "doob note remove" [
    --json                    # Output in JSON format
    --db: string              # Database path
    --help(-h)                # Print help
    ...ids: string            # Note ID(s)
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "doob note help" [
  ]

  # Add note(s)
  export extern "doob note help add" [
  ]

  # List notes
  export extern "doob note help list" [
  ]

  # Remove/delete note(s)
  export extern "doob note help remove" [
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "doob note help help" [
  ]

  # Visual kanban board of todos
  export extern "doob kan" [
    --project(-p): string     # Filter by project
    --status: string          # Filter by status (comma-separated: pending,in_progress,completed,cancelled)
    --json                    # Output in JSON format
    --db: string              # Database path
    --help(-h)                # Print help
  ]

  # Full-text search across todos and notes
  export extern "doob search" [
    --type: string            # Filter by type: todo, note, or all
    --project(-p): string     # Filter by project
    --json                    # Output in JSON format
    --db: string              # Database path
    --help(-h)                # Print help
    query: string             # Search query
  ]

  # Analytics and statistics
  export extern "doob stats" [
    --project(-p): string     # Filter by project
    --window: string          # Time window in days for recent activity
    --json                    # Output in JSON format
    --db: string              # Database path
    --help(-h)                # Print help
  ]

  # Archive completed/cancelled todos
  export extern "doob archive" [
    --json                    # Output in JSON format
    --db: string              # Database path
    --help(-h)                # Print help
  ]

  # Move old completed/cancelled todos to archive (dry-run by default)
  export extern "doob archive run" [
    --older-than: string      # Archive todos older than N days
    --apply                   # Actually perform the move (default is dry-run preview)
    --project(-p): string     # Filter by project
    --json                    # Output in JSON format
    --db: string              # Database path
    --help(-h)                # Print help
  ]

  # List archived todos
  export extern "doob archive list" [
    --project(-p): string
    --limit(-l): string
    --json                    # Output in JSON format
    --db: string              # Database path
    --help(-h)                # Print help
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "doob archive help" [
  ]

  # Move old completed/cancelled todos to archive (dry-run by default)
  export extern "doob archive help run" [
  ]

  # List archived todos
  export extern "doob archive help list" [
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "doob archive help help" [
  ]

  # Manage handoff items (bidirectional sync with HANDOFF.yaml)
  export extern "doob handoff" [
    --json                    # Output in JSON format
    --db: string              # Database path
    --help(-h)                # Print help
  ]

  # Bidirectional sync between HANDOFF.yaml and the handoff_item table
  export extern "doob handoff sync" [
    --file: path              # Path to the HANDOFF.yaml file
    --json                    # Output in JSON format
    --db: string              # Database path
    --help(-h)                # Print help
  ]

  # List handoff items
  export extern "doob handoff list" [
    --project(-p): string     # Filter by project name
    --status: string          # Filter by status (open, done, parked, blocked)
    --json                    # Output in JSON format
    --db: string              # Database path
    --help(-h)                # Print help
  ]

  # Append an extra entry to a handoff item
  export extern "doob handoff add-extra" [
    --type: string            # Entry type: note, blocker, decision, discovery, escalation
    --note: string            # Note text
    --json                    # Output in JSON format
    --db: string              # Database path
    --help(-h)                # Print help
    handoff_id: string        # Handoff item ID (e.g. cci-7)
  ]

  # Update the status of a handoff item
  export extern "doob handoff update-status" [
    --json                    # Output in JSON format
    --db: string              # Database path
    --help(-h)                # Print help
    handoff_id: string        # Handoff item ID (e.g. doob-1)
    status: string            # New status: open, done, parked, blocked
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "doob handoff help" [
  ]

  # Bidirectional sync between HANDOFF.yaml and the handoff_item table
  export extern "doob handoff help sync" [
  ]

  # List handoff items
  export extern "doob handoff help list" [
  ]

  # Append an extra entry to a handoff item
  export extern "doob handoff help add-extra" [
  ]

  # Update the status of a handoff item
  export extern "doob handoff help update-status" [
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "doob handoff help help" [
  ]

  # Launch the doobdash TUI dashboard
  export extern "doob tui" [
    --file(-f): string        # Path to HANDOFF.yaml (auto-detected if omitted)
    --json                    # Output in JSON format
    --db: string              # Database path
    --help(-h)                # Print help
  ]

  # Live-updating kanban board
  export extern "doob watch" [
    --project(-p): string     # Filter by project
    --status: string          # Filter by status (comma-separated)
    --interval: string        # Refresh interval in seconds
    --json                    # Output in JSON format
    --db: string              # Database path
    --help(-h)                # Print help
  ]

  # Print machine-readable JSON manifest of all commands and params
  export extern "doob schema" [
    --json                    # Output in JSON format
    --db: string              # Database path
    --help(-h)                # Print help
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "doob help" [
  ]

  # Manage todos
  export extern "doob help todo" [
  ]

  # Add todo(s)
  export extern "doob help todo add" [
  ]

  # List todos
  export extern "doob help todo list" [
  ]

  # Complete todo(s)
  export extern "doob help todo complete" [
  ]

  # Remove/delete todo(s)
  export extern "doob help todo remove" [
  ]

  # Set or clear due date for a todo
  export extern "doob help todo due" [
  ]

  # Undo completion (mark as pending)
  export extern "doob help todo undo" [
  ]

  # Show dependency chain for a todo
  export extern "doob help todo deps" [
  ]

  # Sync todos to GitHub issues
  export extern "doob help todo gh-sync" [
  ]

  # Update fields of an existing todo in place
  export extern "doob help todo update" [
  ]

  # Manage notes
  export extern "doob help note" [
  ]

  # Add note(s)
  export extern "doob help note add" [
  ]

  # List notes
  export extern "doob help note list" [
  ]

  # Remove/delete note(s)
  export extern "doob help note remove" [
  ]

  # Visual kanban board of todos
  export extern "doob help kan" [
  ]

  # Full-text search across todos and notes
  export extern "doob help search" [
  ]

  # Analytics and statistics
  export extern "doob help stats" [
  ]

  # Archive completed/cancelled todos
  export extern "doob help archive" [
  ]

  # Move old completed/cancelled todos to archive (dry-run by default)
  export extern "doob help archive run" [
  ]

  # List archived todos
  export extern "doob help archive list" [
  ]

  # Manage handoff items (bidirectional sync with HANDOFF.yaml)
  export extern "doob help handoff" [
  ]

  # Bidirectional sync between HANDOFF.yaml and the handoff_item table
  export extern "doob help handoff sync" [
  ]

  # List handoff items
  export extern "doob help handoff list" [
  ]

  # Append an extra entry to a handoff item
  export extern "doob help handoff add-extra" [
  ]

  # Update the status of a handoff item
  export extern "doob help handoff update-status" [
  ]

  # Launch the doobdash TUI dashboard
  export extern "doob help tui" [
  ]

  # Live-updating kanban board
  export extern "doob help watch" [
  ]

  # Print machine-readable JSON manifest of all commands and params
  export extern "doob help schema" [
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "doob help help" [
  ]

}

export use completions *
