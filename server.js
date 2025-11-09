const express = require('express');
const cors = require('cors');

const app = express();

// Enable CORS for frontend requests
app.use(cors());

// Simple in-memory "database"
const database = {
  message: "hello world"
};

// REST API endpoint to get the message
app.get('/api/message', (req, res) => {
  res.json({
    success: true,
    message: database.message,
    timestamp: new Date().toISOString()
  });
});

// Health check endpoint
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok' });
});

// Serve static files from root
app.use(express.static('.'));

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});

module.exports = app;
