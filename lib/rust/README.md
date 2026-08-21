# lib/rust

Rust and Cargo tooling — completions for `cargo`, a source-analysis toolkit
built on regex parsing, coverage, and SARIF post-processing.

```nu
use lib/rust *
```

At ~4.5k lines this is the largest category, almost all of it `rust_ast.nu`.

## Commands

### `cargo.nu` — typed cargo wrappers

Completion-carrying wrappers over the real subcommands: `cargo build`, `check`,
`clean`, `doc`, `new`, `init`, `run`, `test`, `bench`, `update`, `search`,
`publish`, `install`, `uninstall`, `metadata`, `help`, `clippy`,
`install-update`, `add`.

### `rust_ast.nu` — source analysis

`rust-ast` harvests symbols from Rust sources; the `rust-*-records` family
returns one table per item kind:

| Command                     | Returns                                    |
| --------------------------- | ------------------------------------------ |
| `rust-fn-records`           | Functions                                  |
| `rust-extern-fn-records`    | `extern "ABI"` functions                   |
| `rust-struct-records`       | Structs — braced, tuple, unit; generics and where-clauses |
| `rust-enum-records`         | Enums, with generics/where                 |
| `rust-trait-records`        | Traits, including supertraits              |
| `rust-trait-method-records` | Trait-impl methods                         |
| `rust-impl-records`         | `impl` blocks                              |
| `rust-type-records`         | Type aliases                               |
| `rust-mod-records`          | Inline modules and declarations            |
| `rust-file-mod-records`     | Modules synthesized from filesystem layout |
| `rust-macro-records`        | `macro_rules!`                             |
| `rust-const-records` / `rust-static-records` | `const` / `static` items  |
| `rust-use-records`          | One row per `use` statement                |

Display helpers: `rust-tree` (nested symbol structure, minimal payload),
`rust-print-symbol-tree`, `rust-print-call-graph`, `rust-print-dep-usage`.

Commands prefixed `_` (`_seen-add`, `_bump-file-count`, `_sg_cache_put`,
`_sg_cache_clear`, `_ensure-caches`, `_inline-idx-set`) are internal caching
machinery — they exist because the toolkit re-scans files aggressively.

**This is regex-based, not a real parser.** It does not resolve types, expand
macros, or respect `#[cfg]`. Treat the output as a good index, not ground truth.

### `workspace.nu`

`find-workspace-root`, `is-rust-file`, `is-nu-file`.

## Files that export nothing

`cargo_search.nu` and `get_coverage.nu` are glob-imported by `mod.nu` but define
their commands with bare `def`, not `export def` — so they contribute **nothing**
to `use lib/rust *`. `cargo.nu` supplies the `cargo search` you actually get.

## Not re-exported by `mod.nu`

| File                      | Exports                                            |
| ------------------------- | -------------------------------------------------- |
| `annotate.nu`             | `annotate-rust-lines`                              |
| `apply-ignore-reasons.nu` | `apply-ignore-reasons`, `list-unmatched-ignores`   |
| `enrich-sarif.nu`         | `enrich-sarif`, `derive-crate`, `derive-category`, `sarif-group-by` |
| `list-ignored-tests.nu`   | `list-ignored-tests`                               |

```nu
use lib/rust/enrich-sarif.nu *
open results.sarif | enrich-sarif | sarif-group-by category
```

These four are a `rustqual`-oriented toolchain: annotate lines, audit
`#[ignore]` attributes against a rule registry (`list-unmatched-ignores` shows
ignores with no matching rule), and enrich SARIF output with crate and category
fields before grouping.
