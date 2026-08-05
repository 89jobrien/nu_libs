module completions {

  # A keyboard-first Kanban board in your terminal
  export extern kan-cli [
    --board: string           # Board name (project-scoped when in a project)
    --help(-h)                # Print help
  ]

  # Show quick overview of the current board
  export extern "kan-cli list" [
    --board: string           # Board name (project-scoped when in a project)
    --help(-h)                # Print help
  ]

  # Add a new card to a column
  export extern "kan-cli add" [
    --description(-d): string # Card description (optional)
    --tags(-T): string        # Comma-separated list of tags (e.g., "#bug,#urgent")
    --parent(-p): string      # Parent card ID (internal or display ID)
    --board: string           # Board name (project-scoped when in a project)
    --help(-h)                # Print help
    column: string            # Column name or ID to add the card to
    title: string             # Card title
  ]

  # Move a card to another column
  export extern "kan-cli move" [
    --board: string           # Board name (project-scoped when in a project)
    --help(-h)                # Print help
    card_id: string           # Card ID or display ID
    column: string            # Target column name or ID
  ]

  # Show details for a specific card
  export extern "kan-cli show" [
    --board: string           # Board name (project-scoped when in a project)
    --help(-h)                # Print help
    card_id: string           # Card ID or display ID
  ]

  # List all columns on the current board
  export extern "kan-cli columns" [
    --board: string           # Board name (project-scoped when in a project)
    --help(-h)                # Print help
  ]

  # Initialize a new board with default columns
  export extern "kan-cli init" [
    --columns(-c): string     # Comma-separated list of column names
    --prefix(-p): string      # Custom prefix for card IDs (e.g., "WORK")
    --global                  # Create a global board instead of a project-scoped board
    --board: string           # Board name (project-scoped when in a project)
    --help(-h)                # Print help
    name?: string             # Board name
  ]

  # List all available boards
  export extern "kan-cli boards" [
    --board: string           # Board name (project-scoped when in a project)
    --help(-h)                # Print help
  ]

  # Delete a card
  export extern "kan-cli delete" [
    --board: string           # Board name (project-scoped when in a project)
    --help(-h)                # Print help
    card_id: string           # Card ID or display ID
  ]

  # Update a card's title and/or description
  export extern "kan-cli update" [
    --title(-t): string       # New title
    --description(-d): string # New description
    --tags(-T): string        # New tags (overwrites existing tags)
    --parent(-p): string      # Parent card ID (internal or display ID)
    --board: string           # Board name (project-scoped when in a project)
    --help(-h)                # Print help
    card_id: string           # Card ID or display ID
  ]

  # Import Beads issues from a JSONL export
  export extern "kan-cli import-bd" [
    --path(-p): string        # Path to the Beads issues JSONL file
    --column(-c): string      # Column name or ID to import into
    --include-closed          # Include closed issues
    --dry-run                 # Preview issues without creating cards
    --board: string           # Board name (project-scoped when in a project)
    --help(-h)                # Print help
  ]

  # Import ready Beads issues via `bd ready --json`
  export extern "kan-cli import-bd-ready" [
    --column(-c): string      # Column name or ID to import into
    --limit(-l): string       # Maximum issues to import
    --assignee(-a): string    # Filter by assignee
    --label: string           # Filter by labels (AND)
    --label-any: string       # Filter by labels (OR)
    --type(-t): string        # Filter by issue type
    --priority(-p): string    # Filter by priority
    --unassigned              # Show only unassigned issues
    --include-deferred        # Include deferred issues
    --dry-run                 # Preview issues without creating cards
    --board: string           # Board name (project-scoped when in a project)
    --help(-h)                # Print help
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "kan-cli help" [
  ]

  # Show quick overview of the current board
  export extern "kan-cli help list" [
  ]

  # Add a new card to a column
  export extern "kan-cli help add" [
  ]

  # Move a card to another column
  export extern "kan-cli help move" [
  ]

  # Show details for a specific card
  export extern "kan-cli help show" [
  ]

  # List all columns on the current board
  export extern "kan-cli help columns" [
  ]

  # Initialize a new board with default columns
  export extern "kan-cli help init" [
  ]

  # List all available boards
  export extern "kan-cli help boards" [
  ]

  # Delete a card
  export extern "kan-cli help delete" [
  ]

  # Update a card's title and/or description
  export extern "kan-cli help update" [
  ]

  # Import Beads issues from a JSONL export
  export extern "kan-cli help import-bd" [
  ]

  # Import ready Beads issues via `bd ready --json`
  export extern "kan-cli help import-bd-ready" [
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "kan-cli help help" [
  ]

}

export use completions *
