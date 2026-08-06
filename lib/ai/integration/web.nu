def cmpl-transform [] {
    $env.MARKDOWN_TRANSFORM | columns
}

export-env {
    $env.MARKDOWN_TRANSFORM = {
        summary: { $in | ad text-summary en -o }
    }
}

# [nu_lib] Fetch a URL, convert it to markdown, and optionally run a registered transform (e.g. summary) on the content.
export def --wrapped 'mdurl' [
    ...args
    --transform(-t): any@cmpl-transform
    --raw(-r)
] {
    let md = curl -sSL ...$args
    | ^($env.HTML_TO_MARKDOWN? | default 'html2markdown')

    let content = if ($transform | is-empty) {
        $md
    } else {
        if ($transform | describe -d).type == 'closure' {
            $md | do $transform
        } else {
            $md | do ($env.MARKDOWN_TRANSFORM | get $transform)
        }
    }

    if $raw {
        $content
    } else {
        $content | ^($env.MARKDOWN_RENDER? | default 'glow')
    }
}

