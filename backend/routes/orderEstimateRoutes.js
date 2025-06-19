// routes/orderEstimateRoutes.js
const express = require('express');
const router  = express.Router();
const ctrl    = require('../controllers/orderEstimateController');

// create or recalc estimate
router.post('/orders/:orderId/estimate', ctrl.calculateAndCreate);

// fetch existing estimate
router.get('/orders/:orderId/estimate',  ctrl.getByOrder);

module.exports = router;
