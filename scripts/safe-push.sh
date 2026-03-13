#!/usr/bin/env bash
# safe-push.sh v1.0 — Git push with exponential backoff
# Usage: safe-push.sh [branch]
# Branch defaults to current branch if not specified.

set -euo pipefail

BRANCH="${1:-$(git rev-parse --abbrev-ref HEAD)}"
MAX_RETRIES=5
DELAY=5

for attempt in $(seq 1 "$MAX_RETRIES"); do
    if git push --force-with-lease origin "$BRANCH" 2>&1; then
        echo "[safe-push] Push succeeded on attempt $attempt"
        exit 0
    fi
    echo "[safe-push] Push failed (attempt $attempt/$MAX_RETRIES), retrying in ${DELAY}s..."
    sleep "$DELAY"
    DELAY=$((DELAY * 2))
done

echo "[safe-push] FAILED after $MAX_RETRIES attempts"
exit 1
