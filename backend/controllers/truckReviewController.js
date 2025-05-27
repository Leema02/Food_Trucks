const TruckReview = require('../models/truckReviewModel');

// POST /api/reviews/truck
const addTruckReview = async (req, res) => {
  const { truck_id, rating, comment } = req.body;
  const customer_id = req.user._id;

  try {
    const existing = await TruckReview.findOne({ customer_id, truck_id });
    if (existing) {
      return res.status(400).json({ message: "You already reviewed this truck." });
    }

    const review = await TruckReview.create({ customer_id, truck_id, rating, comment });
    res.status(201).json(review);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// GET /api/reviews/truck/:truckId
const getTruckReviews = async (req, res) => {
  try {
    const reviews = await TruckReview.find({ truck_id: req.params.truckId })
      .populate('customer_id', 'F_name L_name');
    res.json(reviews);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

module.exports = { addTruckReview, getTruckReviews };
