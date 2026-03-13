#!/bin/bash

echo "=== Health Check ==="

all_pass=true

check_file() {
    if [ -f "$1" ]; then
        echo "PASS: $1"
    else
        echo "FAIL: $1"
        all_pass=false
    fi
}

check_file "src/backend/server.js"
check_file "src/frontend/index.html"
check_file "src/frontend/styles.css"

if $all_pass; then
    exit 0
else
    exit 1
fi
