'use strict';

const cloudinary = require('cloudinary').v2;
const {
  CLOUDINARY_CLOUD_NAME,
  CLOUDINARY_API_KEY,
  CLOUDINARY_API_SECRET,
  CLOUDINARY_FOLDER,
} = require('./config');

const configured = Boolean(CLOUDINARY_CLOUD_NAME && CLOUDINARY_API_KEY && CLOUDINARY_API_SECRET);

if (configured) {
  cloudinary.config({
    cloud_name: CLOUDINARY_CLOUD_NAME,
    api_key: CLOUDINARY_API_KEY,
    api_secret: CLOUDINARY_API_SECRET,
    secure: true,
  });
}

/** Sube bytes a Cloudinary y devuelve la URL pública segura. */
async function uploadImage(buffer) {
  if (!configured) {
    const error = new Error('Faltan variables de Cloudinary (cloud name, API key y API secret)');
    error.code = 'CLOUDINARY_NOT_CONFIGURED';
    throw error;
  }

  // Firma los parámetros con el SDK y envía la petición directamente para poder
  // leer el mensaje real de Cloudinary en errores que el SDK no expone (p. ej. 403).
  const params = cloudinary.utils.sign_request({
    timestamp: Math.floor(Date.now() / 1000),
    folder: CLOUDINARY_FOLDER,
    overwrite: false,
  });

  const form = new FormData();
  for (const [key, value] of Object.entries(params)) form.append(key, String(value));
  form.append('file', new Blob([buffer], { type: 'image/jpeg' }), 'image.jpg');

  const endpoint = `https://api.cloudinary.com/v1_1/${encodeURIComponent(CLOUDINARY_CLOUD_NAME)}/image/upload`;
  const response = await fetch(endpoint, { method: 'POST', body: form });
  const text = await response.text();

  if (!response.ok) {
    let detail = response.headers.get('x-cld-error') || '';
    if (!detail) {
      try {
        detail = JSON.parse(text)?.error?.message || '';
      } catch (_) {
        detail = text.slice(0, 200);
      }
    }
    const error = new Error(detail || `Cloudinary respondió ${response.status}`);
    error.status = response.status;
    throw error;
  }

  const result = JSON.parse(text);
  if (!result.secure_url) throw new Error('Cloudinary no devolvió una URL');
  return result.secure_url;
}

/* ---------- Persistencia de la base de datos ---------- */

const DB_PUBLIC_ID = 'trianmax_db.json';

function deliveryUrl(version) {
  const base = `https://res.cloudinary.com/${encodeURIComponent(CLOUDINARY_CLOUD_NAME)}/raw/upload`;
  return version ? `${base}/v${version}/${DB_PUBLIC_ID}` : `${base}/${DB_PUBLIC_ID}?v=${Date.now()}`;
}

// La URL sin versión puede servir una copia vieja desde la CDN de Cloudinary.
// Consultamos la versión real del recurso para leer siempre el último JSON.
async function latestDeliveryUrl() {
  const resource = await cloudinary.api.resource(DB_PUBLIC_ID, { resource_type: 'raw', type: 'upload' });
  return resource.secure_url || deliveryUrl(resource.version);
}

async function saveJson(data) {
  if (!configured) return;
  const params = cloudinary.utils.sign_request({
    timestamp: Math.floor(Date.now() / 1000),
    public_id: DB_PUBLIC_ID,
    overwrite: true,
    invalidate: true,
    // Versión única aunque dos cambios ocurran en el mismo segundo.
    version: Date.now(),
  });
  const form = new FormData();
  for (const [key, value] of Object.entries(params)) form.append(key, String(value));
  form.append('file', new Blob([JSON.stringify(data)], { type: 'application/json' }), 'db.json');

  const endpoint = `https://api.cloudinary.com/v1_1/${encodeURIComponent(CLOUDINARY_CLOUD_NAME)}/raw/upload`;
  const response = await fetch(endpoint, { method: 'POST', body: form });
  if (!response.ok) throw new Error((await response.text()).slice(0, 200) || `Cloudinary ${response.status}`);
}

async function loadJson() {
  if (!configured) return null;
  const urls = [];
  try {
    urls.push(await latestDeliveryUrl());
  } catch (e) {
    console.warn('No se pudo consultar la versión de la DB en Cloudinary:', e.message || e);
  }
  urls.push(deliveryUrl());

  for (const url of urls) {
    try {
      const response = await fetch(url);
      if (!response.ok) continue;
      const data = JSON.parse(await response.text());
      if (Array.isArray(data.products) && Array.isArray(data.orders)) return data;
    } catch (_) {}
  }
  return null;
}

module.exports = { uploadImage, saveJson, loadJson, configured };
