const axios = require('axios');
const TruckReview = require('../models/truckReviewModel');

// 🌟 Helper: Analyze sentiment using Gemini

// 🧠 Smarter Gemini prompt & parsing
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


    const raw = response.data.candidates?.[0]?.content?.parts?.[0]?.text?.toLowerCase().trim();
    console.log("🧠 Gemini raw response:", raw);

    let sentiment = 'neutral';

    if (raw === 'positive') sentiment = 'positive';
    else if (raw === 'negative') sentiment = 'negative';
    else if (raw === 'neutral') sentiment = 'neutral';

    return { sentiment, sentiment_score: 1 }; // ✅ you can later replace with real scoring
  } catch (err) {
    console.error('❌ Gemini sentiment analysis failed:', err.message);
    return { sentiment: 'neutral', sentiment_score: 0 };
  }
};

// 🚀 POST /api/reviews/truck
const addTruckReview = async (req, res) => {
  const { truck_id, rating, comment, order_id } = req.body; 

  const customer_id = req.user._id;

  try {
    const existing = await TruckReview.findOne({ customer_id, truck_id, order_id });

    if (existing) {
      return res.status(400).json({ message: "You already reviewed this truck." });
    }

    const { sentiment, sentiment_score } = await analyzeSentimentWithGemini(comment || '');

    const review = await TruckReview.create({
      customer_id,
      truck_id,
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

// 🟡 GET /api/reviews/truck/:truckId
const getTruckReviews = async (req, res) => {
  try {
    const reviews = await TruckReview.find({ truck_id: req.params.truckId })
      .populate('customer_id', 'F_name L_name');
    res.json(reviews);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// ✅ GET /api/reviews/truck/check/:orderId/:truckId
const checkTruckRated = async (req, res) => {
  const { orderId, truckId } = req.params;
  const customer_id = req.user._id;

  try {
    const existing = await TruckReview.findOne({
      customer_id,
      truck_id: truckId,
      order_id: orderId
    });

    res.status(200).json({ isRated: !!existing });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};


module.exports = { addTruckReview, getTruckReviews,checkTruckRated };
