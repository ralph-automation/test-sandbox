# Security Policy

## Secrets Management
- API keys go in `.env` (never committed)
- `.env.example` shows required variables without real values
- `.gitignore` must always include `.env`

## Audit
- Run `src/security/audit.sh` before each commit
- Never hardcode API keys, tokens, or passwords

## Reporting
- Report security issues to the project maintainer directly
- Do not open public issues for security vulnerabilities
