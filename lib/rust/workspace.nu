# workspace — Cargo workspace discovery helpers

# Walk up from $start to find the Cargo workspace root.
# Returns the directory containing a [workspace] Cargo.toml, or "" if not found.
export def find-workspace-root [start: string] {
    mut dir = $start
    mut fallback = ""
    loop {
        let cargo = $dir | path join "Cargo.toml"
        if ($cargo | path exists) {
            let contents = open $cargo
            if ($contents | str contains "[workspace]") {
                return $dir
            } else if $fallback == "" {
                $fallback = $dir
            }
        }
        let parent = $dir | path dirname
        if $parent == $dir { break }
        $dir = $parent
    }
    $fallback
}

# True if $path ends with .rs
export def is-rust-file [path: string] {
    $path | str ends-with ".rs"
}

# True if $path ends with .nu
export def is-nu-file [path: string] {
    $path | str ends-with ".nu"
}
