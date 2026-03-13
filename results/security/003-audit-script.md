`src/security/audit.sh` created, executable, and committed. It:

- Scans all files excluding `.git/`, `node_modules/`, and `.env`
- Matches `sk-ant-`, `ghp_`, `password=`, `PASSWORD=`
- Prints `WARNING: <file>:<line>:<content>` per match
- Prints `X potential secrets found`
- Exits 1 if any found, 0 if clean
