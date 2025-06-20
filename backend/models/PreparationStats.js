const mongoose = require('mongoose');
const { Schema } = mongoose;

const PreparationStatsSchema = new Schema({
  menuItemId: { type: Schema.Types.ObjectId, ref: 'MenuItem', required: true, unique: true },
  times:      { type: [Number], default: [] },
  avgTime:    { type: Number, default: 0 }
}, { timestamps: true,
      toJSON: {
      transform: function (doc, ret) {
        delete ret.__v;
        delete ret.updatedAt;
        delete ret.createdAt;
        return ret;
      }
    }
});

module.exports = mongoose.model('PreparationStats', PreparationStatsSchema);

