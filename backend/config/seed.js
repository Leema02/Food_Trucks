const mongoose = require('mongoose');
const { faker } = require('@faker-js/faker');
const bcrypt = require('bcrypt');
require('dotenv').config({ path: '../.env' });

const User = require('../models/userModel');
const Truck = require('../models/truckModel');
const MenuItem = require('../models/menuModel');

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
    MenuItem.deleteMany({})
  ]);

  const hashedPass = await bcrypt.hash('00', 10);

  console.log('🧑 Seeding real users...');
  const customer = await User.create({
    F_name: 'Lemar',
    L_name: 'Customer',
    email_address: 'lemarizeq@gmail.com',
    phone_num: '0590000001',
    username: 'lemar_customer',
    password: hashedPass,
    city: 'Nablus',
    address: 'Main Street',
    role_id: 'customer'
  });

  const truckOwner = await User.create({
    F_name: 'Leema',
    L_name: 'TruckOwner',
    email_address: 's12029320@stu.najah.edu',
    phone_num: '0590000002',
    username: 'leema_owner',
    password: hashedPass,
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
    password: hashedPass,
    city: 'Ramallah',
    address: 'Downtown',
    role_id: 'admin'
  });

  console.log('🚚 Seeding fake trucks...');
  const trucks = [];
  for (let i = 0; i < 10; i++) {
    const city = faker.helpers.arrayElement(supportedCities);
    const coords = getRandomLocation(city);

    const truck = await Truck.create({
      truck_name: `${faker.company.name()} Truck`,
      cuisine_type: faker.commerce.department(),
      description: faker.lorem.sentence(),
      owner_id: truckOwner._id,
      location: {
        latitude: coords.latitude,
        longitude: coords.longitude,
        address_string: coords.address_string
      },
      operating_hours: {
        open: '10:00 AM',
        close: '10:00 PM'
      },
      logo_image_url: faker.image.urlLoremFlickr({ category: 'food' })
    });

    trucks.push(truck);
  }

  console.log('🍔 Seeding fake menu items...');
  for (let i = 0; i < 30; i++) {
    const truck = faker.helpers.arrayElement(trucks);

    await MenuItem.create({
      truck_id: truck._id,
      name: faker.commerce.productName(),
      description: faker.lorem.sentence(),
      price: faker.commerce.price({ min: 5, max: 20 }),
      category: faker.commerce.department(),
      isAvailable: true,
      image_url: faker.image.urlLoremFlickr({ category: 'food' })
    });
  }

  console.log('✅ Seed complete.');
  process.exit();
}

seed().catch(err => {
  console.error('❌ Seed failed:', err);
  process.exit(1);
});
