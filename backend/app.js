
require('dotenv').config();            // Load .env file
const express = require('express');
const connectDB = require('./config/db');
const bodyParser = require('body-parser');
const path = require('path');


const app = express();
const PORT = process.env.PORT || 5000;

// Connect to MongoDB
connectDB();

// Middleware setup
 app.use(bodyParser.json());            // Parse JSON request bodies

const userRoutes = require('./routes/userRoutes');
const truckRoutes = require('./routes/truckRoutes');
const uploadRoutes = require('./routes/uploadRoutes');


app.use('/api/users', userRoutes);
app.use('/api/trucks', truckRoutes);
app.use('/api/upload', uploadRoutes);


// Make uploads folder public
app.use('/uploads', express.static(path.join(__dirname, '/uploads')));

// Start the server
app.listen(PORT, () => {
  console.log(`Server is running on port http://localhost:${PORT}`);
});
