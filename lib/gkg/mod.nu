# gkg — Knowledge Graph and .kgx wiki helpers
# Requires: gkg server running on localhost:27495
#
# Usage:
#   use /Users/joe/dev/nu_libs/lib/gkg/mod.nu *
#
# Commands:
#   gkg index       — index a repo
#   gkg stats       — get graph stats for a project
#   gkg search      — search symbols in the graph
#   gkg status      — check server reachability and index status
#   gkg list-defs   — list definitions (optionally filtered by type)
#   kgx list        — list .kgx wiki entries
#   kgx read        — read a single wiki entry
#   kgx write       — write a wiki entry (creates or overwrites)
#   kgx reindex     — rebuild .kgx/wiki/index.md from disk
#   kgx verify      — check that expected slugs exist in .kgx/wiki/

export use ./gkg.nu *
export use ./kgx.nu *
