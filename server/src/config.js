'use strict';

const path = require('path');

module.exports = {
  PORT: process.env.PORT || 3000,
  ADMIN_PASSWORD: process.env.ADMIN_PASSWORD || 'trianmax2026',
  DATA_DIR: path.join(__dirname, '..', 'data'),
  DB_FILE: path.join(__dirname, '..', 'data', 'db.json'),
  UPLOAD_DIR: path.join(__dirname, '..', 'uploads'),
  CLOUDINARY_CLOUD_NAME: process.env.CLOUDINARY_CLOUD_NAME,
  CLOUDINARY_API_KEY: process.env.CLOUDINARY_API_KEY,
  CLOUDINARY_API_SECRET: process.env.CLOUDINARY_API_SECRET,
  CLOUDINARY_FOLDER: process.env.CLOUDINARY_FOLDER || 'trianmax',
  WEB_DIR: path.join(__dirname, '..', '..', 'app', 'build', 'web'),
  SHIP_METHODS: { recojo: 0, delivery: 10000, nacional: 15000 },
  ORDER_STATUSES: ['nuevo', 'confirmado', 'entregado', 'cancelado'],
  MAX_TOKENS: 20,
};
