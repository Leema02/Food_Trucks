const axios = require('axios');
const MenuItemReview = require('../models/menuItemReviewModel');

// Helper to analyze sentiment via Gemini
const analyzeSentimentWithGemini = async (text) => {
  try {
    const response = await axios.post(
      
      `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=${process.env.GEMINI_API_KEY}`,
      {
        contents: [
          {
            parts: [
              {
                text: `Only reply with one of these words: Positive, Neutral, or Negative.\n\nReview: "${text}"`
              }
            ]
          }
        ]
      }
    );

    const raw = response.data.candidates?.[0]?.content?.parts?.[0]?.text?.toLowerCase() || 'neutral';
    let sentiment = 'neutral';
    if (raw.includes('positive')) sentiment = 'positive';
    else if (raw.includes('negative')) sentiment = 'negative';

    return { sentiment, sentiment_score: 1 }; // Optional: you can parse score if supported
  } catch (err) {
    console.error('Sentiment analysis failed:', err.message);
    return { sentiment: 'neutral', sentiment_score: 0 };
  }
};

// POST /api/reviews/menu
const addMenuItemReview = async (req, res) => {
  const { menu_item_id, order_id, rating, comment } = req.body;
  const customer_id = req.user._id;

  try {
    const existing = await MenuItemReview.findOne({ customer_id, menu_item_id, order_id });
    if (existing) {
      return res.status(400).json({ message: "You already reviewed this item in this order." });
    }

    const { sentiment, sentiment_score } = await analyzeSentimentWithGemini(comment || '');

    const review = await MenuItemReview.create({
      customer_id,
      menu_item_id,
      order_id,
      rating,
      comment,
      sentiment,
      sentiment_score
    });

    res.status(201).json(review);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// GET /api/reviews/menu/:menuItemId
const getMenuItemReviews = async (req, res) => {
  try {
    const reviews = await MenuItemReview.find({ menu_item_id: req.params.menuItemId })
      .populate('customer_id', 'F_name L_name');
    res.json(reviews);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

module.exports = { addMenuItemReview, getMenuItemReviews };
