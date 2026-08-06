# [nu_lib] `wc` wrapper returning structured lines/words/bytes (and file, if paths are given).
export def main [...rest] {
  let stdin = $in
  if ($rest | length ) > 0 {
    ^wc $rest | lines | parse -r '^\s*(?<lines>\d+)\s*(?<words>\d+)\s*(?<bytes>\d+)\s*(?<file>.*)$' 
  } else {
    $stdin | ^wc | lines | parse -r '^\s*(?<lines>\d+)\s*(?<words>\d+)\s*(?<bytes>\d+)\s*$' 
    
  }
}
