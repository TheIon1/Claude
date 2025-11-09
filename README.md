# Hello World Full-Stack Application

A complete full-stack application demonstrating a modern cloud architecture with a static frontend, serverless backend, and cloud database.

## Architecture

```
GitHub Pages (Frontend)
    ↓ (HTTP request with API key)
Vercel (Backend/API)
    ↓ (MongoDB query)
MongoDB Atlas (Database)
```

## Components

- **Frontend**: Static HTML/CSS/JavaScript hosted on GitHub Pages
- **Backend**: Node.js/Express API running on Vercel
- **Database**: MongoDB Atlas for data persistence
- **Authentication**: API key-based authentication

## Live Demo

- **Frontend**: https://theion1.github.io/Claude/
- **Backend API**: https://claude-silk-six.vercel.app/api/message

## Local Development

### Prerequisites

- Node.js 16+
- MongoDB local instance or MongoDB Atlas account

### Setup

1. Clone the repository:
```bash
git clone <repo-url>
cd Claude
```

2. Install dependencies:
```bash
npm install
```

3. Create `.env` file (optional, uses defaults):
```
MONGODB_URI=mongodb+srv://user:password@cluster.mongodb.net/hello-world?retryWrites=true&w=majority
API_KEY=test-key-12345
PORT=3000
```

4. Start the server:
```bash
npm start
```

5. Access the API:
- Health check: http://localhost:3000/api/health
- Get message: http://localhost:3000/api/message?key=test-key-12345

## Deployment

### Deploy Backend on Vercel

1. Go to [Vercel Dashboard](https://vercel.com/dashboard)
2. Click **Add New Project**
3. Import your GitHub repository
4. Configure environment variables:
   - `MONGODB_URI`: Your MongoDB Atlas connection string
   - `API_KEY`: Your API key (default: `test-key-12345`)
5. Click **Deploy**

### Deploy Frontend on GitHub Pages

1. Go to your GitHub repository settings
2. Navigate to **Pages** section
3. Under **Build and deployment**:
   - Source: Deploy from branch
   - Branch: `main`
   - Folder: `/ (root)`
4. Click **Save**

### Configure MongoDB

1. Go to [MongoDB Atlas](https://cloud.mongodb.com)
2. Create or select your cluster
3. Click **Collections** and create:
   - Database: `hello-world`
   - Collection: `messages`
4. Insert a document:
```json
{
  "_id": "default",
  "message": "hello world",
  "createdAt": new Date(),
  "updatedAt": new Date()
}
```
5. Go to **Network Access** and allow access from **0.0.0.0/0** (for Vercel)

## API Endpoints

### GET /api/message
Retrieves the message from MongoDB.

**Headers:**
- `X-API-Key: test-key-12345` (required)

**Query Parameters:**
- `key=test-key-12345` (alternative to header)

**Response:**
```json
{
  "success": true,
  "message": "hello world",
  "timestamp": "2025-11-09T20:03:23.056Z",
  "source": "MongoDB"
}
```

**Status Codes:**
- `200`: Success
- `401`: Invalid or missing API key
- `503`: Database not connected

### GET /api/health
Health check endpoint (no authentication required).

**Response:**
```json
{
  "status": "ok",
  "mongodb": "connected",
  "timestamp": "2025-11-09T20:03:23.056Z"
}
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `MONGODB_URI` | `mongodb://localhost:27017/hello-world` | MongoDB connection string |
| `API_KEY` | `test-key-12345` | API authentication key |
| `PORT` | `3000` | Server port |

## File Structure

```
├── index.html         # Frontend HTML/CSS/JavaScript
├── server.js          # Express backend
├── package.json       # Dependencies and scripts
├── vercel.json        # Vercel deployment config
├── .gitignore         # Git ignore rules
└── README.md          # This file
```

## Security Notes

⚠️ **API Key in Frontend**: The API key is hardcoded in the frontend HTML. This is acceptable for educational purposes and public APIs, but in production:
- Use environment-based keys
- Implement proper authentication (OAuth, JWT, etc.)
- Monitor API usage and rate limiting
- Regenerate keys regularly

⚠️ **MongoDB Connection**: The connection string is stored as an environment variable on Vercel and should never be committed to code.

## Troubleshooting

### API returns "Database not connected"
- Check MongoDB Atlas connection string is correct
- Verify IP whitelist includes `0.0.0.0/0`
- Check Vercel deployment logs

### CORS errors on frontend
- Verify backend is running and accessible
- Check browser console for detailed error messages
- Ensure API key header is being sent

### 401 Unauthorized
- Verify API key matches between frontend and backend
- Check that `X-API-Key` header or `key` query parameter is provided

## Technologies Used

- **Frontend**: HTML5, CSS3, JavaScript (Fetch API)
- **Backend**: Node.js, Express.js
- **Database**: MongoDB
- **Hosting**: GitHub Pages (frontend), Vercel (backend)
- **Authentication**: API Key
- **CORS**: Express CORS middleware

## License

ISC

## Author

Created as a learning project for full-stack cloud deployment.
