module completions {

  # SQLite store for atelier handoff files
  export extern handb [
    --db: path                # Path to the SQLite database (default: $HANDOFF_DB or ~/.ctx/handoff.db)
    --help(-h)                # Print help
  ]

  # Initialise (or migrate) the database schema
  export extern "handb init" [
    --db: path                # Path to the SQLite database (default: $HANDOFF_DB or ~/.ctx/handoff.db)
    --help(-h)                # Print help
  ]

  # Bidirectional sync between a HANDOFF yaml file and the database
  export extern "handb sync" [
    --project: string
    --handoff: path
    --db: path                # Path to the SQLite database (default: $HANDOFF_DB or ~/.ctx/handoff.db)
    --help(-h)                # Print help
  ]

  # Export DB items back to a HANDOFF yaml file (optionally squashing old done items)
  export extern "handb export" [
    --project: string
    --handoff: path
    --squash-done: string
    --db: path                # Path to the SQLite database (default: $HANDOFF_DB or ~/.ctx/handoff.db)
    --help(-h)                # Print help
  ]

  # Append a note/bug/discovery extra to an item
  export extern "handb note" [
    --project: string
    --item: string
    --note-type: string
    --text: string
    --db: path                # Path to the SQLite database (default: $HANDOFF_DB or ~/.ctx/handoff.db)
    --help(-h)                # Print help
  ]

  # Record a snapshot from a HANDOFF.<name>.<base>.state.yaml file
  export extern "handb snap" [
    --project: string
    --state: path
    --db: path                # Path to the SQLite database (default: $HANDOFF_DB or ~/.ctx/handoff.db)
    --help(-h)                # Print help
  ]

  # Query items in the database
  export extern "handb query" [
    --project: string
    --status: string
    --db: path                # Path to the SQLite database (default: $HANDOFF_DB or ~/.ctx/handoff.db)
    --help(-h)                # Print help
  ]

  # Show recent log entries
  export extern "handb log" [
    --project: string
    --limit: string
    --db: path                # Path to the SQLite database (default: $HANDOFF_DB or ~/.ctx/handoff.db)
    --help(-h)                # Print help
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "handb help" [
  ]

  # Initialise (or migrate) the database schema
  export extern "handb help init" [
  ]

  # Bidirectional sync between a HANDOFF yaml file and the database
  export extern "handb help sync" [
  ]

  # Export DB items back to a HANDOFF yaml file (optionally squashing old done items)
  export extern "handb help export" [
  ]

  # Append a note/bug/discovery extra to an item
  export extern "handb help note" [
  ]

  # Record a snapshot from a HANDOFF.<name>.<base>.state.yaml file
  export extern "handb help snap" [
  ]

  # Query items in the database
  export extern "handb help query" [
  ]

  # Show recent log entries
  export extern "handb help log" [
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "handb help help" [
  ]

}

export use completions *
