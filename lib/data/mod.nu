# data — Data transforms: typeof, JSON schema, format converters, encoding
# Files with `export def main` (expand, remove-diacritics) must be used directly:
#   use lib/data/expand.nu
#   use lib/data/remove-diacritics.nu

export use ./typeof.nu *
export use ./to-json-schema.nu *
export use ./from-cpuinfo.nu *
export use ./from-dmidecode.nu *
export use ./from-env.nu *
export use ./to-ini.nu *
export use ./to-number-format.nu *
export use ./base64_encode.nu *
export use ./indent.nu *
export use ./sh.nu *
