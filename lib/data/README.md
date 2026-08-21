# lib/data

Data transforms: type inspection, format converters, encoding, text shaping.

```nu
use lib/data *
```

## Commands

| Command            | From                  | Does                                                     |
| ------------------ | --------------------- | -------------------------------------------------------- |
| `typeof`           | `typeof.nu`           | Type of the input value, as a string                     |
| `structured-type`  | `typeof.nu`           | Like `typeof`, but humanized — structured types become a record, with lengths for values |
| `from cpuinfo`     | `from-cpuinfo.nu`     | Parse `/proc/cpuinfo` into structured data               |
| `from dmidecode`   | `from-dmidecode.nu`   | Parse `dmidecode` output into structured data            |
| `from env`         | `from-env.nu`         | Parse a `.env` file into a record — `open .env \| load-env` |
| `to ini`           | `to-ini.nu`           | Render a record as INI                                   |
| `number-format`    | `to-number-format.nu` | Format a number — `-t` thousands delimiter, `-w` whole-part padding, `-d` decimal digits |
| `parse sh-export`  | `sh.nu`               | Parse shell `export` statements                          |
| `parse-indent`     | `indent.nu`           | Parse indentation-structured text into nested data       |
| `base64_encode`    | `base64_encode.nu`    | Base64-encode a string (hand-rolled, no external tool)   |

## Not re-exported by `mod.nu`

| File                   | Why                                                      | Use                                |
| ---------------------- | -------------------------------------------------------- | ---------------------------------- |
| `expand.nu`            | `export def main` — bare `main` would collide            | `use lib/data/expand.nu`           |
| `remove-diacritics.nu` | same                                                     | `use lib/data/remove-diacritics.nu`|
| `to-json-schema.nu`    | Command name clashes with the module name                | `use lib/data/to-json-schema.nu *` |

```nu
use lib/data/expand.nu
expand "file{1,2,3}.txt"     # brace expansion, bash-style

use lib/data/to-json-schema.nu *
open sample.json | to-json-schema
```

## Note on `from env`

Its doc comment pins it to Nushell 0.109.1. `.env` parsing has been sensitive
to parser changes across versions — if it misbehaves, check your `version`
before assuming the file is malformed.

## Two `main`s in one module

`typeof.nu` and `base64_encode.nu` both carry `export def main`, and `mod.nu` glob-imports both. Whether
that resolves cleanly, last-wins, or errors has not been verified against a
live Nushell. If `typeof` / `base64_encode` misbehave after `use lib/data *`, load the file
directly instead — that path is unambiguous.
