# fs — Filesystem: tree, file ops, disk, navigation
# Files with `export def main` (loc, wc) must be used directly:
#   use lib/fs/loc.nu
#   use lib/fs/wc.nu

export use ./tree.nu *
# file.nu uses relative `use nushell.nu` cross-domain — use directly after ensuring nushell.nu is in path
export use ./disk.nu *
# file_convert_naming_case.nu is a script (bare pipeline), use directly
# filesize.nu is a script (bare pipeline), use directly
export use ./find_in.nu *
export use ./ultimate_extractor.nu *
# directory.nu contains top-level record literal (keybinding config), not a module
export use ./up.nu *
export use ./cdpath.nu *
export use ./pwd-short.nu *
export use ./autojump.nu *
export use ./zoxide-menu.nu *
