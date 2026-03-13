#!/usr/bin/env bash
echo "=== JSON Validation ==="

FILE="src/backend/package.json"

if [ ! -f "$FILE" ]; then
  echo "FAIL"
  exit 1
fi

if python3 -m json.tool "$FILE" > /dev/null 2>&1; then
  echo "PASS"
  exit 0
else
  echo "FAIL"
  exit 1
fi
