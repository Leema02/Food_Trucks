const express = require('express');
const router = express.Router();
const { createPaymentIntent } = require('../services/stripeService');

// 💳 POST /api/payments/create-payment-intent
router.post('/create-payment-intent', async (req, res) => {
  const { amount, currency, metadata } = req.body;

  try {
    const result = await createPaymentIntent(amount, currency, metadata);
    res.status(200).json(result); // { clientSecret: ... }
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;
