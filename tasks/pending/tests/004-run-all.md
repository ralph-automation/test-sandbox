Create `src/tests/run-all.sh` — a test runner script:

1. Print "=== Running All Tests ==="
2. Find all .sh files in src/tests/ except run-all.sh itself
3. Run each one, capture its exit code
4. Print a summary: total tests, passed, failed
5. Exit 0 if all passed, 1 if any failed

Make the script executable. Do not modify any other files.
