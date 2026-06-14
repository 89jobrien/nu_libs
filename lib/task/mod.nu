# task — Productivity: task runner, todo, history, bookmarks, host/path updates
# Files with `export def main` (after, just) must be used directly:
#   use lib/task/after.nu
#   use lib/task/just.nu

export use ./task.nu *
# todo.nu uses old closure syntax ({|$it, n|} → needs {|it, n|}), use directly after fixing
# history.nu is a keybinding config record, not a module
# current_session_history_menu.nu is a keybinding config record, not a module
export use ./update-path.nu *
export use ./update_hosts.nu *
export use ./bm.nu *
