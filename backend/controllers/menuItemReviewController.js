const axios = require("axios");
const MenuItemReview = require("../models/menuItemReviewModel");


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

    const raw =
      response.data.candidates?.[0]?.content?.parts?.[0]?.text?.toLowerCase() ||
      'neutral';
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
    const existing = await MenuItemReview.findOne({
      customer_id,
      menu_item_id,
      order_id,
    });
    if (existing) {
      return res
        .status(400)
        .json({ message: "You already reviewed this item in this order." });
    }

    const { sentiment, sentiment_score } = await analyzeSentimentWithGemini(
      comment || ''
    );

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
    const reviews = await MenuItemReview.find({
      menu_item_id: req.params.menuItemId,
    })
      .populate('customer_id', 'F_name L_name')
      .populate('menu_item_id', 'name'); 

    res.json(reviews);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// GET /api/reviews/menu/check/:orderId/:itemId
const checkMenuItemRated = async (req, res) => {
  const { orderId, itemId } = req.params;
  const customerId = req.user._id;

  try {
    const existing = await MenuItemReview.findOne({
      customer_id: customerId,
      order_id: orderId,
      menu_item_id: itemId,
    });

    res.status(200).json({ isRated: !!existing });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// Admin: Get all menu item reviews with pagination and filtering
const getAllMenuItemReviewsAdmin = async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const skip = (page - 1) * limit;

    const filter = {};
    if (req.query.sentiment) {
      filter.sentiment = req.query.sentiment;
    }
    if (req.query.rating) {
      filter.rating = parseInt(req.query.rating);
    }
    // You can add more filters here (e.g., by menu_item_id, customer_id)

    const totalReviews = await MenuItemReview.countDocuments(filter);
    const reviews = await MenuItemReview.find(filter)
      .populate("customer_id", "F_name L_name email_address")
      .populate({
        path: "menu_item_id",
        select: "name truck_id", 
        populate: {
          path: "truck_id",
          select: "truck_name",
        },
      })
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit);

    res.json({
      reviews,
      currentPage: page,
      totalPages: Math.ceil(totalReviews / limit),
      totalItems: totalReviews,
    });
  } catch (err) {
    console.error("Error in getAllMenuItemReviewsAdmin:", err);
    res.status(500).json({
      message: "Server error while fetching menu item reviews for admin.",
    });
  }
};

// Admin: Delete any menu item review
const deleteMenuItemReviewAdmin = async (req, res) => {
  try {
    const { id } = req.params; // Review ID
    const review = await MenuItemReview.findByIdAndDelete(id);

    if (!review) {
      return res.status(404).json({ message: "Menu item review not found" });
    }
    res.status(200).json({ message: "Menu item review deleted successfully." });
  } catch (err) {
    console.error("Error in deleteMenuItemReviewAdmin:", err);
    res
      .status(500)
      .json({ message: "Server error while deleting menu item review." });
  }
};

// Admin: Get summary statistics for menu item reviews
const getMenuItemReviewStatsAdmin = async (req, res) => {
  try {
    const stats = await MenuItemReview.aggregate([
      {
        $group: {
          _id: null,
          totalReviews: { $sum: 1 },
          averageRating: { $avg: "$rating" },
          positiveCount: {
            $sum: { $cond: [{ $eq: ["$sentiment", "positive"] }, 1, 0] },
          },
          neutralCount: {
            $sum: { $cond: [{ $eq: ["$sentiment", "neutral"] }, 1, 0] },
          },
          negativeCount: {
            $sum: { $cond: [{ $eq: ["$sentiment", "negative"] }, 1, 0] },
          },
        },
      },
      {
        $project: {
          _id: 0,
          totalReviews: 1,
          averageRating: { $round: ["$averageRating", 2] }, // Round to 2 decimal places
          positiveCount: 1,
          neutralCount: 1,
          negativeCount: 1,
        },
      },
    ]);
    res.json(
      stats[0] || {
        totalReviews: 0,
        averageRating: 0,
        positiveCount: 0,
        neutralCount: 0,
        negativeCount: 0,
      }
    );
  } catch (err) {
    console.error("Error in getMenuItemReviewStatsAdmin:", err);
    res.status(500).json({
      message: "Server error while fetching menu item review statistics.",
    });
  }
};


module.exports = {
  addMenuItemReview,
  getMenuItemReviews,
  checkMenuItemRated,
  
  getAllMenuItemReviewsAdmin,
  deleteMenuItemReviewAdmin,
  getMenuItemReviewStatsAdmin,
};
