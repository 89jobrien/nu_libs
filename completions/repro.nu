module completions {

  # Reproducible container image builder
  export extern repro [
    --help(-h)                # Print help
  ]

  def "nu-complete repro build runtime" [] {
    [ "docker" "podman" ]
  }

  # Perform a reproducible container image build
  export extern "repro build" [
    --runtime: string@"nu-complete repro build runtime" # Container runtime (docker or podman)
    --datetime: string        # Date/time in ISO format for image layer timestamps
    --buildkit-image: string  # BuildKit container image (NAME:TAG@DIGEST)
    --source-date-epoch: string # Unix timestamp for image layer timestamps
    --no-cache                # Do not use cached images
    --rootless                # Run BuildKit in rootless mode (Podman only)
    --file(-f): string        # Pathname of a Dockerfile
    --output(-o): string      # Path to save OCI tarball
    --tag(-t): string         # Tag the built image
    --build-arg: string       # Set build-time variables (ARG=VALUE)
    --annotation: string      # Append annotation to the image (KEY=VALUE)
    --platform: string        # Set platform for the image
    --buildkit-args: string   # Extra arguments for BuildKit (Podman only)
    --buildx-args: string     # Extra arguments for Docker Buildx (Docker only)
    --dry                     # Print commands without executing
    --help(-h)                # Print help
    context: string           # Path to the build context
  ]

  # Analyze an OCI image tarball
  export extern "repro analyze" [
    --expected-image-digest: string # Expected digest to verify against
    --show-contents           # Show full file contents
    --help(-h)                # Print help
    tarball: path             # Path to OCI image tarball
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "repro help" [
  ]

  # Perform a reproducible container image build
  export extern "repro help build" [
  ]

  # Analyze an OCI image tarball
  export extern "repro help analyze" [
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "repro help help" [
  ]

}

export use completions *
