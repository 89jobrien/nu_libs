module completions {

  # Knowledge graph toolkit
  export extern kgx [
    --root: path              # Root directory for all kgx data (default: .kgx in cwd)
    --help(-h)                # Print help
  ]

  # Initialize a new kgx workspace
  export extern "kgx init" [
    --help(-h)                # Print help
  ]

  # Ingest a document with entities and relations
  export extern "kgx ingest" [
    --format: string          # Input format: json (default) or github
    --github: string          # Fetch directly from GitHub (e.g. owner/repo)
    --github-layer: string    # GitHub extraction layer: metadata, docs, deps, issues
    --help(-h)                # Print help
  ]

  # Query the graph by seed entity name
  export extern "kgx query" [
    --help(-h)                # Print help
    name: string              # Entity name to start BFS from
  ]

  # Graph operations
  export extern "kgx graph" [
    --help(-h)                # Print help
  ]

  # Add a node
  export extern "kgx graph add-node" [
    --entity-type: string
    --supporting-text: string
    --source-doc: string
    --help(-h)                # Print help
    name: string
  ]

  # Add an edge
  export extern "kgx graph add-edge" [
    --relation-type: string
    --confidence: string
    --supporting-text: string
    --source-doc: string
    --help(-h)                # Print help
    source: string
    target: string
  ]

  # Search nodes by keyword
  export extern "kgx graph search" [
    --help(-h)                # Print help
    query: string
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "kgx graph help" [
  ]

  # Add a node
  export extern "kgx graph help add-node" [
  ]

  # Add an edge
  export extern "kgx graph help add-edge" [
  ]

  # Search nodes by keyword
  export extern "kgx graph help search" [
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "kgx graph help help" [
  ]

  # Wiki operations
  export extern "kgx wiki" [
    --help(-h)                # Print help
  ]

  # Write a wiki page (content on stdin)
  export extern "kgx wiki write" [
    --category: string
    --title: string
    --summary: string
    --help(-h)                # Print help
  ]

  # Read a wiki page
  export extern "kgx wiki read" [
    --category: string
    --title: string
    --help(-h)                # Print help
  ]

  # Search wiki pages
  export extern "kgx wiki search" [
    --help(-h)                # Print help
    query: string
  ]

  # List pages in a category
  export extern "kgx wiki list" [
    --category: string
    --help(-h)                # Print help
  ]

  # Lint the wiki for issues
  export extern "kgx wiki lint" [
    --help(-h)                # Print help
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "kgx wiki help" [
  ]

  # Write a wiki page (content on stdin)
  export extern "kgx wiki help write" [
  ]

  # Read a wiki page
  export extern "kgx wiki help read" [
  ]

  # Search wiki pages
  export extern "kgx wiki help search" [
  ]

  # List pages in a category
  export extern "kgx wiki help list" [
  ]

  # Lint the wiki for issues
  export extern "kgx wiki help lint" [
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "kgx wiki help help" [
  ]

  # Document store operations
  export extern "kgx docs" [
    --help(-h)                # Print help
  ]

  # List all ingested documents
  export extern "kgx docs list" [
    --help(-h)                # Print help
  ]

  # Search chunks by keyword
  export extern "kgx docs search" [
    --help(-h)                # Print help
    query: string
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "kgx docs help" [
  ]

  # List all ingested documents
  export extern "kgx docs help list" [
  ]

  # Search chunks by keyword
  export extern "kgx docs help search" [
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "kgx docs help help" [
  ]

  # Export the full context graph
  export extern "kgx export" [
    --format: string          # Output format: json or markdown
    --output: path            # Output directory
    --help(-h)                # Print help
  ]

  # Show stats
  export extern "kgx stats" [
    --help(-h)                # Print help
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "kgx help" [
  ]

  # Initialize a new kgx workspace
  export extern "kgx help init" [
  ]

  # Ingest a document with entities and relations
  export extern "kgx help ingest" [
  ]

  # Query the graph by seed entity name
  export extern "kgx help query" [
  ]

  # Graph operations
  export extern "kgx help graph" [
  ]

  # Add a node
  export extern "kgx help graph add-node" [
  ]

  # Add an edge
  export extern "kgx help graph add-edge" [
  ]

  # Search nodes by keyword
  export extern "kgx help graph search" [
  ]

  # Wiki operations
  export extern "kgx help wiki" [
  ]

  # Write a wiki page (content on stdin)
  export extern "kgx help wiki write" [
  ]

  # Read a wiki page
  export extern "kgx help wiki read" [
  ]

  # Search wiki pages
  export extern "kgx help wiki search" [
  ]

  # List pages in a category
  export extern "kgx help wiki list" [
  ]

  # Lint the wiki for issues
  export extern "kgx help wiki lint" [
  ]

  # Document store operations
  export extern "kgx help docs" [
  ]

  # List all ingested documents
  export extern "kgx help docs list" [
  ]

  # Search chunks by keyword
  export extern "kgx help docs search" [
  ]

  # Export the full context graph
  export extern "kgx help export" [
  ]

  # Show stats
  export extern "kgx help stats" [
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "kgx help help" [
  ]

}

export use completions *
