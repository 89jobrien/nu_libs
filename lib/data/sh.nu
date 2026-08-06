# Parse `export KEY=VALUE` lines from a piped-in shell script into a record.
export def "parse sh-export" [] {
    $in
    | lines
    | where {|x| not ($x | str trim  | str starts-with '#')}
    | parse -r 'export\s+(?<k>[^=]+)=(?<v>[^=]+)'
    | reduce -f {} {|x, a| $a| upsert $x.k $x.v}
}

