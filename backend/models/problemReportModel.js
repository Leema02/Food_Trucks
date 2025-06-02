const mongoose = require("mongoose");

const problemReportSchema = new mongoose.Schema({
  user_id: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
  role: { type: String, enum: ['customer', 'truck owner'], required: true },
  category: { type: String, enum: ['Bug', 'Order Issue', 'Menu Problem', 'Other'], required: true },
  subject: { type: String, required: true },
  description: { type: String, required: true },
  status: { type: String, enum: ['pending', 'in progress', 'resolved'], default: 'pending' },
  admin_response: { type: String, default: '' },
}, {
      timestamps: true,
    toJSON: {
      transform: function (doc, ret) {
        delete ret.__v;
        return ret;
      }
    }
});

module.exports = mongoose.model("ProblemReport", problemReportSchema);
