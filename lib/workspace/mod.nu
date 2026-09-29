# workspace — multi-repo workspace introspection
# proj-index.nu is `export def main` and IS glob-exported (verified), so load
# the category: `use ~/dev/nu_libs/lib/workspace *` -> `proj-index`

export use ./proj-index.nu *
