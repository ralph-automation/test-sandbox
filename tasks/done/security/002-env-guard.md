Create two files:

1. `.env.example` in the project root with:
```
ANTHROPIC_API_KEY=sk-ant-your-key-here
```

2. Verify `.gitignore` exists and contains `.env`. If `.gitignore` doesn't exist, create it with:
```
.env
node_modules/
*.log
```

If `.gitignore` exists but doesn't have `.env`, add it. Do not modify any other files.
