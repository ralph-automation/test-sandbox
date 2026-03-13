Create `src/backend/server.js` — a minimal Express.js server:

- Listen on port 3002, bind to 0.0.0.0
- GET /health returns JSON: { "status": "ok", "timestamp": <ISO timestamp> }
- GET /api/hello/:name returns JSON: { "message": "Hello, <name>!" }
- Enable CORS for all origins
- Log "Server listening on port 3002" on startup

Use only express and cors as dependencies. Do not create any other files.
