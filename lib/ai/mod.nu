export-env {
    use integration/ollama.nu *
    use call.nu *
    use function.nu *
    use data/tools/os.nu
    # web.nu uses `query web 'selector'` — API changed across nu versions, use directly if needed
    use data/tools/git.nu
    use data/tools/programming.nu
    use data/tools/clipboard.nu
    $env.AI_CONFIG = {
        finish_reason: {
            enable: true
            color: xterm_grey30
        }
        reasoning_content: {
            color: grey
            delimiter: $'(char newline)------(char newline)'
        }
        tool_calls: grey
        template_calls: xterm_fuchsia
        message_limit: 20
        permitted-write: ~/Downloads
    }
    use data/assistant/supervisor
}

export def --env hook-ai-assistant [] {
    $env.config.hooks.pre_execution ++= [
        { || $env.CURRENT_INPUT = (commandline) }
    ]

    if ($env.config.hooks.command_not_found | is-empty) {
        $env.config.hooks.command_not_found = []
    }

    $env.config.hooks.command_not_found ++= [{ |cmd|
        ai-assistant $env.CURRENT_INPUT
        ""
    }]
}

export use call.nu *
export use shortcut.nu *
export use mcp.nu *
export use clients/baml.nu *

export use integration/ollama.nu *
export use integration/local.nu *
export use integration/audio.nu *
export use list-hooks.nu *
