const mongoose = require('mongoose');

const menuItemSchema = new mongoose.Schema({
  truck_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Truck',
    required: true
  },
  name: { type: String, required: true },
  description: { type: String },
  price: { type: Number, required: true },
  category: { type: String, required: true },
  image_url: { type: String },
  isAvailable: { type: Boolean, default: true },
    // New fields
  calories: { type: Number },
  isVegan: { type: Boolean, default: false },
  isSpicy: { type: Boolean, default: false }
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

module.exports = mongoose.model('MenuItem', menuItemSchema);
