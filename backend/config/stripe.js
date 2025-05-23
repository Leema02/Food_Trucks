const Stripe = require('stripe');
const stripe = Stripe(process.env.STRIPE_SECRET_KEY); // put this in .env

module.exports = stripe;
