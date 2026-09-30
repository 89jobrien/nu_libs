module completions {

  export extern kgx [
    --help(-h)                # Print help
    --root: string            # Root directory for all kgx data (default: .kgx in cwd)
  ]

  export extern "kgx docs" [
    --help(-h)                # Print help
  ]

  export extern "kgx export" [
    --help(-h)                # Print help
  ]

  export extern "kgx graph" [
    --help(-h)                # Print help
  ]

  export extern "kgx ingest" [
    --help(-h)                # Print help
  ]

  export extern "kgx init" [
    --help(-h)                # Print help
  ]

  export extern "kgx query" [
    --help(-h)                # Print help
  ]

  export extern "kgx stats" [
    --help(-h)                # Print help
  ]

  export extern "kgx wiki" [
    --help(-h)                # Print help
  ]

}

export use completions *
