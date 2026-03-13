Create `src/tests/validate-json.sh` — a bash script that:

1. Prints "=== JSON Validation ==="
2. Checks if `src/backend/package.json` exists
3. If it exists, use python3 -m json.tool to validate it is valid JSON
4. Print PASS if valid, FAIL if invalid or missing
5. Exit 0 on pass, 1 on fail

Make the script executable. Do not modify any other files.
