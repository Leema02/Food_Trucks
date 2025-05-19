
const mongoose = require('mongoose');

const truckSchema = new mongoose.Schema({
  owner_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  truck_name: { type: String, required: true },
  cuisine_type: { type: String, required: true },
  description: { type: String },
  logo_image_url: { type: String }, // optional logo
    city: {
    type: String,
    required: true,
    enum: [
      'Ramallah', 'Nablus', 'Bethlehem', 'Hebron', 'Jericho',
      'Tulkarm', 'Jenin', 'Qalqilya', 'Salfit', 'Tubas', 'Gaza'
    ]
  },

  location: {
    latitude: Number,
    longitude: Number,
    address_string: String
  },
  operating_hours: {
    open: String,  // e.g., "10:00 AM"
    close: String
  },
   unavailable_dates: [{ type: Date }]
},{
    timestamps: true,
    toJSON: {
      transform: function (doc, ret) {
        delete ret.__v;
        delete ret.updatedAt;
        delete ret.createdAt;
        return ret;
      }
    }
  });

module.exports = mongoose.model('Truck', truckSchema);
