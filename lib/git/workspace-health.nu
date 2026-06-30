#!/usr/bin/env nu

# Scan all git repos under ~/dev/ and report health summary.
# Sections: active (last 24h), dirty trees, extra worktrees, all repos.
#
# Usage:
#   use /Users/joe/dev/nu_libs/lib/git/workspace-health.nu *
#   workspace-health
#   workspace-health --dev-dir /path/to/dev

export def workspace-health [
    --dev-dir: string = "/Users/joe/dev"  # Root directory to scan
] {
    let repos = (ls $dev_dir | where type == dir | get name)

    let git_state = ($repos | each {|r|
        let br = (do { ^git -C $r branch --show-current } | complete)
        let branch = ($br.stdout | str trim)
        let st = (do { ^git -C $r status --short } | complete)
        let recent = (do { ^git -C $r log --since="24 hours ago" --oneline -1 } | complete)
        let wt = (do { ^git -C $r worktree list } | complete)
        {
            repo: ($r | path basename),
            branch: $branch,
            tree: (if ($st.stdout | str trim | str length) > 0 { "dirty" } else { "clean" }),
            active_24h: (if ($recent.stdout | str trim | str length) > 0 { "yes" } else { "no" }),
            worktrees: ($wt.stdout | lines | length)
        }
    } | where {|x| not ($x.branch == "") })

    print $"Total git repos: ($git_state | length)"

    print ""
    print "=== ACTIVE (last 24h) ==="
    $git_state | where {|x| $x.active_24h == "yes"} | each {|x|
        print $"  ($x.repo) @ ($x.branch) [($x.tree)]"
    }

    print ""
    print "=== DIRTY TREES ==="
    $git_state | where {|x| $x.tree == "dirty"} | each {|x|
        print $"  ($x.repo) @ ($x.branch)"
    }

    print ""
    print "=== EXTRA WORKTREES ==="
    $git_state | where {|x| $x.worktrees > 1} | each {|x|
        print $"  ($x.repo): ($x.worktrees) worktrees"
    }

    print ""
    print "=== ALL REPOS (branch / tree) ==="
    $git_state | each {|x|
        print $"  ($x.repo): ($x.branch) [($x.tree)] active=($x.active_24h)"
    }
}
