# kgx — .kgx wiki helpers
# Read, verify, and write entries in the .kgx/wiki/ knowledge base.
# The .kgx/ layout:
#   .kgx/wiki/entity/  — one file per concept/crate/component
#   .kgx/wiki/summary/ — longer multi-section documents
#   .kgx/wiki/topic/   — overview topics
#   .kgx/wiki/index.md — generated index of all entries
#   .kgx/wiki/log.md   — append-only write log

# Resolve the .kgx root for a given repo path.
export def kgx-root [repo: string = "."]: nothing -> string {
    $"($repo | path expand)/.kgx"
}

# TODO(review): Validate section and slug inputs before constructing paths. Section should be
# restricted to known wiki directories, and slugs should reject path separators, `..`, and empty
# components so read/write/verify cannot escape `.kgx/wiki/<section>/`.

# List all entries of a given section (entity, summary, topic).
export def "kgx list" [
    section: string = "entity"  # entity | summary | topic
    --repo (-r): string = "."
]: nothing -> table {
    let dir = $"(kgx-root $repo)/wiki/($section)"
    if not ($dir | path exists) {
        return []
    }
    ls $dir | where type == "file" | select name | rename path | each {|row|
        {
            name: ($row.path | path basename | str replace ".md" "")
            path: $row.path
        }
    }
}

# Read a single wiki entry by section and slug.
export def "kgx read" [
    slug: string        # Entry slug (filename without .md)
    --section (-s): string = "entity"
    --repo (-r): string = "."
]: nothing -> string {
    let f = $"(kgx-root $repo)/wiki/($section)/($slug).md"
    if not ($f | path exists) {
        error make { msg: $"kgx: entry not found: ($f)" }
    }
    open $f
}

# Write (create or overwrite) a wiki entry, appending to log.md.
export def "kgx write" [
    slug: string          # Entry slug
    content: string       # Markdown content
    --section (-s): string = "entity"
    --repo (-r): string = "."
]: nothing -> nothing {
    let dir = $"(kgx-root $repo)/wiki/($section)"
    mkdir $dir
    let f = $"($dir)/($slug).md"
    $content | save --force $f
    let log = $"(kgx-root $repo)/wiki/log.md"
    $"- write: ($slug)\n" | save --append $log
}

# Rebuild index.md from actual files on disk.
export def "kgx reindex" [
    --repo (-r): string = "."
]: nothing -> nothing {
    let root = $"(kgx-root $repo)/wiki"
    let sections = ["summary" "entity" "topic"]
    mut lines = ["# Wiki Index\n"]
    for section in $sections {
        let dir = $"($root)/($section)"
        if not ($dir | path exists) { continue }
        let entries = ls $dir | where type == "file" | each {|row|
            let slug = ($row.name | path basename | str replace ".md" "")
            $"- [($slug)](($section)/($slug).md)"
        } | sort
        if ($entries | length) > 0 {
            $lines = ($lines | append $"\n## ($section | str capitalize)\n")
            $lines = ($lines | append $entries)
        }
    }
    $lines | str join "\n" | save --force $"($root)/index.md"
}

# Verify that a set of expected entity slugs all have files in .kgx/wiki/entity/.
# Returns a table of {slug, exists} for any missing entries.
export def "kgx verify" [
    ...slugs: string    # Expected entity slugs
    --repo (-r): string = "."
    --section (-s): string = "entity"
]: nothing -> table {
    $slugs | each {|slug|
        let f = $"(kgx-root $repo)/wiki/($section)/($slug).md"
        { slug: $slug exists: ($f | path exists) }
    }
}
