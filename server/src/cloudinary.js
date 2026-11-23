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

/* ---------- Respaldos individuales de pedidos ---------- */

// Cada pedido se guarda como recurso propio. Así, aunque la base principal se
// sobrescriba con una copia vieja, los pedidos se recuperan al arrancar.
const ORDER_PREFIX = 'trianmax_orders/order_';

async function saveOrder(order) {
  if (!configured) return;
  const params = cloudinary.utils.sign_request({
    timestamp: Math.floor(Date.now() / 1000),
    public_id: `${ORDER_PREFIX}${order.id}`,
    overwrite: true,
    invalidate: true,
  });
  const form = new FormData();
  for (const [key, value] of Object.entries(params)) form.append(key, String(value));
  form.append('file', new Blob([JSON.stringify(order)], { type: 'application/json' }), 'order.json');

  const endpoint = `https://api.cloudinary.com/v1_1/${encodeURIComponent(CLOUDINARY_CLOUD_NAME)}/raw/upload`;
  const response = await fetch(endpoint, { method: 'POST', body: form });
  if (!response.ok) throw new Error((await response.text()).slice(0, 200) || `Cloudinary ${response.status}`);
}

async function loadOrders() {
  if (!configured) return [];
  try {
    const result = await cloudinary.api.resources({
      resource_type: 'raw',
      type: 'upload',
      prefix: ORDER_PREFIX,
      max_results: 500,
    });
    const orders = [];
    for (const resource of result.resources || []) {
      if (!resource.secure_url) continue;
      try {
        const url = `${resource.secure_url}${resource.secure_url.includes('?') ? '&' : '?'}v=${Date.now()}`;
        const response = await fetch(url);
        if (!response.ok) continue;
        const order = JSON.parse(await response.text());
        if (order && order.id && Array.isArray(order.items)) orders.push(order);
      } catch (_) {}
    }
    return orders;
  } catch (e) {
    console.warn('No se pudieron leer los respaldos de pedidos:', e.message || e);
    return [];
  }
}

module.exports = { uploadImage, saveJson, loadJson, saveOrder, loadOrders, configured };
