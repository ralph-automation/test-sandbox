Create `src/utility/log-parser.sh` — a bash script that parses worker log files:

1. Accept a log file path as argument (default: logs/worker.log)
2. Print "=== Log Summary ==="
3. Count and print: total lines, lines with "Completed:", lines with "Failed:", lines with "ERROR"
4. Print the last 5 lines of the log
5. Exit 0

Make the script executable. Do not modify any other files.
