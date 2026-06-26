# doob — repo-local todo, note, search, and handoff helpers
#
# Usage:
#   use /Users/joe/dev/nu_libs/lib/doob/mod.nu *
#
# Commands:
#   doob pending       — list pending todos for a project
#   doob find          — search todos and notes for a project
#   doob handoff list  — list handoff items
#   doob handoff sync  — sync HANDOFF state through doob
#   doob note list     — list notes
#   doob note add      — add a note
#   doob raw           — pass arguments through to the doob CLI

export use ./doob.nu *
