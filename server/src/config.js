'use strict';

const path = require('path');

// Permite usar un archivo .env en desarrollo. En Render/Supabase las variables
// llegan directamente en el entorno y dotenv no sobrescribe nada.
require('dotenv').config({ path: path.join(__dirname, '..', '.env') });

module.exports = {
  PORT: process.env.PORT || 3000,
  ADMIN_PASSWORD: process.env.ADMIN_PASSWORD || 'trianmax2026',
  // El número se edita en el panel (Ajustes) y se guarda en la DB persistida.
  WHATSAPP_NUMBER: '573209080898',
  DATA_DIR: path.join(__dirname, '..', 'data'),
  DB_FILE: path.join(__dirname, '..', 'data', 'db.json'),
  // URL de conexión de Supabase (PostgreSQL). Si está vacía se usa el modo
  // anterior: db.json local con respaldo en Cloudinary.
  DATABASE_URL: process.env.DATABASE_URL || process.env.SUPABASE_DB_URL || '',
  UPLOAD_DIR: path.join(__dirname, '..', 'uploads'),
  CLOUDINARY_CLOUD_NAME: process.env.CLOUDINARY_CLOUD_NAME,
  CLOUDINARY_API_KEY: process.env.CLOUDINARY_API_KEY,
  CLOUDINARY_API_SECRET: process.env.CLOUDINARY_API_SECRET,
  CLOUDINARY_FOLDER: process.env.CLOUDINARY_FOLDER || 'trianmax',
  WEB_DIR: path.join(__dirname, '..', '..', 'app', 'build', 'web'),
  SHIP_METHODS: { recojo: 0, delivery: 10000, nacional: 15000 },
  PAYMENT_METHODS: ['Nequi', 'Efectivo'],
  ORDER_STATUSES: ['nuevo', 'confirmado', 'entregado', 'cancelado'],
  MAX_TOKENS: 20,
};
