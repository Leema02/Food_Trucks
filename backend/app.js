require("dotenv").config(); // Load .env file
const express = require("express");
const connectDB = require("./config/db");
const bodyParser = require("body-parser");
const path = require("path");
const cors = require("cors");

const app = express();
const PORT = process.env.PORT || 5000;

// Connect to MongoDB
connectDB();

// Middleware setup
app.use(bodyParser.json()); // Parse JSON request bodies
app.use(cors());

const userRoutes = require("./routes/userRoutes");
const truckRoutes = require("./routes/truckRoutes");
const uploadRoutes = require("./routes/uploadRoutes");
const menuRoutes = require("./routes/menuRoutes");
const orderRoutes = require("./routes/orderRoutes");
const eventBookingRoutes = require("./routes/eventBookingRoutes");
const paymentRoutes = require("./routes/paymentRoutes");
const adminRoutes = require("./routes/adminRoutes");
const reviewRoutes = require('./routes/reviewRoutes');
const reportRoutes = require('./routes/reportRoutes');

app.use("/api/users", userRoutes);
app.use("/api/trucks", truckRoutes);
app.use("/api/upload", uploadRoutes);
app.use("/api/menu", menuRoutes);
app.use("/api/orders", orderRoutes);
app.use("/api/bookings", eventBookingRoutes);
app.use("/api/payments", paymentRoutes);
app.use("/api/admin", adminRoutes);
app.use('/api/reviews', reviewRoutes);
app.use('/api/reports', reportRoutes);

// Make uploads folder public
app.use("/uploads", express.static(path.join(__dirname, "/uploads")));

// Start the server
app.listen(PORT, () => {
  console.log(`Server is running on port http://localhost:${PORT}`);
});
