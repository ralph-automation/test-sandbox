#!/usr/bin/env bash
# worker.sh v1.0 — Agent task loop
# Usage: worker.sh <role>
# Runs on agent machines. Picks pending tasks, executes with Claude (Gemini fallback).

set -euo pipefail

ROLE="${1:?Usage: worker.sh <role>}"
PROJECT_DIR="$HOME/project"
TASKS_DIR="$PROJECT_DIR/tasks"
RESULTS_DIR="$PROJECT_DIR/results"
SCRIPTS_DIR="$PROJECT_DIR/scripts"
STOP_HOUR=6
MAX_TASKS=10
MAX_RETRIES=3
TASK_TIMEOUT=30m

# Load API key
ENV_FILE="$HOME/.env"
if [[ -f "$ENV_FILE" ]]; then
    set -a; source "$ENV_FILE"; set +a
fi

# Find Claude binary
CLAUDE_BIN=""
for candidate in "$HOME/node_modules/.bin/claude" "$(command -v claude 2>/dev/null || true)"; do
    if [[ -n "$candidate" && -x "$candidate" ]]; then
        CLAUDE_BIN="$candidate"
        break
    fi
done

GEMINI_BIN="$(command -v gemini 2>/dev/null || true)"

log() { echo "[worker/$ROLE] $(date '+%H:%M:%S') $*"; }

pick_task() {
    local pending_dir="$TASKS_DIR/pending/$ROLE"
    [[ -d "$pending_dir" ]] || return 1
    local task
    task=$(find "$pending_dir" -name '*.md' -type f 2>/dev/null | sort | head -1)
    [[ -n "$task" ]] && echo "$task" || return 1
}

claim_task() {
    local task_file="$1"
    local task_name
    task_name=$(basename "$task_file")
    local in_progress_dir="$TASKS_DIR/in-progress/$ROLE"
    mkdir -p "$in_progress_dir"
    mv "$task_file" "$in_progress_dir/$task_name"
    echo "$in_progress_dir/$task_name"
}

execute_task() {
    local task_file="$1"
    local task_name
    task_name=$(basename "$task_file" .md)
    local result_file="$RESULTS_DIR/$ROLE/$task_name.md"
    mkdir -p "$(dirname "$result_file")"

    local prompt
    prompt=$(cat "$task_file")

    # Try Claude first
    if [[ -n "$CLAUDE_BIN" && -n "${ANTHROPIC_API_KEY:-}" ]]; then
        log "Running Claude on $task_name"
        local output
        if output=$(timeout "$TASK_TIMEOUT" setsid "$CLAUDE_BIN" -p "$prompt" --dangerously-skip-permissions 2>&1); then
            echo "$output" > "$result_file"
            return 0
        fi
        log "Claude failed on $task_name"
    fi

    # Gemini fallback
    if [[ -n "$GEMINI_BIN" ]]; then
        log "Falling back to Gemini on $task_name"
        local output
        if output=$(timeout "$TASK_TIMEOUT" setsid "$GEMINI_BIN" -p "$prompt" 2>&1); then
            echo "$output" > "$result_file"
            return 0
        fi
        log "Gemini failed on $task_name"
    fi

    log "All AI tools failed on $task_name"
    return 1
}

complete_task() {
    local task_file="$1"
    local task_name
    task_name=$(basename "$task_file")
    local done_dir="$TASKS_DIR/done/$ROLE"
    mkdir -p "$done_dir"
    mv "$task_file" "$done_dir/$task_name"
}

get_retry_count() {
    local task_name="$1"
    local marker="$TASKS_DIR/.retries/$ROLE/$task_name"
    if [[ -f "$marker" ]]; then cat "$marker"; else echo "0"; fi
}

increment_retry() {
    local task_name="$1"
    local marker_dir="$TASKS_DIR/.retries/$ROLE"
    mkdir -p "$marker_dir"
    local count
    count=$(get_retry_count "$task_name")
    echo "$((count + 1))" > "$marker_dir/$task_name"
}

clear_retry() {
    local task_name="$1"
    rm -f "$TASKS_DIR/.retries/$ROLE/$task_name"
}

fail_task() {
    local task_file="$1"
    local task_name
    task_name=$(basename "$task_file")
    increment_retry "$task_name"
    local retries
    retries=$(get_retry_count "$task_name")

    if (( retries >= MAX_RETRIES )); then
        # Give up — move to failed/
        local failed_dir="$TASKS_DIR/failed/$ROLE"
        mkdir -p "$failed_dir"
        mv "$task_file" "$failed_dir/$task_name"
        log "GAVE UP on $task_name after $retries attempts (moved to failed/)"
    else
        # Move back to pending for retry
        local pending_dir="$TASKS_DIR/pending/$ROLE"
        mkdir -p "$pending_dir"
        mv "$task_file" "$pending_dir/$task_name"
    fi
}

push_results() {
    cd "$PROJECT_DIR"
    local branch
    branch=$(git rev-parse --abbrev-ref HEAD)
    git add -A
    git commit -m "[$ROLE] Task results" 2>/dev/null || true
    bash "$SCRIPTS_DIR/safe-push.sh" "$branch"
}

# --- Startup recovery: move orphaned in-progress tasks back to pending ---
recover_orphaned() {
    local ip_dir="$TASKS_DIR/in-progress/$ROLE"
    [[ -d "$ip_dir" ]] || return 0
    local count=0
    for f in "$ip_dir"/*.md; do
        [[ -f "$f" ]] || continue
        local task_name
        task_name=$(basename "$f")
        mkdir -p "$TASKS_DIR/pending/$ROLE"
        mv "$f" "$TASKS_DIR/pending/$ROLE/$task_name"
        count=$((count + 1))
    done
    if [[ $count -gt 0 ]]; then log "Recovered $count orphaned tasks"; fi
}

# --- Main loop ---
log "Starting (project: $PROJECT_DIR)"

if [[ -z "$CLAUDE_BIN" && -z "$GEMINI_BIN" ]]; then
    log "FATAL: No AI tool available (need claude or gemini)"
    exit 1
fi

recover_orphaned
tasks_done=0

while true; do
    # Stop at STOP_HOUR (6 AM) — only if we're in the morning window (past midnight)
    current_hour=$(date +%H)
    if (( 10#$current_hour >= STOP_HOUR && 10#$current_hour < 12 )); then
        log "Stop hour reached ($STOP_HOUR:00), shutting down"
        break
    fi

    # Stop after MAX_TASKS
    if (( tasks_done >= MAX_TASKS )); then
        log "Max tasks reached ($MAX_TASKS), shutting down"
        break
    fi

    task_file=$(pick_task) || {
        log "No pending tasks, waiting 60s..."
        sleep 60
        continue
    }

    task_name=$(basename "$task_file")
    log "Picked: $task_name"

    claimed=$(claim_task "$task_file")

    if execute_task "$claimed"; then
        complete_task "$claimed"
        clear_retry "$task_name"
        log "Completed: $task_name"
        tasks_done=$((tasks_done + 1))
        push_results
    else
        fail_task "$claimed"
        log "Failed: $task_name (retry $(get_retry_count "$task_name")/$MAX_RETRIES)"
    fi
done

push_results
log "Done. Completed $tasks_done tasks."
