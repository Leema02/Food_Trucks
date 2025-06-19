// models/OrderEstimate.js
const mongoose = require('mongoose');
const { Schema } = mongoose;

const OrderEstimateSchema = new Schema({
  orderId: {
    type: Schema.Types.ObjectId,
    ref: 'Order',
    required: true,
    unique: true
  },
  // how many orders can prepare in parallel (pulled from env on creation)
  maxConcurrent: {
    type: Number,
    default: () => parseInt(process.env.MAX_CONCURRENT_ORDERS, 10) || 5
  },
  partOne: {
    type: Number, // minutes until a preparation slot frees up
    required: true
  },
  partTwo: {
    type: Number, // historical avg time to prepare this order
    required: true
  },
  estimatedTime: {
    type: Number, // partOne + partTwo
    required: true
  },
  calculatedAt: {
    type: Date,
    default: Date.now
  }
}, { timestamps: true });

module.exports = mongoose.model('OrderEstimate', OrderEstimateSchema);
