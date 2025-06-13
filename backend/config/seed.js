const mongoose = require('mongoose');
const { faker } = require('@faker-js/faker');
const bcrypt = require('bcrypt');
require('dotenv').config({ path: '../.env' });

const User = require('../models/userModel');
const Truck = require('../models/truckModel');
const MenuItem = require('../models/menuModel');
const EventBooking = require('../models/eventBookingModel');
const Order = require('../models/orderModel');
const TruckReview = require('../models/truckReviewModel');
const MenuItemReview = require('../models/menuItemReviewModel');

const MONGO_URI = process.env.MONGO_URI || 'mongodb://localhost:27017/foodtrucks';

const supportedCities = [
  'Ramallah', 'Nablus', 'Bethlehem', 'Hebron',
  'Jericho', 'Tulkarm', 'Jenin', 'Qalqilya', 'Salfit', 'Tubas'
];

const getRandomLocation = (city) => {
  const baseCoords = {
    Ramallah: [31.8996, 35.2042],
    Nablus: [32.2211, 35.2544],
    Bethlehem: [31.7054, 35.2024],
    Hebron: [31.5335, 35.0950],
    Jericho: [31.8569, 35.4599],
    Tulkarm: [32.3104, 35.0286],
    Jenin: [32.4656, 35.2930],
    Qalqilya: [32.1897, 34.9706],
    Salfit: [32.0840, 35.1797],
    Tubas: [32.3207, 35.3699]
  };
  const [lat, lng] = baseCoords[city];
  return {
    latitude: lat + (Math.random() - 0.5) * 0.01,
    longitude: lng + (Math.random() - 0.5) * 0.01,
    address_string: faker.location.streetAddress()
  };
};

