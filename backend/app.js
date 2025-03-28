
require('dotenv').config();            // Load .env file
const express = require('express');
const connectDB = require('./config/db');
const bodyParser = require('body-parser');

const app = express();
const PORT = process.env.PORT || 5000;

// Connect to MongoDB
connectDB();

// Middleware setup
app.use(bodyParser.json());            // Parse JSON request bodies
app.use(bodyParser.urlencoded({ extended: true }));  // Parse URL-encoded form data

// Routes setup (auth route as an example)
//app.use('/api/auth', require('./routes/authRoutes')); 

// Start the server
app.listen(PORT, () => {
  console.log(`Server is running on port http://localhost:${PORT}`);
});
