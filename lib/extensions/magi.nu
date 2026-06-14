# magi.nu — Nu wrappers for the magi RL pipeline
# Requires: uv, magi repo at $env.MAGI_DIR (default ~/dev/magi)
#
# Usage:
#   use /Users/joe/dev/nu_libs/lib/extensions/magi.nu *

export-env {
    if "MAGI_DIR" not-in $env {
        $env.MAGI_DIR = ($env.HOME | path join "dev" "magi")
    }
}

def magi-dir [] { $env.MAGI_DIR }
def magi-pid-file [] { "/tmp/magi-loop.pid" }
def magi-log-file [] { "/tmp/magi-loop.log" }

def magi-run [script: string, ...args: string] {
    let dir = magi-dir
    uv run --project $dir python ($dir | path join "scripts" $script) ...$args
}

# Check whether the magi loop daemon is running; returns true/false
def magi-is-running [] {
    let pid_file = magi-pid-file
    if not ($pid_file | path exists) { return false }
    let pid = open $pid_file | str trim
    (ps | where pid == ($pid | into int) | length) > 0
}

# Start the magi loop daemon in the background
export def magi-start [
    --once         # run one cycle then exit (no daemon)
    --interval: int  # override loop interval in seconds
] {
    if (magi-is-running) {
        let pid = open (magi-pid-file) | str trim
        print $"magi is already running (pid ($pid))"
        return
    }
    let dir = magi-dir
    let log = magi-log-file
    let pid_file = magi-pid-file
    let script = ($dir | path join "scripts" "loop.py")
    let extra = (
        []
        | if $once { append "--once" } else { $in }
        | if $interval != null { append ["--interval" ($interval | into string)] } else { $in }
    )
    let cmd = $"cd ($dir) && uv run python ($script) ($extra | str join ' ') >> ($log) 2>&1 & echo $! > ($pid_file)"
    bash -c $cmd
    sleep 500ms
    if (magi-is-running) {
        let pid = open $pid_file | str trim
        print $"magi started (pid ($pid)) — logs: ($log)"
    } else {
        print $"magi failed to start — check ($log)"
    }
}

# Stop the magi loop daemon (SIGTERM — waits for current cycle to finish)
export def magi-stop [] {
    if not (magi-is-running) {
        print "magi is not running"
        return
    }
    let pid = open (magi-pid-file) | str trim
    bash -c $"kill ($pid)"
    print $"sent SIGTERM to magi (pid ($pid)) — waiting for clean shutdown..."
    let pid_file = magi-pid-file
    mut waited = 0
    loop {
        sleep 1sec
        $waited = $waited + 1
        if not (magi-is-running) {
            rm -f $pid_file
            print $"magi stopped after ($waited)s"
            break
        }
        if $waited >= 30 {
            print $"magi did not stop after 30s — sending SIGKILL"
            bash -c $"kill -9 ($pid)"
            rm -f $pid_file
            break
        }
    }
}

# Show daemon status: running/stopped, pid, log tail
export def magi-ps [] {
    let running = magi-is-running
    let pid_file = magi-pid-file
    let log = magi-log-file
    let pid = if ($pid_file | path exists) { open $pid_file | str trim } else { "—" }
    let status = if $running { "running" } else { "stopped" }
    print $"status : ($status)"
    print $"pid    : ($pid)"
    print $"log    : ($log)"
    if ($log | path exists) {
        print $"--- last 10 log lines ---"
        open $log | lines | last 10 | each { print $in }
    }
}

# Tail the magi loop log live
export def magi-logs [
    --lines(-n): int = 40  # initial lines to show before following
] {
    let log = magi-log-file
    if not ($log | path exists) {
        print "no log file yet — has magi been started?"
        return
    }
    bash -c $"tail -n ($lines) -f ($log)"
}

# Show the magi training dashboard (one-shot)
export def magi-dashboard [
    --watch(-w)          # refresh continuously
    --interval(-i): int = 10  # refresh interval in seconds (with --watch)
] {
    let dir = magi-dir
    let script = ($dir | path join "scripts" "dashboard.py")
    if $watch {
        uv run --project $dir python $script --watch --interval $interval
    } else {
        uv run --project $dir python $script
    }
}

# Run interact stage — samples tasks and records interactions to DB
export def magi-interact [] {
    magi-run "interact.py"
}

# Run score stage — scores unscored interactions
export def magi-score [] {
    magi-run "score.py"
}

# Run prompt RL stage — updates system prompt and few-shot pool
export def magi-rl-prompt [] {
    magi-run "rl_prompt.py"
}

# Run weight RL stage — fine-tunes weights when threshold is met
export def magi-rl-weights [] {
    magi-run "rl_weights.py"
}

# Run full pipeline loop (one iteration: interact → score → rl_prompt → maybe rl_weights)
export def magi-loop [] {
    magi-run "loop.py"
}

def cmpl-reconcile-mode [] { ["prompt", "weight"] }

# Reconcile modelcard after a prompt or weight RL run
export def magi-reconcile [
    mode: string@cmpl-reconcile-mode  # "prompt" or "weight"
] {
    magi-run "reconcile.py" "--mode" $mode
}

# Show recent interaction stats from the rewards DB
export def magi-status [
    --limit(-n): int = 20  # number of recent interactions to show
] {
    let db = (magi-dir | path join "db" "rewards.db")
    open $db
    | query db $"
        SELECT task_id, round(reward, 3) as reward, round(rule_score, 3) as rule,
               round(embed_score, 3) as embed, round(judge_score, 3) as judge,
               created_at
        FROM interactions
        ORDER BY created_at DESC
        LIMIT ($limit)
    "
}

# Show prompt update history
export def magi-prompt-history [
    --limit(-n): int = 10
] {
    let db = (magi-dir | path join "db" "rewards.db")
    open $db
    | query db $"
        SELECT id, round(mean_reward, 3) as mean_reward, few_shot_count,
               created_at
        FROM prompt_updates
        ORDER BY created_at DESC
        LIMIT ($limit)
    "
}

# Show weight training run history
export def magi-weight-history [
    --limit(-n): int = 5
] {
    let db = (magi-dir | path join "db" "rewards.db")
    open $db
    | query db $"
        SELECT id, status, interaction_count, base_model, output_model, created_at
        FROM weight_runs
        ORDER BY created_at DESC
        LIMIT ($limit)
    "
}

# Chat with gemma-lg via Ollama (oneshot by default)
export def magi-chat [
    message: string
    --multi-turn(-m)  # keep conversation history across calls
    --image(-i): string  # path to image (vision mode)
] {
    let base = "http://localhost:11434"
    let img = if ($image | is-empty) {
        {}
    } else {
        {images: [(open $image | encode base64)]}
    }
    let r = http post -t application/json $"($base)/api/generate" ({
        model: "gemma-lg"
        prompt: $message
        stream: false
    } | merge $img)
    $r.response
}
