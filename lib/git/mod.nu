# git — Git helpers
# Files with `export def main` (bump-version) must be used directly:
#   use lib/git/bump-version.nu

export use ./git.nu *
export use ./git_branch_age.nu *
export use ./git_branch_cleanup.nu *
export use ./git_gone.nu *
export use ./clone-all.nu *
# merged-branches.nu is a script (bare pipeline), use directly: use lib/git/merged-branches.nu
export use ./git-hooks.nu *
