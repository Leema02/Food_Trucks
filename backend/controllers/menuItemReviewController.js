const MenuItemReview = require('../models/menuItemReviewModel');

// POST /api/reviews/menu
const addMenuItemReview = async (req, res) => {
  const { menu_item_id, order_id, rating, comment } = req.body;
  const customer_id = req.user._id;

  try {
    const existing = await MenuItemReview.findOne({ customer_id, menu_item_id, order_id });
    if (existing) {
      return res.status(400).json({ message: "You already reviewed this item in this order." });
    }

    const review = await MenuItemReview.create({ customer_id, menu_item_id, order_id, rating, comment });
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
