#!/usr/bin/env bash

LOG_FILE="${1:-logs/worker.log}"

echo "=== Log Summary ==="

total=$(wc -l < "$LOG_FILE")
completed=$(grep -c "Completed:" "$LOG_FILE" || true)
failed=$(grep -c "Failed:" "$LOG_FILE" || true)
errors=$(grep -c "ERROR" "$LOG_FILE" || true)

echo "Total lines: $total"
echo "Completed: $completed"
echo "Failed: $failed"
echo "ERROR: $errors"

echo "--- Last 5 lines ---"
tail -5 "$LOG_FILE"

exit 0
