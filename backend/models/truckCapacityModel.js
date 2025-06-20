// models/TruckCapacity.js
const mongoose = require('mongoose');
const { Schema } = mongoose;

const TruckCapacitySchema = new Schema({
  truckId: {
    type: Schema.Types.ObjectId,
    ref: 'Truck',
    required: true,
    unique: true
  },
  maxConcurrent: {
    type: Number,
    required: true
  }
}, { timestamps: true,
        toJSON: {
      transform: function (doc, ret) {
        delete ret.__v;
        delete ret.updatedAt;
        //delete ret.createdAt;
        return ret;
      }
    }
 });

module.exports = mongoose.model('TruckCapacity', TruckCapacitySchema);
