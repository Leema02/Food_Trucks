// clearDB.js
const mongoose = require('mongoose');
require('dotenv').config({ path: '../.env' });

const User = require('../models/userModel');
const Truck = require('../models/truckModel');
const MenuItem = require('../models/menuModel');
const Order = require('../models/orderModel');
const EventBooking = require('../models/eventBookingModel');
const TruckReview = require('../models/truckReviewModel');
const MenuItemReview = require('../models/menuItemReviewModel');

const MONGO_URI = process.env.MONGO_URI || 'mongodb://localhost:27017/foodtrucks';

async function clearDatabase() {
  try {
    await mongoose.connect(MONGO_URI);
    console.log('🧹 Connected to MongoDB...');

    await Promise.all([
      User.deleteMany({}),
      Truck.deleteMany({}),
      MenuItem.deleteMany({}),
      Order.deleteMany({}),
      EventBooking.deleteMany({}),
      TruckReview.deleteMany({}),
      MenuItemReview.deleteMany({})
    ]);

    console.log('✅ All collections cleared.');
    process.exit();
  } catch (err) {
    console.error('❌ Failed to clear DB:', err);
    process.exit(1);
  }
}

clearDatabase();
