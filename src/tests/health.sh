#!/bin/bash
echo "=== Health Check ==="

PASS=0

if [ -f "src/backend/hello.js" ]; then
    echo "src/backend/hello.js: PASS"
else
    echo "src/backend/hello.js: FAIL"
    PASS=1
fi

if [ -f "src/frontend/index.html" ]; then
    echo "src/frontend/index.html: PASS"
else
    echo "src/frontend/index.html: FAIL"
    PASS=1
fi

exit $PASS
