const mongoose = require('mongoose');

const orderSchema = new mongoose.Schema({
  customer_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  truck_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Truck',
    required: true
  },
  items: [
    {
      menu_id: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'MenuItem',
        required: true
      },
      name: String,
      quantity: Number,
      price: Number
    }
  ],
  total_price: { type: Number, required: true },
  order_type: { type: String, enum: ['pickup', 'delivery'], default: 'pickup' },
  status: { type: String, enum: ['pending', 'preparing', 'ready', 'completed'], default: 'pending' },
}, {
    timestamps: true,
    toJSON: {
      transform: function (doc, ret) {
        delete ret.__v;
        delete ret.updatedAt;
        return ret;
      }
    }
  });

module.exports = mongoose.model('Order', orderSchema);
