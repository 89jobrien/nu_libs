# typeof command.  Requires Nushell version 0.88 or later

# Internal helper shared by `main` and `structured-type` to avoid calling `main` by name,
# which is fragile when the file is loaded as a module.
def _typeof [--full (-f)] {
  describe -d | if not $full { get type } else { $in }
}

# Returns the typeof a value passed into input as a string
export def main [--full (-f)] {
  _typeof --full=$full
}


# Performs typeof on input but humanizes structured types into simple type record
# value lengths are given by ints so downstream consumers do not have to
# parse string contents like in the raw output of describe -d
# E.g. { list: 2 } # list with 2 elements
# { record: 3 } # record with 3 fields
export def structured-type [] {
  let data = $in
  match ($data | _typeof --full) {
  {type: list } => { {list: ($data | length) } },
    { type: record } =>  { {record: ($data | columns | length) } },
  _ => { $data | _typeof }
  }
}
