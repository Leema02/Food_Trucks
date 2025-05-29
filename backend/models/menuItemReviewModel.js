const mongoose = require('mongoose');

const menuItemReviewSchema = new mongoose.Schema({
  customer_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  menu_item_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'MenuItem',
    required: true
  },
  order_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Order',
    required: true
  },
  rating: {
    type: Number,
    min: 1,
    max: 5,
    required: true
  },
  comment: {
    type: String,
    default: ''
  },
      // 🧠 New for sentiment AI
  sentiment: {   //What Gemini classifies the review as
    type: String,
    enum: ['positive', 'neutral', 'negative'],
    default: 'neutral'
  },
  sentiment_score: { //how confident Gemini is (0–1) or polarity from -1 to 1
    type: Number,
    default: 0
  }
}, { timestamps: true,
      toJSON: {
    transform: (doc, ret) => {
      delete ret.__v;
      delete ret.createdAt;
      delete ret.updatedAt;
      return ret;
    }
  }
 });


module.exports = mongoose.model('MenuItemReview', menuItemReviewSchema);
