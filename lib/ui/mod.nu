# ui — UI/shell: progress bars, completions, aliases, clipboard, notifications

# bar.nu must be used directly (command name clashes with module name):
#   use lib/ui/bar.nu *
export use ./percent_meter.nu *
export use ./completion-generator.nu *
export use ./bat-aliases.nu *
export use ./eza-aliases.nu *
export use ./clip.nu *
export use ./notify.nu *
