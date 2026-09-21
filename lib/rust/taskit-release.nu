#!/usr/bin/env nu
# Release a taskit-managed Rust project, in order:
#   1. single validation check (taskit ci --fail-fast)
#   2. bump version based on conventional-commit changes since the last tag
#   3. generate CHANGELOG.md via git-cliff (falls back to git-cliff's default
#      config if the project has no cliff.toml)
#   4. commit + tag the release
#   5. push --no-verify
#   6. create the GitHub release (taskit release)
#   7. publish to crates.io (taskit publish)
#   8. log it to .ctx/logs/releases.log
#
# Requires: taskit, git-cliff, gh (for taskit release), a Cargo project with
# taskit.toml configured for major/minor/patch/publish/release.
#
# Works for both Cargo workspaces ([workspace.package] version) and
# single-crate projects ([package] version) — detected automatically from
# whether Cargo.toml contains a [workspace] table.
#
# Usage:
#   use ~/dev/nu_libs/lib/rust/taskit-release.nu *
#   taskit-release --dry-run    # print every step, run nothing irreversible
#   taskit-release              # interactive — confirms before push/release/publish
#   taskit-release --yes        # skip the confirmation prompt

# [nu_lib] Read the crate version from Cargo.toml, whether this is a
# workspace ([workspace.package] version) or a single crate ([package] version).
def read-version []: nothing -> string {
    let cargo = (open Cargo.toml)
    let raw = (open --raw Cargo.toml)
    if ($raw | str contains "[workspace") {
        $cargo | get workspace.package.version
    } else {
        $cargo | get package.version
    }
}

export def main [--dry-run, --yes] {
    print "== release: single validation check =="
    if $dry_run {
        print "  \(dry-run\) taskit ci --fail-fast"
    } else {
        ^taskit ci --fail-fast
    }

    let last_tag = (do { ^git describe --tags --abbrev=0 } | complete)
    let has_prior_release = ($last_tag.exit_code == 0)
    let current_version = (read-version)

    print "== release: determine version =="
    let bump_kind = if not $has_prior_release {
        print $"  no prior tag — first release, keeping current version ($current_version)"
        "none"
    } else {
        # git-cliff echoes back the unchanged (v-prefixed) tag when there are
        # no bump-worthy commits since it, and returns a bare semver (no "v")
        # when proposing a genuine new version — normalize both before
        # comparing, and treat exact equality as "nothing to bump" rather
        # than trusting the presence/absence of a "v" prefix.
        let bumped = (^git-cliff --bumped-version | str trim | str replace -r '^v' '')
        let cur_norm = ($current_version | str replace -r '^v' '')
        print $"  current: ($cur_norm)  cliff-suggested: ($bumped)"
        if $bumped == $cur_norm {
            "none"
        } else {
            let cur = ($cur_norm | split row ".")
            let new = ($bumped | split row ".")
            if ($new.0 != $cur.0) {
                "major"
            } else if ($new.1 != $cur.1) {
                "minor"
            } else if ($new.2 != $cur.2) {
                "patch"
            } else {
                "none"
            }
        }
    }

    if $bump_kind != "none" {
        print $"== release: bumping ($bump_kind) via taskit =="
        if $dry_run {
            print $"  \(dry-run\) taskit ($bump_kind)"
        } else {
            match $bump_kind {
                "major" => { ^taskit major }
                "minor" => { ^taskit minor }
                "patch" => { ^taskit patch }
            }
        }
    } else {
        print "== release: no version bump needed =="
    }

    let version = (read-version)
    let tag = $"v($version)"
    print $"== release: target ($tag) =="

    print "== release: generate changelog via git-cliff =="
    if $dry_run {
        print $"  \(dry-run\) git-cliff --tag ($tag) -o CHANGELOG.md"
    } else {
        ^git-cliff --tag $tag -o CHANGELOG.md
    }

    if not $dry_run and not $yes {
        let ok = (input $"About to commit, tag, push --no-verify, create a GitHub release, and publish to crates.io as ($tag). Continue? [y/N] ")
        if ($ok | str downcase) != "y" {
            print "aborted."
            exit 1
        }
    }

    print "== release: commit version bump + changelog =="
    if $dry_run {
        print $"  \(dry-run\) git add -A && git commit -m 'chore\(release\): ($tag)'"
    } else {
        ^git add -A
        ^git commit -m $"chore\(release\): ($tag)"
    }

    print $"== release: tag ($tag) =="
    if $dry_run {
        print $"  \(dry-run\) git tag -a ($tag) -m 'Release ($tag)'"
    } else {
        ^git tag -a $tag -m $"Release ($tag)"
    }

    print "== release: push --no-verify =="
    if $dry_run {
        print "  (dry-run) git push --no-verify && git push --no-verify --tags"
    } else {
        ^git push --no-verify
        ^git push --no-verify --tags
    }

    print $"== release: GitHub release ($tag) =="
    if $dry_run {
        print $"  \(dry-run\) taskit release ($tag)"
    } else {
        ^taskit release $tag
    }

    print "== release: publish to crates.io =="
    if $dry_run {
        print "  (dry-run) taskit publish"
    } else {
        ^taskit publish
    }

    print "== release: log it =="
    let commit_sha = (^git rev-parse HEAD | str trim)
    let timestamp = (date now | format date "%Y-%m-%dT%H:%M:%S")
    let log_line = $"($timestamp)  ($tag)  ($commit_sha)"
    if $dry_run {
        print $"  \(dry-run\) would append to .ctx/logs/releases.log: ($log_line)"
    } else {
        mkdir .ctx/logs
        $log_line | save --append .ctx/logs/releases.log
    }

    print $"== release ($tag) complete =="
}
