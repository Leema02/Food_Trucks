const path = require('path');
const multer = require('multer');

// Storage configuration
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, 'uploads/'); // Save inside "uploads" folder
  },
  filename: function (req, file, cb) {
    const uniqueName = `${Date.now()}-${file.originalname}`;
    cb(null, uniqueName);
  }
});

const upload = multer({ storage: storage });

// Controller function
const uploadImage = (req, res) => {
  if (!req.file) {
    return res.status(400).json({ message: 'No file uploaded.' });
  }

  const fileUrl = `/uploads/${req.file.filename}`;

  res.status(200).json({
    message: '✅ Image uploaded successfully.',
    url: fileUrl
  });
};

module.exports = {
  upload,
  uploadImage
};
