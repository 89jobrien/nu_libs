# lib/gkg

Knowledge-graph queries (`gkg`) and a `.kgx` file-backed wiki.

```nu
use lib/gkg *
```

## `gkg` — graph queries

Talks to a **gkg server on `localhost:27495`**. `gkg status` is the one to run
first; the rest assume a reachable server and an indexed project.

| Command          | Returns                                                          |
| ---------------- | ---------------------------------------------------------------- |
| `gkg status`     | Whether the server is reachable and the project indexed          |
| `gkg index`      | Index a repo or a workspace of repos                             |
| `gkg stats`      | Record with `total_nodes`, `total_relationships`, `node_counts`, … |
| `gkg search`     | Matching nodes — file, line, fqn, type                           |
| `gkg list-defs`  | Symbols of a given type, sampled via a broad search              |

`gkg list-defs` samples rather than enumerating — treat its output as a
discovery aid, not a complete list.

## `kgx` — `.kgx` wiki

File-backed, no server. Entries live under `.kgx/wiki/<section>/` in three
sections: `entity`, `summary`, `topic`.

| Command       | Does                                                              |
| ------------- | ----------------------------------------------------------------- |
| `kgx-root`    | Resolve the `.kgx` root for a repo path                           |
| `kgx list`    | List entries in a section                                         |
| `kgx read`    | Read one entry by section and slug                                |
| `kgx write`   | Create or **overwrite** an entry, appending to `log.md`            |
| `kgx reindex` | Rebuild `index.md` from the files actually on disk                |
| `kgx verify`  | Check expected entity slugs exist; returns `{slug, exists}` rows   |

`kgx write` overwrites without prompting. Run `kgx reindex` after adding or
removing files by hand, or `index.md` drifts from the directory.

## Requires

`gkg` server running on port 27495 for the `gkg` commands. The `kgx` commands
need only a `.kgx` directory.
