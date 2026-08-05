module completions {

  # Turn any repo into Rust — scan, plan, scaffold, absorb
  export extern cnbl [
    --help(-h)                # Print help
  ]

  # Walk a foreign repo and figure out what's in it (outputs JSONL)
  export extern "cnbl scan" [
    --output: path            # Save the JSONL output to a file instead of printing it
    --report                  # Also print a summary table showing what was found
    --help(-h)                # Print help
    path: path                # Path to the repo you want to cannibalize
  ]

  # Decide where each file should go in your Rust ecosystem (outputs JSONL)
  export extern "cnbl plan" [
    --repo-map: path          # Path to your repos.json ecosystem map (default: ~/dev/bazaar/repos.json)
    --input: path             # Read scan output from a file instead of stdin
    --dry-run                 # Show the routing decisions as a table without writing any output
    --help(-h)                # Print help
  ]

  # Create empty Rust stubs for everything that needs to be ported
  export extern "cnbl gen" [
    --input: path             # Read plan output from a file instead of stdin
    --out-dir: path           # Where to write the generated stubs (default: ./cnbl-output)
    --force                   # Replace existing files if they already exist
    --help(-h)                # Print help
  ]

  # Copy stubs into your repos and archive the originals — this does the actual work
  export extern "cnbl eat" [
    --input: path             # Read plan output from a file instead of stdin
    --scaffold-dir: path      # Where the generated stubs live (default: ./cnbl-output)
    --repo-root: path         # Root directory where your local repos live (default: ~/dev)
    --vault-dir: path         # Where to archive files that aren't being ported
    --source-repo: string     # Name of the repo being cannibalized
    --dry-run                 # Show what would happen without touching anything
    --help(-h)                # Print help
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "cnbl help" [
  ]

  # Walk a foreign repo and figure out what's in it (outputs JSONL)
  export extern "cnbl help scan" [
  ]

  # Decide where each file should go in your Rust ecosystem (outputs JSONL)
  export extern "cnbl help plan" [
  ]

  # Create empty Rust stubs for everything that needs to be ported
  export extern "cnbl help gen" [
  ]

  # Copy stubs into your repos and archive the originals — this does the actual work
  export extern "cnbl help eat" [
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "cnbl help help" [
  ]

}

export use completions *
