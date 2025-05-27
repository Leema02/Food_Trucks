const mongoose = require('mongoose');

const eventBookingSchema = new mongoose.Schema({
  event_start_date: {
    type: Date,
    required: true
  },
  event_end_date: {
    type: Date,
    required: true
  },
  start_time: {
    type: String,
    required: true
  },
  end_time: {
    type: String,
    required: true
  },
  occasion_type: {
    type: String,
    required: true
  },
  status: {
    type: String,
    enum: ['pending', 'confirmed', 'rejected'],
    default: 'pending'
  },
  location: {
    type: String,
    required: true
  },
  city: {
    type: String,
    required: true
  },
  guest_count: {
    type: Number,
    required: true
  },
  special_requests: {
    type: String
  },
  total_amount: {
    type: Number,
    required: true
  },
  truck_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Truck',
    required: true
  },
  user_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  }
}, {
  timestamps: true,
  toJSON: {
    transform: (doc, ret) => {
      delete ret.__v;
      delete ret.createdAt;
      delete ret.updatedAt;
      return ret;
    }
  }
});

module.exports = mongoose.model('EventBooking', eventBookingSchema);
