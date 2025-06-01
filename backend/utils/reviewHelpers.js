const mongoose = require('mongoose');
const Truck = require('../models/truckModel'); // adjust path if needed
const TruckReview = require('../models/truckReviewModel'); // adjust path

/**
 * Calculates average rating and review count for a list of truck IDs.
 * @param {Array<mongoose.Types.ObjectId>} truckIds 
 * @returns {Promise<Object>} Object with truckId keys mapping to avg and count.
 */
const calculateAverageTruckRatings = async (truckIds) => {
  const ratings = await TruckReview.aggregate([
    { $match: { truck_id: { $in: truckIds } } },
    {
      $group: {
        _id: "$truck_id",
        average_rating: { $avg: "$rating" },
        review_count: { $sum: 1 }
      }
    }
  ]);

  const ratingMap = {};
  for (const r of ratings) {
    ratingMap[r._id.toString()] = {
      average_rating: r.average_rating,
      review_count: r.review_count
    };
  }

  return ratingMap;
};

module.exports = { calculateAverageTruckRatings };
