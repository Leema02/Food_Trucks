const axios = require("axios");
const TruckReview = require("../models/truckReviewModel"); // Assuming this model exists and is correct

// 🌟 Helper: Analyze sentiment using Gemini
const analyzeSentimentWithGemini = async (text) => {
  try {
    const response = await axios.post(
      `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=${process.env.GEMINI_API_KEY}`,
      {
        contents: [
          {
            parts: [
              {
                text: `Only reply with one of these words: Positive, Neutral, or Negative.\n\nReview: "${text}"`,
              },
            ],
          },
        ],
      }
    );

    const raw = response.data.candidates?.[0]?.content?.parts?.[0]?.text
      ?.toLowerCase()
      .trim();
    console.log("🧠 Gemini raw response:", raw);

    let sentiment = "neutral";

    if (raw === "positive") sentiment = "positive";
    else if (raw === "negative") sentiment = "negative";
    else if (raw === "neutral") sentiment = "neutral";

    return { sentiment, sentiment_score: 1 }; // ✅ you can later replace with real scoring
  } catch (err) {
    console.error("❌ Gemini sentiment analysis failed:", err.message);
    return { sentiment: "neutral", sentiment_score: 0 };
  }
};

// 🚀 POST /api/reviews/truck
const addTruckReview = async (req, res) => {
  const { truck_id, rating, comment, order_id } = req.body;
  const customer_id = req.user._id;

  try {
    const existing = await TruckReview.findOne({
      customer_id,
      truck_id,
      order_id,
    });

    if (existing) {
      return res
        .status(400)
        .json({ message: "You already reviewed this truck." });
    }

    const { sentiment, sentiment_score } = await analyzeSentimentWithGemini(
      comment || ""
    );

    const review = await TruckReview.create({
      customer_id,
      truck_id,
      order_id,
      rating,
      comment,
      sentiment,
      sentiment_score,
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
      .populate("customer_id", "F_name L_name")
      .populate("truck_id", "truck_name"); // Populate truck name
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
      order_id: orderId,
    });

    res.status(200).json({ isRated: !!existing });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// --- ADMIN SPECIFIC FUNCTIONS ---

// Admin: Get all truck reviews with pagination and filtering
const getAllTruckReviewsAdmin = async (req, res) => {
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
    // You can add more filters here (e.g., by truck_id, customer_id)

    const totalReviews = await TruckReview.countDocuments(filter);
    const reviews = await TruckReview.find(filter)
      .populate("customer_id", "F_name L_name email_address")
      .populate("truck_id", "truck_name") // Populate truck name
      .sort({ createdAt: -1 }) // Latest reviews first
      .skip(skip)
      .limit(limit);

    res.json({
      reviews,
      currentPage: page,
      totalPages: Math.ceil(totalReviews / limit),
      totalItems: totalReviews,
    });
  } catch (err) {
    console.error("Error in getAllTruckReviewsAdmin:", err);
    res
      .status(500)
      .json({
        message: "Server error while fetching truck reviews for admin.",
      });
  }
};

// Admin: Delete any truck review
const deleteTruckReviewAdmin = async (req, res) => {
  try {
    const { id } = req.params; // Review ID
    const review = await TruckReview.findByIdAndDelete(id);

    if (!review) {
      return res.status(404).json({ message: "Truck review not found" });
    }
    res.status(200).json({ message: "Truck review deleted successfully." });
  } catch (err) {
    console.error("Error in deleteTruckReviewAdmin:", err);
    res
      .status(500)
      .json({ message: "Server error while deleting truck review." });
  }
};

// Admin: Get summary statistics for truck reviews
const getTruckReviewStatsAdmin = async (req, res) => {
  try {
    const stats = await TruckReview.aggregate([
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
          averageRating: { $round: ["$averageRating", 2] },
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
    console.error("Error in getTruckReviewStatsAdmin:", err);
    res
      .status(500)
      .json({
        message: "Server error while fetching truck review statistics.",
      });
  }
};

module.exports = {
  addTruckReview,
  getTruckReviews,
  checkTruckRated,
  // Admin exports
  getAllTruckReviewsAdmin,
  deleteTruckReviewAdmin,
  getTruckReviewStatsAdmin,
};
