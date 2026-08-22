# scripts

Standalone scripts. **Not modules** — every `.nu` file here contains top-level
executable code, so `use`-ing one *runs* it. `file_cat.nu` would write and delete
files, `shell_stars.nu` would fire off 20 HTTP requests. Run them deliberately:

```nu
nu scripts/<name>.nu
```

Nothing under `lib/` depends on anything here.

## Tooling

| Script                       | Does                                                                 |
| ---------------------------- | -------------------------------------------------------------------- |
| `test-load.rs`               | Load test + inventory for `lib/`. See [the root README](../README.md#testing) |
| `defguard.nu`                | Manage a local defguard docker-compose 2.0 stack                     |
| `branch-protections.nu`      | Apply branch protection to every repo in a GitHub org                |
| `this_week_in_nu_release.nu` | Generate the "This Week in Nu" post from merged PRs                  |
| `shell_stars.nu`             | GitHub star counts for 20 shells, sorted                             |

### `test-load.rs`

The only non-Nu file here, and the only one with tests behind it. A dependency-free
[rust-script](https://rust-script.org/); CI runs it on every push.

```bash
./scripts/test-load.rs --inventory
```

### `defguard.nu`

The only script written as a proper command — shebang, `main`, subcommands:

```nu
nu scripts/defguard.nu up [dir]       # default dir: defguard-test
nu scripts/defguard.nu status [dir]
nu scripts/defguard.nu down [dir]     # docker compose down -v
nu scripts/defguard.nu clean [dir]    # down -v, then rm -rf the dir
```

`up` runs `bash <(curl -sSL .../defguard/deployment/.../setup.sh)` — it downloads
and executes a remote script. That is how upstream ships it, but know that going
in. `clean` does `rm -rf` on the directory you name.

Requires `docker`, `bash`, and `curl`.

### `branch-protections.nu`

Iterates every repo in `$env.OWNER` and `PUT`s a protection payload to each one's
default branch: required status checks, required reviews, linear history,
`enforce_admins`, no force pushes, no deletions.

**Fill in the placeholders before running it.** As committed, the payload contains
`'YOUR CHECK HERE'`, `'YOUR APP ID HERE'`, and a bare `[ YOUR APP HERE ]`. Those
parse as ordinary strings, so nothing will stop you — the script will happily push
nonsense config across the whole org. There is no dry-run flag and no confirmation
prompt.

Requires `gh` authenticated, and `$env.OWNER` set to the org.

### `this_week_in_nu_release.nu`

Builds the weekly Nushell post. Queries the GitHub search API for PRs merged in
the last 21 days across `nushell`, `vscode-nushell-lang`, `nushell.github.io`,
`demo`, `nu_scripts`, and `rfcs`, groups them by author, and prints Markdown. The
issue number is derived from weeks elapsed since 2019-08-23, the 0.2.0 release.
Sleeps 2s between fetches to stay under rate limits.

### `shell_stars.nu`

Star counts for 20 shells — bash, fish, nushell, pwsh, two ksh variants, elvish,
es, ion, mksh, ngs, oksh, oil, shell++, tcsh, xonsh, yash, zsh, plus the AWS and
Azure cloud shells — sorted descending, with a 250ms pause between requests.

Five more (`powershell`, `csh`, `dash`, `sh`, `cmd`) are commented out in the
list for having no GitHub URL. The script still carries a `str starts-with no`
branch to emit a 0-star row for those, which is unreachable while they stay
commented out.

### Both GitHub-API scripts are probably dead

`this_week_in_nu_release.nu` and `shell_stars.nu` authenticate with
`http get -u $env.GITHUB_USERNAME -p $env.GITHUB_PASSWORD`. GitHub removed
password authentication for the REST API in 2021, so these need porting to a token
(`http get -H [Authorization $"Bearer ($env.GITHUB_TOKEN)"]`) before they will
return anything.

## Demos and reference

Cookbook material — no arguments, no useful output, illustrating a technique.

| Script                                | Shows                                                        |
| ------------------------------------- | ------------------------------------------------------------ |
| `emulating_other_data_structures.nu`  | Lists as queue, stack, set, and multiset                     |
| `table_grouping.nu`                   | `group-by` + `transpose` to render a table as Markdown       |
| `progress_bar.nu`                     | A progress bar via `fill` and ANSI cursor control            |
| `progress_bar_no_back.nu`             | Stripped-down variant of the same                            |
| `file_cat.nu`                         | Combining two JSON files into one                            |

`emulating_other_data_structures.nu` is the most useful of these to read: it is
mostly commented prose covering enqueue/dequeue, push/pop, set membership, union,
intersection, difference, symmetric difference, and `uniq --count` for bag counts,
each with the expected result inline.

`table_grouping.nu` operates on hardcoded nushell PR data from 2021 — it is the
formatting half of `this_week_in_nu_release.nu`, extracted so you can see it work
without hitting the API.

`progress_bar.nu` carries a caveat from its author: *"There is a strange artifact
drawing the first two full blocks… I'm not sure what's going on nor how to fix
it."* `progress_bar_no_back.nu` exists to show that artifact more clearly.

`file_cat.nu` creates `a.json` and `b.json` **in the current directory**, merges
them to `c.json`, then deletes all three. Run it somewhere you don't mind that.
