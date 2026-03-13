#!/usr/bin/env bash

echo "=== Security Audit ==="

count=0

while IFS= read -r line; do
    echo "WARNING: $line"
    count=$((count + 1))
done < <(grep -rn \
    --exclude-dir=.git \
    --exclude-dir=node_modules \
    --exclude=".env" \
    -e "sk-ant-" \
    -e "ghp_" \
    -e "password=" \
    -e "PASSWORD=" \
    . 2>/dev/null | grep -v "^Binary")

echo "$count potential secrets found"

[ "$count" -gt 0 ] && exit 1
exit 0
