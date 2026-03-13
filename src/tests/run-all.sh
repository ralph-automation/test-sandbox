#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== Running All Tests ==="

total=0
passed=0
failed=0

while IFS= read -r -d '' test_file; do
  total=$((total + 1))
  echo ""
  echo "--- Running: $(basename "$test_file") ---"
  if bash "$test_file"; then
    passed=$((passed + 1))
  else
    failed=$((failed + 1))
  fi
done < <(find "$SCRIPT_DIR" -maxdepth 1 -name "*.sh" ! -name "run-all.sh" -print0 | sort -z)

echo ""
echo "=== Summary: $total total, $passed passed, $failed failed ==="

[ "$failed" -eq 0 ]
