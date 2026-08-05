module completions {

  # Bootstrap a new machine from dotfiles
  export extern notstrap [
    --help(-h)                # Print help
  ]

  # Run the full bootstrap sequence
  export extern "notstrap run" [
    --config: path            # Path to notstrap.toml config
    --force                   # Force re-run of setup hooks
    --key-file: path          # Path to age key file (skips Bitwarden and prompt)
    --dotfiles: path          # Path to dotfiles directory (default: ~/dotfiles)
    --help(-h)                # Print help
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "notstrap help" [
  ]

  # Run the full bootstrap sequence
  export extern "notstrap help run" [
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "notstrap help help" [
  ]

}

export use completions *
