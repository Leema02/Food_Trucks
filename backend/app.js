require("dotenv").config(); // Load .env file
const { Server }             = require("socket.io");
const { addUserSocket,  removeUserSocket ,sendToClient,
  getEventsStartingIn24Hours}
                             = require("./services/CustomSocketService");
                             const http                   = require("http");
const express = require("express");
const connectDB = require("./config/db");
const bodyParser = require("body-parser");
const path = require("path");
const cors = require("cors");
const cron = require('node-cron');
const app = express();
const PORT = process.env.PORT || 5000;

const server =http.createServer(app);
const io = new Server(server);
io.on('connection', (socket) => {
  
  console.log('A user connected');
  socket.on("setId",(data)=>{
    addUserSocket(data,socket)  
  });
  
  
  
  socket.on('disconnect', () => {
    console.log('User disconnected');
    removeUserSocket(socket);
});}
)

// Connect to MongoDB
connectDB();

// Middleware setup
app.use(bodyParser.json()); // Parse JSON request bodies
app.use(cors());
cron.schedule('48 * * * *', async () => {
  const events= await getEventsStartingIn24Hours();
  console.log("========================")
  console.log(events.length);
  console.log("========================")
  for(let i of events){
    sendToClient(i.user_id.toString(),"Notification",{title:"Event reminder",message:"Your event starts in 24 hours"});
    sendToClient(i.truck_id.owner_id.toString(),"Notification",{title:"Event reminder",message:"Your event starts in 24 hours"});
  }
});
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
const orderEstimateRoutes = require('./routes/orderEstimateRoutes');


app.use('/api', orderEstimateRoutes);
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
server.listen(PORT, () => {
  console.log(`Server is running on port http://localhost:${PORT}`);
});