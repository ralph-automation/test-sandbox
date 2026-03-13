Create `src/security/audit.sh` — a bash script that scans for potential secrets:

1. Print "=== Security Audit ==="
2. Search all files (excluding .git/, node_modules/, .env) for patterns:
   - "sk-ant-" (Anthropic API keys)
   - "ghp_" (GitHub tokens)
   - "password=" or "PASSWORD=" (hardcoded passwords)
3. For each match, print WARNING with filename and line number
4. Print summary: "X potential secrets found"
5. Exit 1 if any found, 0 if clean

Make the script executable. Do not modify any other files.
