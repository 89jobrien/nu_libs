# doob — thin Nushell wrappers around the doob CLI.

const DEFAULT_PROJECT = "nu_libs"

def doob-json-prefix [json: bool]: nothing -> list<string> {
    if $json { ["--json"] } else { [] }
}

def doob-db-args [db: string]: nothing -> list<string> {
    if ($db | is-empty) { [] } else { ["--db" $db] }
}

def doob-project-args [project: string]: nothing -> list<string> {
    if ($project | is-empty) { [] } else { ["--project" $project] }
}

# List pending todos, scoped to this repo by default.
export def "doob pending" [
    --project (-p): string = $DEFAULT_PROJECT  # Project name to filter by
    --json                                     # Emit doob JSON output
    --db: string = ""                          # Override doob database path
]: nothing -> any {
    let args = (
        doob-json-prefix $json
        | append (doob-db-args $db)
        | append ["todo" "list" "--status" "pending"]
        | append (doob-project-args $project)
        | flatten
    )
    ^doob ...$args
}

# Search todos and notes, scoped to this repo by default.
export def "doob find" [
    query: string                              # Search query
    --project (-p): string = $DEFAULT_PROJECT  # Project name to filter by
    --type (-t): string = "all"                # todo, note, or all
    --json                                     # Emit doob JSON output
    --db: string = ""                          # Override doob database path
]: nothing -> any {
    let args = (
        doob-json-prefix $json
        | append (doob-db-args $db)
        | append ["search" $query "--type" $type]
        | append (doob-project-args $project)
        | flatten
    )
    ^doob ...$args
}

# List doob handoff items.
export def "doob handoff list" [
    --json             # Emit doob JSON output
    --db: string = ""  # Override doob database path
]: nothing -> any {
    let args = (
        doob-json-prefix $json
        | append (doob-db-args $db)
        | append ["handoff" "list"]
        | flatten
    )
    ^doob ...$args
}

# Sync HANDOFF state through doob.
export def "doob handoff sync" [
    --json             # Emit doob JSON output
    --db: string = ""  # Override doob database path
]: nothing -> any {
    let args = (
        doob-json-prefix $json
        | append (doob-db-args $db)
        | append ["handoff" "sync"]
        | flatten
    )
    ^doob ...$args
}

# List notes.
export def "doob note list" [
    --json             # Emit doob JSON output
    --db: string = ""  # Override doob database path
]: nothing -> any {
    let args = (
        doob-json-prefix $json
        | append (doob-db-args $db)
        | append ["note" "list"]
        | flatten
    )
    ^doob ...$args
}

# Add a note.
export def "doob note add" [
    text: string        # Note text
    --json              # Emit doob JSON output
    --db: string = ""   # Override doob database path
]: nothing -> any {
    let args = (
        doob-json-prefix $json
        | append (doob-db-args $db)
        | append ["note" "add" $text]
        | flatten
    )
    ^doob ...$args
}

# Pass raw arguments through to doob for subcommands not wrapped here.
export def "doob raw" [
    ...args: string  # Arguments to pass to doob
]: nothing -> any {
    ^doob ...$args
}
