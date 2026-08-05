module completions {

  # A container runtime in Rust
  export extern mbx [
    --help(-h)                # Print help
    --version(-V)             # Print version
  ]

  # Run a container from an image
  export extern "mbx run" [
    --memory: string          # Memory limit in bytes (passed to cgroups v2 `memory.max`)
    --cpu-weight: string      # CPU weight in the range 1–10000 (passed to cgroups v2 `cpu.weight`)
    --tag(-t): string         # Image tag (default: latest)
    --network: string         # Network mode: none (default), bridge, host, tailnet. 'none' runs the container in an isolated namespace with no network connectivity
    --privileged              # Grant full Linux capabilities to the container (required for `DinD`)
    --volume(-v): string      # Bind mount in src:dst[:ro] format. Repeatable. Example: -v /tmp/bin:/minibox  -v /tmp/traces:/traces:ro
    --mount: string           # Long-form mount specification. Repeatable. Example: --mount type=bind,src=/tmp/bin,dst=/minibox
    --name: string            # Assign a human-readable name to the container. Can be used instead of the ID in stop/rm commands
    --tty                     # Allocate a pseudo-TTY
    --interactive(-i)         # Keep stdin open (interactive mode)
    --env(-e): string         # Set environment variables (KEY=VALUE). Repeatable
    --entrypoint: string      # Override the image entrypoint
    --user(-u): string        # Run as a specific user (e.g. "nobody", "1000:1000")
    --rm                      # Automatically remove the container when it exits
    --platform: string        # Target platform (e.g. linux/arm64). Defaults to host platform
    --cgroup-parent: string   # Override the cgroup root for this container (`DinD`)
    --help(-h)                # Print help (see more with '--help')
    --version(-V)             # Print version
    image: string             # Image name (e.g., alpine, ubuntu, library/nginx)
  ]

  # List all containers
  export extern "mbx ps" [
    --help(-h)                # Print help
    --version(-V)             # Print version
  ]

  # Stop a running container
  export extern "mbx stop" [
    --help(-h)                # Print help
    --version(-V)             # Print version
    id: string                # Container ID
  ]

  # Pause a running container
  export extern "mbx pause" [
    --help(-h)                # Print help
    --version(-V)             # Print version
    id: string                # Container ID
  ]

  # Resume a paused container
  export extern "mbx resume" [
    --help(-h)                # Print help
    --version(-V)             # Print version
    id: string                # Container ID
  ]

  # Remove a stopped container
  export extern "mbx rm" [
    --all                     # Remove all stopped containers
    --help(-h)                # Print help
    --version(-V)             # Print version
    id?: string               # Container ID (omit when using --all)
  ]

  # Re-pull cached images to check for newer versions
  export extern "mbx update" [
    --all                     # Update all cached images
    --containers              # Resolve images from running containers
    --restart                 # Restart containers after their image is updated
    --help(-h)                # Print help
    --version(-V)             # Print version
    ...images: string         # Specific images to update (e.g. alpine:latest nginx:stable)
  ]

  # Pull an image from Docker Hub
  export extern "mbx pull" [
    --tag: string             # Image tag (default: latest)
    --platform: string        # Target platform (e.g. linux/arm64). Defaults to host platform
    --help(-h)                # Print help
    --version(-V)             # Print version
    image: string             # Image name (e.g., alpine, library/nginx)
  ]

  # Execute a command inside a running container
  export extern "mbx exec" [
    --tty                     # Allocate a pseudo-TTY
    --interactive(-i)         # Keep stdin open (interactive mode)
    --user(-u): string        # Run as a specific user (e.g. "nobody", "1000:1000")
    --help(-h)                # Print help (see more with '--help')
    --version(-V)             # Print version
    container_id: string      # Container ID or name
  ]

  # Fetch or stream log output from a container
  export extern "mbx logs" [
    --follow                  # Keep the connection open and stream new output as it arrives
    --help(-h)                # Print help (see more with '--help')
    --version(-V)             # Print version
    id: string                # Container ID or name
  ]

  # Stream container lifecycle events as JSON-lines to stdout
  export extern "mbx events" [
    --help(-h)                # Print help (see more with '--help')
    --version(-V)             # Print version
  ]

  # Remove unused images from the image store
  export extern "mbx prune" [
    --dry-run                 # Show what would be removed without actually deleting anything
    --help(-h)                # Print help (see more with '--help')
    --version(-V)             # Print version
  ]

  # Remove a specific image by reference (e.g. alpine:latest)
  export extern "mbx rmi" [
    --help(-h)                # Print help
    --version(-V)             # Print version
    image_ref: string         # Image reference in name:tag format
  ]

  # Run a script inside a sandboxed container with resource limits
  export extern "mbx sandbox" [
    --image: string           # Image to use (default: minibox-sandbox:latest)
    --tag: string             # Image tag
    --memory-mb: string       # Memory limit in MB (default: 512)
    --timeout: string         # Timeout in seconds (default: 60)
    --volume(-v): string      # Extra bind mounts in src:dst[:ro] format. Repeatable
    --network                 # Enable bridge networking (default: no network)
    --help(-h)                # Print help (see more with '--help')
    --version(-V)             # Print version
    script: path              # Path to the script file on the host
  ]

  # Manage VM state snapshots (save, restore, list)
  export extern "mbx snapshot" [
    --help(-h)                # Print help
    --version(-V)             # Print version
  ]

  # Save a VM state snapshot
  export extern "mbx snapshot save" [
    --name: string            # Snapshot name (auto-generated if omitted)
    --help(-h)                # Print help
    --version(-V)             # Print version
    id: string                # Container ID
  ]

  # Restore a VM state snapshot
  export extern "mbx snapshot restore" [
    --help(-h)                # Print help
    --version(-V)             # Print version
    id: string                # Container ID
    name: string              # Snapshot name to restore
  ]

  # List available snapshots
  export extern "mbx snapshot list" [
    --help(-h)                # Print help
    --version(-V)             # Print version
    id: string                # Container ID
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "mbx snapshot help" [
  ]

  # Save a VM state snapshot
  export extern "mbx snapshot help save" [
  ]

  # Restore a VM state snapshot
  export extern "mbx snapshot help restore" [
  ]

  # List available snapshots
  export extern "mbx snapshot help list" [
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "mbx snapshot help help" [
  ]

  # Manage pipeline runs (run, list, show)
  export extern "mbx pipeline" [
    --help(-h)                # Print help
    --version(-V)             # Print version
  ]

  # Run a pipeline file inside a container
  export extern "mbx pipeline run" [
    --input: string           # Optional JSON input to the pipeline
    --image: string           # Container image to use (default: crux-runtime:latest)
    --help(-h)                # Print help
    --version(-V)             # Print version
    pipeline_path: string     # Path to the pipeline file (host-side, must be absolute)
  ]

  # List pipeline runs
  export extern "mbx pipeline list" [
    --limit: string           # Maximum number of results
    --pipeline: string        # Filter by pipeline path
    --help(-h)                # Print help
    --version(-V)             # Print version
  ]

  # Show details of a pipeline run
  export extern "mbx pipeline show" [
    --help(-h)                # Print help
    --version(-V)             # Print version
    id: string                # Pipeline run / trace ID
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "mbx pipeline help" [
  ]

  # Run a pipeline file inside a container
  export extern "mbx pipeline help run" [
  ]

  # List pipeline runs
  export extern "mbx pipeline help list" [
  ]

  # Show details of a pipeline run
  export extern "mbx pipeline help show" [
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "mbx pipeline help help" [
  ]

  # Update mbx and miniboxd to the latest release
  export extern "mbx upgrade" [
    --dry-run                 # Show what would be done without replacing binaries
    --version: string         # Install a specific version (e.g. "v0.21.0"). Default: latest
    --help(-h)                # Print help
  ]

  # Diagnose a container: gather state, process info, and cgroup context
  export extern "mbx diagnose" [
    --help(-h)                # Print help (see more with '--help')
    --version(-V)             # Print version
    container_id: string      # Container ID or unambiguous prefix
  ]

  # Show adapter suite diagnostics (no daemon connection required)
  export extern "mbx doctor" [
    --help(-h)                # Print help (see more with '--help')
    --version(-V)             # Print version
  ]

  # Open a read-only terminal dashboard: live container table + event log
  export extern "mbx tui" [
    --help(-h)                # Print help
    --version(-V)             # Print version
  ]

  # Show the execution manifest for a container
  export extern "mbx manifest" [
    --help(-h)                # Print help
    --version(-V)             # Print version
    id: string                # Container ID or name
  ]

  # Verify a container's execution manifest against a policy file
  export extern "mbx verify" [
    --policy: string          # Path to the JSON policy file
    --help(-h)                # Print help
    --version(-V)             # Print version
    id: string                # Container ID or name
  ]

  # Load an image from a local OCI tar archive
  export extern "mbx load" [
    --name: string            # Image name (default: derived from filename without extension)
    --tag: string             # Image tag (default: latest)
    --help(-h)                # Print help
    --version(-V)             # Print version
    path: string              # Path to the OCI image tar archive
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "mbx help" [
  ]

  # Run a container from an image
  export extern "mbx help run" [
  ]

  # List all containers
  export extern "mbx help ps" [
  ]

  # Stop a running container
  export extern "mbx help stop" [
  ]

  # Pause a running container
  export extern "mbx help pause" [
  ]

  # Resume a paused container
  export extern "mbx help resume" [
  ]

  # Remove a stopped container
  export extern "mbx help rm" [
  ]

  # Re-pull cached images to check for newer versions
  export extern "mbx help update" [
  ]

  # Pull an image from Docker Hub
  export extern "mbx help pull" [
  ]

  # Execute a command inside a running container
  export extern "mbx help exec" [
  ]

  # Fetch or stream log output from a container
  export extern "mbx help logs" [
  ]

  # Stream container lifecycle events as JSON-lines to stdout
  export extern "mbx help events" [
  ]

  # Remove unused images from the image store
  export extern "mbx help prune" [
  ]

  # Remove a specific image by reference (e.g. alpine:latest)
  export extern "mbx help rmi" [
  ]

  # Run a script inside a sandboxed container with resource limits
  export extern "mbx help sandbox" [
  ]

  # Manage VM state snapshots (save, restore, list)
  export extern "mbx help snapshot" [
  ]

  # Save a VM state snapshot
  export extern "mbx help snapshot save" [
  ]

  # Restore a VM state snapshot
  export extern "mbx help snapshot restore" [
  ]

  # List available snapshots
  export extern "mbx help snapshot list" [
  ]

  # Manage pipeline runs (run, list, show)
  export extern "mbx help pipeline" [
  ]

  # Run a pipeline file inside a container
  export extern "mbx help pipeline run" [
  ]

  # List pipeline runs
  export extern "mbx help pipeline list" [
  ]

  # Show details of a pipeline run
  export extern "mbx help pipeline show" [
  ]

  # Update mbx and miniboxd to the latest release
  export extern "mbx help upgrade" [
  ]

  # Diagnose a container: gather state, process info, and cgroup context
  export extern "mbx help diagnose" [
  ]

  # Show adapter suite diagnostics (no daemon connection required)
  export extern "mbx help doctor" [
  ]

  # Open a read-only terminal dashboard: live container table + event log
  export extern "mbx help tui" [
  ]

  # Show the execution manifest for a container
  export extern "mbx help manifest" [
  ]

  # Verify a container's execution manifest against a policy file
  export extern "mbx help verify" [
  ]

  # Load an image from a local OCI tar archive
  export extern "mbx help load" [
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "mbx help help" [
  ]

}

export use completions *