async function seed() {
  await mongoose.connect(MONGO_URI);
  console.log('🌱 Connected to MongoDB');

  await Promise.all([
    User.deleteMany({}),
    Truck.deleteMany({}),
    MenuItem.deleteMany({}),
    EventBooking.deleteMany({}),
    Order.deleteMany({}),
    TruckReview.deleteMany({}),
    MenuItemReview.deleteMany({}),
  ]);

  console.log('🧑 Seeding real users...');
  const customer = await User.create({
    F_name: 'Lemar',
    L_name: 'Customer',
    email_address: 'lemarizeq@gmail.com',
    phone_num: '0590000001',
    username: 'lemar_customer',
    password: '00',
    city: 'Qalqilya',
    address: 'Main Street',
    role_id: 'customer'
  });

  const truckOwner = await User.create({
    F_name: 'Leema',
    L_name: 'TruckOwner',
    email_address: 's12029320@stu.najah.edu',
    phone_num: '0590000002',
    username: 'leema_owner',
    password: '00',
    city: 'Hebron',
    address: 'Old Market',
    role_id: 'truck owner'
  });

  const admin = await User.create({
    F_name: 'Admin',
    L_name: 'Leema',
    email_address: 'itech.leema01@gmail.com',
    phone_num: '0590000003',
    username: 'leema_admin',
    password: '00',
    city: 'Ramallah',
    address: 'Downtown',
    role_id: 'admin'
  });

  console.log('🚚 Seeding fake trucks...');

function getRandomOperatingHours() {
  const hours = [
    { open: '08:00 AM', close: '04:00 PM' },
    { open: '10:00 AM', close: '10:00 PM' },
    { open: '12:00 PM', close: '12:00 AM' },
    { open: '06:00 PM', close: '02:00 AM' },
    { open: '09:00 AM', close: '05:00 PM' },
  ];
  return faker.helpers.arrayElement(hours);
}

function getRandomSentiment() {
  return faker.helpers.arrayElement(['positive', 'neutral', 'negative']);
}

function getRandomSentimentScore() {
  return parseFloat((Math.random() * 2 - 1).toFixed(2)); // range -1 to 1
}


  const cuisineOptions = [
    'Palestinian', 'Middle Eastern', 'BBQ', 'Burgers', 'Pizza', 'Mexican',
    'Asian', 'Sushi', 'Italian', 'Fried Chicken', 'Sandwiches', 'Seafood',
    'Desserts', 'Ice Cream', 'Coffee', 'Shawarma', 'Falafel', 'Vegan'
  ];
  
  const trucks = [];
  for (let i = 0; i < 50; i++) {
    const city = faker.helpers.arrayElement(supportedCities);
    const coords = getRandomLocation(city);

    const unavailable_dates = [];
    const numberOfDates = faker.number.int({ min: 2, max: 4 });
    for (let j = 0; j < numberOfDates; j++) {
      const daysFromNow = faker.number.int({ min: 1, max: 60 });
      const randomDate = new Date();
      randomDate.setDate(randomDate.getDate() + daysFromNow);
      unavailable_dates.push(randomDate);
    }

    const truck = await Truck.create({
      truck_name: faker.helpers.arrayElement([
  "Taco Tempo",
  "The Grilled Goat",
  "Rolling Bites",
  "Pizza Wheels",
  "Burger Boulevard",
  "Wrap & Roll",
  "Spice Voyage",
  "The Vegan Van",
  "Sizzle Station",
  "Falafel Fusion",
  "Churro Chariot",
  "Noodle N Go",
  "Shawarma Shack",
  "BBQ Express",
  "Sushi Street",
  "Kebab Kingdom",
  "Sweet Ride",
  "Urban Bites",
  "Curry Cruiser",
  "Waffle Wagon"
]),
      cuisine_type: faker.helpers.arrayElement(cuisineOptions),
      description: faker.lorem.sentence(),
      owner_id: truckOwner._id,
      city,
      location: {
        latitude: coords.latitude,
        longitude: coords.longitude,
        address_string: coords.address_string
      },
operating_hours: getRandomOperatingHours(),
      logo_image_url:  `/uploads/1748348316290-perfect-food-truck.jpg`,
      unavailable_dates
    });

    trucks.push(truck);
  }
console.log('🍔 Seeding fake menu items...');
for (let i = 0; i < 70; i++) {
  const truck = faker.helpers.arrayElement(trucks);

  await MenuItem.create({
    truck_id: truck._id,
    name: faker.food.dish(),
    description: faker.lorem.sentence(),
    price: faker.commerce.price({ min: 5, max: 20 }),
    category: faker.commerce.department(),
    isAvailable: true,
    image_url: `/uploads/1745837907866-1000000035.jpg`,

    // 🆕 Enhanced fields
    calories: faker.number.int({ min: 100, max: 800 }),
    isVegan: faker.datatype.boolean(),
    isSpicy: faker.datatype.boolean()
  });
}

console.log('📅 Seeding fake event bookings...');
const occasionTypes = ['Wedding', 'Birthday', 'Graduation', 'Corporate'];

for (const truck of trucks) {
  const numBookings = faker.number.int({ min: 1, max: 3 });

  for (let k = 0; k < numBookings; k++) {
    const daysFromNow = faker.number.int({ min: 5, max: 90 });
    const duration = faker.number.int({ min: 1, max: 3 }); // number of days

    const startDate = new Date();
    startDate.setDate(startDate.getDate() + daysFromNow);

    const endDate = new Date(startDate);
    endDate.setDate(startDate.getDate() + duration);

    const startHour = faker.number.int({ min: 10, max: 15 });
    const endHour = faker.number.int({ min: 16, max: 22 });

    const startTime = `${startHour}:00`;
    const endTime = `${endHour}:00`;

    const guestCount = faker.number.int({ min: 30, max: 150 });
    const totalAmount = faker.number.int({ min: 500, max: 2000 }); // or avg menu × guests

    await EventBooking.create({
      truck_id: truck._id,
      user_id: customer._id,
      event_start_date: startDate,
      event_end_date: endDate,
      start_time: startTime,
      end_time: endTime,
      occasion_type: faker.helpers.arrayElement(occasionTypes),
      location: faker.location.streetAddress(),
      city: truck.city,
      guest_count: guestCount,
      special_requests: faker.lorem.words(5),
      total_amount: totalAmount,
      status: faker.helpers.arrayElement(['pending', 'confirmed', 'rejected']),
    });

    // 🛑 Block all days in the booking range
    const blockedDates = [];
    const tempDate = new Date(startDate);
    while (tempDate <= endDate) {
      blockedDates.push(new Date(tempDate));
      tempDate.setDate(tempDate.getDate() + 1);
    }

    const currentTruck = await Truck.findById(truck._id);
    const updatedBlocked = [
      ...new Set([
        ...currentTruck.unavailable_dates.map(d => d.toISOString().split('T')[0]),
        ...blockedDates.map(d => d.toISOString().split('T')[0]),
      ]),
    ].map(dateStr => new Date(dateStr));

    currentTruck.unavailable_dates = updatedBlocked;
    await currentTruck.save();
  }
}

console.log('🧾 Seeding fake orders + reviews...');

for (let i = 0; i < 50; i++) {
  const truck = faker.helpers.arrayElement(trucks);
  const items = await MenuItem.find({ truck_id: truck._id }).limit(3);
  if (!items.length) continue;

const orderedItems = items.map(item => ({
  menu_id: item._id,
  name: item.name,
  quantity: faker.number.int({ min: 1, max: 3 }),
  price: item.price
}));

const order = await Order.create({
  customer_id: customer._id,
  truck_id: truck._id,
  items: orderedItems,
  total_price: orderedItems.reduce((sum, it) => sum + (it.price * it.quantity), 0),
  status: 'Completed', // ✅ use a valid enum value
  order_type: faker.helpers.arrayElement(['pickup', 'delivery'])
});

  // Truck Review
await TruckReview.create({
  customer_id: customer._id,
  truck_id: truck._id,
  order_id: order._id,
  rating: faker.number.int({ min: 3, max: 5 }),
  comment: faker.helpers.arrayElement(['Great truck!', 'Loved it!', 'Would order again.']),
  sentiment: getRandomSentiment(),
  sentiment_score: getRandomSentimentScore()
});



  // Menu Item Reviews
for (const ordered of orderedItems) {
  await MenuItemReview.create({
    customer_id: customer._id,
    menu_item_id: ordered.menu_id,
    order_id: order._id,
    rating: faker.number.int({ min: 3, max: 5 }),
    comment: faker.helpers.arrayElement(['Tasty!', 'Too spicy.', 'Perfectly cooked.']),
    sentiment: getRandomSentiment(),
    sentiment_score: getRandomSentimentScore()
  });
}


}

  console.log('✅ Seed complete.');
  process.exit();
}

seed().catch(err => {
  console.error('❌ Seed failed:', err);
  process.exit(1);
});
