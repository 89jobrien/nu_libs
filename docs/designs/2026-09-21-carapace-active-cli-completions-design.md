# Design: Carapace Completions for Active CLIs

## Goal

Provide maintained completions for every user-facing CLI in a local project with a commit in
the last 90 days, without requiring each CLI to implement Nushell-specific generation.

## Approved Approach

Keep existing Nushell extern definitions and add Carapace YAML specs for missing active CLIs,
with a Nushell command that installs the tracked specs into Carapace's platform config directory.

## Context Map

### Files to Modify

| File                          | Purpose                             | Changes Needed                                                            |
| ----------------------------- | ----------------------------------- | ------------------------------------------------------------------------- |
| `lib/std/carapace.nu`         | Carapace helpers                    | Resolve the platform config path and sync tracked specs                   |
| `completions/carapace/*.yaml` | Tracked external CLI specifications | Add active user-facing command trees, flags, and value completion actions |
| `README.md`                   | Repository usage                    | Document Carapace spec installation and coverage policy                   |

### Dependencies

| File                                             | Relationship                                       |
| ------------------------------------------------ | -------------------------------------------------- |
| `lib/std/mod.nu`                                 | Already re-exports `lib/std/carapace.nu`           |
| `/Users/joe/.config/nushell/config.nu`           | Already delegates external completion to Carapace  |
| `/Users/joe/.config/nushell/autoload/nu_libs.nu` | Already loads `lib/mod.nu`, exposing sync commands |

### Test Coverage

The repository has no traditional test harness. Validation loads the changed Nu module, checks
every YAML document against Carapace, installs into an isolated temporary config root, and probes
representative root and nested command completions.

### Reference Patterns

| File                  | Pattern to Follow                                                     |
| --------------------- | --------------------------------------------------------------------- |
| `lib/std/carapace.nu` | Existing conversion and installation helper                           |
| `completions/*.nu`    | Existing command naming and descriptions                              |
| Carapace spec schema  | Command, flags, persistent flags, subcommands, and completion actions |

## Ownership

`nu_libs` owns the tracked specs and installer. Individual CLI repositories remain unchanged.

## Public API

The existing `nul-carapace` command remains compatible. One command is added:

```nu
export def sync-carapace-specs [
    --dry-run
]
```

## Data Flow

1. Source: YAML specs in `completions/carapace/` describe active local CLIs.
2. Transform: `sync-carapace-specs` resolves Carapace's macOS or XDG config location.
3. Sink: Specs are copied with atomic per-file replacement into Carapace's `specs/` directory.
4. Runtime: Nushell's configured external completer invokes Carapace for suggestions.

## Coverage

Include active user-facing CLIs missing native extern definitions. Exclude daemons, MCP servers,
compatibility aliases, internal build helpers, and external/upstream repositories.

The inventory is sourced from each repository's current working tree on 2026-09-21:

| Commands            | Repository   | Included surface                                            |
| ------------------- | ------------ | ----------------------------------------------------------- |
| `crux`, `crux-task` | `crux`       | Pipeline runner, validator, planner, and task management    |
| `slash`             | `slash`      | Slash-command parser and orchestration CLI                  |
| `rulery`            | `rulery`     | Rule management CLI                                         |
| `episteme`          | `episteme`   | Knowledge CLI                                               |
| `surgeon`           | `surgeon`    | Source transformation CLI                                   |
| `pactum`            | `pactum`     | Contract CLI                                                |
| `atelier`           | `atelier`    | Workspace automation CLI                                    |
| `praxis`            | `praxis`     | Improvement-loop demo and trace ingestion                   |
| `looprs`            | `looprs`     | Agent runtime, provider selection, and TUI entrypoint       |
| `obfsck`, `scan`    | `obfsck`     | Secret scanning and compatibility scan surface              |
| `bamlish`           | `bamlish`    | BAML workflow CLI                                           |
| `opavs`             | `opavs`      | OPAVS workflow CLI                                          |
| `crs`               | `coursers`   | Hook, rule, and command-learning CLI                        |
| `xtui`              | `xtui`       | Terminal UI CLI                                             |
| `hj`                | `hj`         | Handoff lifecycle CLI; compatibility binaries excluded      |
| `rxx`               | `rx`         | Prefix-learning CLI; `rx` already has a native extern       |
| `notfiles`          | `notfiles`   | Dotfile management CLI; companion CLIs already have externs |
| `lintx`             | `checkup`    | User-facing lint runner; internal helper binaries excluded  |
| `doobdash`          | `doob`       | Todo dashboard; `doob` already has a native extern          |
| `prefixe`           | `prefixe`    | Prefix management CLI                                       |
| `bz`                | `bazaar`     | Bazaar CLI                                                  |
| `sparkfile`         | `sparkfile`  | Project scaffolding CLI                                     |
| `ragrs`             | `ragrs`      | Retrieval CLI                                               |
| `harvestrs`         | `harvestrs`  | Harvesting CLI                                              |
| `dev-health`        | `dev-health` | Development health CLI                                      |
| `disyn-app`         | `disyn`      | Disyn application CLI                                       |
| `sandbox-cli`       | `sandbox`    | Sandbox management CLI                                      |

## Out of Scope

- Migrating existing `completions/*.nu` definitions.
- Modifying every CLI to generate native shell completions.
- Completing daemon-only, MCP-only, compatibility, or internal commands.

## Risk

- Breaking API changes: no.
- New dependency: no; Carapace is already installed and configured.
- Platform behavior: the installer must not assume Linux's `$HOME/.config` path on macOS.
- Drift: static specs must be refreshed when a CLI's argument model changes.
