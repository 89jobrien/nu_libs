# lib/git

Git helpers: log stats, branch age and cleanup, gone branches, hook management,
version bumping.

```nu
use lib/git *
```

## Commands

| Command                  | From                    | Does                                              |
| ------------------------ | ----------------------- | ------------------------------------------------- |
| `gl` / `glv`             | `git.nu`                | Log view — compact / verbose                      |
| `gco <branch>`           | `git.nu`                | `git checkout`                                    |
| `gbD <branch>`           | `git.nu`                | `git branch -D` (force delete)                    |
| `gf <branch> [remote]`   | `git.nu`                | `git fetch`, remote defaults to `origin`          |
| `grb <branch>`           | `git.nu`                | `git rebase`                                      |
| `gr [remote]`            | `git.nu`                | `git remote show`, defaults to `origin`           |
| `grh <commit>`           | `git.nu`                | `git reset <commit>` — mixed, *not* `--hard`      |
| `gha`                    | `git.nu`                | Histogram of commits per author                   |
| `gsq`                    | `git.nu`                | Expire all reflog + `gc --prune=now --aggressive` |
| `gpp!`                   | `git.nu`                | **Destructive** — see below                       |
| `git age`                | `git_branch_age.nu`     | Branches sorted by last-commit age                |
| `git branch-cleanup`     | `git_branch_cleanup.nu` | Delete merged/stale branches                      |
| `git gone`               | `git_gone.nu`           | Branches whose upstream is gone                   |
| `clone all`              | `clone-all.nu`          | Bulk clone                                        |
| `git-install-hooks`      | `git-hooks.nu`          | Install this repo's hooks                         |
| `git-uninstall-hooks`    | `git-hooks.nu`          | Remove them                                       |
| `git-list-hooks`         | `git-hooks.nu`          | List installed hooks                              |
| `git-hooks-dir`          | `git-hooks.nu`          | Resolve the hooks directory                       |
| `git-hooks-context`      | `git-hooks.nu`          | Context record passed to hooks                    |
| `has-git-hooks`          | `git-hooks.nu`          | Predicate                                         |
| `project init-git-hooks` | `git-hooks.nu`          | Scaffold hooks for a project                      |

### Two commands that lose work

- **`gpp!`** runs `git pull`, `git add --all`, `git commit -a --no-edit
  --amend`, then `git push --force`. It rewrites the last commit with every
  unstaged change in the tree and force-pushes it. Never run it on a shared
  branch, and never as a reflex "push" alias.
- **`gsq`** expires the entire reflog (`--expire=now`) before an aggressive
  `gc`. That discards the safety net you would otherwise use to recover a bad
  reset or amend. It reclaims space; it is not a squash.

`_git_stat` and `_git_log` are internal helpers the above build on.

## Not re-exported by `mod.nu`

| File                  | Why                                              | Use instead                        |
| --------------------- | ------------------------------------------------ | ---------------------------------- |
| `bump-version.nu`     | `export def main` — would collide as bare `main` | `use lib/git/bump-version.nu`      |
| `merged-branches.nu`  | Script (bare pipeline), not a module             | `use lib/git/merged-branches.nu`   |
| `merge-conflicts.nu`  | Not wired into `mod.nu`                          | `use lib/git/merge-conflicts.nu *` |
| `workspace-health.nu` | Not wired into `mod.nu`                          | `use lib/git/workspace-health.nu *`|

```nu
use lib/git/bump-version.nu
bump-version patch
```

`merge-conflicts.nu` exports `merge-conflicts` and `categorize-conflicts`;
`workspace-health.nu` exports `workspace-health`.

## Requires

`git` on `PATH`. `git-hooks.nu` writes into `.git/hooks/` — see `lib/hooks/`
for the Claude Code hook I/O primitives those scripts use.
