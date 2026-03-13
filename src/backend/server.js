const express = require('express');
const cors = require('cors');

const app = express();

app.use(cors());

app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

app.get('/api/hello/:name', (req, res) => {
  res.json({ message: `Hello, ${req.params.name}!` });
});

app.listen(3002, '0.0.0.0', () => {
  console.log('Server listening on port 3002');
});
