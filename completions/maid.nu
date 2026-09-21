module completions {

  # A clean file organiser
  export extern maid [
    --help(-h)                # Print help
  ]

  # Organise files in a directory
  export extern "maid run" [
    --help(-h)                # Print help
    path?: path               # Target directory (defaults to configured directories)
  ]

  # Preview what would happen without moving files
  export extern "maid preview" [
    --help(-h)                # Print help
    path?: path               # Target directory (defaults to configured directories)
  ]

  # Undo the last organisation
  export extern "maid undo" [
    --help(-h)                # Print help
    path?: path               # Target directory (defaults to configured directories)
  ]

}

export use completions *
