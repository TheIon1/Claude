const express = require('express');
const cors = require('cors');
const path = require('path');
const fs = require('fs');

const app = express();

// Enable CORS for frontend requests from GitHub Pages
app.use(cors({
  origin: ['https://theion1.github.io', 'http://localhost:3000', 'http://localhost:5000'],
  credentials: true,
  optionsSuccessStatus: 200
}));

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

// Serve static files
app.use(express.static(path.join(__dirname)));

// Serve index.html for root and other non-API routes
app.get('/', (req, res) => {
  const indexPath = path.join(__dirname, 'index.html');
  if (fs.existsSync(indexPath)) {
    res.sendFile(indexPath);
  } else {
    res.status(404).send('index.html not found');
  }
});

// Catch-all for other routes - serve index.html for SPA support
app.get('*', (req, res) => {
  const indexPath = path.join(__dirname, 'index.html');
  if (fs.existsSync(indexPath)) {
    res.sendFile(indexPath);
  } else {
    res.status(404).send('Not found');
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});

module.exports = app;
