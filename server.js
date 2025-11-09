const express = require('express');
const cors = require('cors');
const path = require('path');
const fs = require('fs');
const { MongoClient } = require('mongodb');

const app = express();

// Enable CORS for frontend requests from GitHub Pages
app.use(cors({
  origin: ['https://theion1.github.io', 'http://localhost:3000', 'http://localhost:5000'],
  credentials: true,
  optionsSuccessStatus: 200,
  allowedHeaders: ['Content-Type', 'X-API-Key', 'Accept'],
  methods: ['GET', 'POST', 'OPTIONS']
}));

// MongoDB configuration
const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/hello-world';
const DB_NAME = 'hello-world';
const COLLECTION_NAME = 'messages';

let mongoClient;
let db;

// Initialize MongoDB connection
async function initMongoDB() {
  try {
    mongoClient = new MongoClient(MONGODB_URI, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
      serverSelectionTimeoutMS: 30000, // Increased to 30 seconds for Vercel cold starts
      socketTimeoutMS: 30000,
      connectTimeoutMS: 30000,
      maxPoolSize: 10,
    });

    console.log('Attempting to connect to MongoDB...');
    await mongoClient.connect();
    db = mongoClient.db(DB_NAME);
    console.log('✓ Connected to MongoDB successfully');

    // Initialize database with sample data if empty
    const collection = db.collection(COLLECTION_NAME);
    const existingMessage = await collection.findOne({});
    if (!existingMessage) {
      await collection.insertOne({
        _id: 'default',
        message: 'hello world',
        createdAt: new Date(),
        updatedAt: new Date()
      });
      console.log('✓ Initialized MongoDB with default message');
    } else {
      console.log('✓ MongoDB already has data');
    }
  } catch (error) {
    console.error('✗ MongoDB connection error:', error.message);
    // Try to reconnect after 5 seconds
    setTimeout(() => {
      console.log('Retrying MongoDB connection...');
      initMongoDB();
    }, 5000);
  }
}

// Initialize MongoDB on startup
initMongoDB();

// API key from environment variable
const API_KEY = process.env.API_KEY || 'test-key-12345';

// Middleware to check API key
const requireApiKey = (req, res, next) => {
  const providedKey = req.headers['x-api-key'] || req.query.key;

  // Debug logging
  console.log('API Key Check:');
  console.log('  Headers:', Object.keys(req.headers));
  console.log('  Provided Key:', providedKey);
  console.log('  Expected Key:', API_KEY);

  if (!providedKey || providedKey !== API_KEY) {
    return res.status(401).json({
      success: false,
      error: 'Unauthorized: Invalid or missing API key',
      debug: {
        providedKey: providedKey ? 'received' : 'missing',
        expectedKey: API_KEY,
        match: providedKey === API_KEY
      }
    });
  }

  next();
};

// REST API endpoint to get the message from MongoDB
app.get('/api/message', requireApiKey, async (req, res) => {
  try {
    if (!db) {
      return res.status(503).json({
        success: false,
        error: 'Database not connected'
      });
    }

    const collection = db.collection(COLLECTION_NAME);
    const messageDoc = await collection.findOne({ _id: 'default' });

    if (!messageDoc) {
      return res.status(404).json({
        success: false,
        error: 'Message not found'
      });
    }

    res.json({
      success: true,
      message: messageDoc.message,
      timestamp: new Date().toISOString(),
      source: 'MongoDB'
    });
  } catch (error) {
    console.error('Error fetching message:', error);
    res.status(500).json({
      success: false,
      error: 'Internal server error',
      details: error.message
    });
  }
});

// Health check endpoint (no auth required)
app.get('/api/health', (req, res) => {
  res.json({
    status: 'ok',
    mongodb: db ? 'connected' : 'disconnected',
    timestamp: new Date().toISOString()
  });
});

// Debug endpoint - check MongoDB connection status
app.get('/api/debug', (req, res) => {
  res.json({
    environment: process.env.NODE_ENV,
    mongodb_uri: process.env.MONGODB_URI ? 'configured' : 'not configured',
    db_connected: db ? true : false,
    api_key_configured: process.env.API_KEY ? 'yes' : 'using default',
    timestamp: new Date().toISOString()
  });
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
