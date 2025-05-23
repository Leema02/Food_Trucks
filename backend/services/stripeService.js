const stripe = require('../config/stripe');

// 🛠️ Handles creating a PaymentIntent
const createPaymentIntent = async (amount, currency = 'ils', metadata = {}) => {
  try {
    const paymentIntent = await stripe.paymentIntents.create({
      amount,
      currency,
      metadata,
      automatic_payment_methods: { enabled: true },
    });

    return { clientSecret: paymentIntent.client_secret };
  } catch (error) {
    throw new Error(error.message);
  }
};

module.exports = { createPaymentIntent };
