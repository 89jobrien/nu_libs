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

  # Print this message or the help of the given subcommand(s)
  export extern "maid help" [
  ]

  # Organise files in a directory
  export extern "maid help run" [
  ]

  # Preview what would happen without moving files
  export extern "maid help preview" [
  ]

  # Undo the last organisation
  export extern "maid help undo" [
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "maid help help" [
  ]

}

export use completions *
