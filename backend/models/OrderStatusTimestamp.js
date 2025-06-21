// models/OrderStatusTimestamp.js
const mongoose = require('mongoose');
const { Schema } = mongoose;

const OrderStatusTimestampSchema = new Schema({
  orderId: { type: Schema.Types.ObjectId, ref: 'Order', required: true, unique: true },
  timestamps: {
    type: Map,
    of: Date,
    default: {},
  }
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

module.exports = mongoose.model('OrderStatusTimestamp', OrderStatusTimestampSchema);
