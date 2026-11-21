'use strict';

const fs = require('fs');
const { DATA_DIR, DB_FILE, WHATSAPP_NUMBER } = require('./config');
const { saveJson, loadJson } = require('./cloudinary');

for (const dir of [DATA_DIR]) fs.mkdirSync(dir, { recursive: true });

const SEED_PRODUCTS = [
  { id: 1, name: 'AIRPODS MAX IMANTADAS PREMIUM', category: 'Audio & sound', price: 119990, oldPrice: 160000, stock: 10, description: 'Audio de alta fidelidad con sonido envolvente, conexión Bluetooth 5.3 estable y hasta 40 horas de batería. Almohadillas imantadas premium removibles, cancelación de ruido y estuche rígido de carga incluido.', image: null, images: [], createdAt: new Date().toISOString() },
  { id: 2, name: 'AIRPODS PRO 3', category: 'Audio & sound', price: 99990, oldPrice: null, stock: 8, description: 'Función de traducción compatible con iOS y Android. Compatibles con diferentes dispositivos Bluetooth. Sonido estéreo para música y llamadas. Almohadillas de silicona para mayor comodidad. Estuche de carga portátil. Conexión inalámbrica rápida y práctica.', image: null, images: [], createdAt: new Date().toISOString() },
  { id: 3, name: 'PLANCHA CERÁMICA ROSE GOLD', category: 'Belleza', price: 79990, oldPrice: 99990, stock: 15, description: 'Plancha de cabello con placas de cerámica turmalina que sellan el brillo y reducen el frizz. Calentamiento rápido en 30 segundos, temperatura regulable y apagado automático de seguridad.', image: null, images: [], createdAt: new Date().toISOString() },
  { id: 4, name: 'SMARTWATCH ULTRA GOLD', category: 'Smartwatch', price: 129990, oldPrice: null, stock: 12, description: 'Pantalla AMOLED de alta definición, llamadas Bluetooth, monitoreo de ritmo cardíaco, sueño y oxígeno en sangre. Resistente al agua, más de 100 modos deportivos y batería de hasta 7 días.', image: null, images: [], createdAt: new Date().toISOString() },
  { id: 5, name: 'PARLANTE BLUETOOTH GOLD EDITION', category: 'Audio & sound', price: 89990, oldPrice: 110000, stock: 20, description: 'Sonido 360° con graves potentes, 12 horas de reproducción continua, resistencia al agua IPX6 y emparejamiento estéreo dual. Acabado metálico dorado con malla premium.', image: null, images: [], createdAt: new Date().toISOString() },
  { id: 6, name: 'PERFUME AMBER NOIR 100ML', category: 'Belleza', price: 149990, oldPrice: null, stock: 6, description: 'Fragancia unisex de larga duración con notas de ámbar, vainilla y maderas nobles. Presentación de vidrio ámbar con tapa dorada, ideal para regalo. Fijación de más de 10 horas.', image: null, images: [], createdAt: new Date().toISOString() },
];

function loadDB() {
  if (!fs.existsSync(DB_FILE)) {
    return {
      products: SEED_PRODUCTS,
      orders: [],
      tokens: [],
      settings: { whatsapp: WHATSAPP_NUMBER },
    };
  }
  try {
    return JSON.parse(fs.readFileSync(DB_FILE, 'utf8'));
  } catch {
    return { products: [], orders: [], tokens: [], settings: { whatsapp: WHATSAPP_NUMBER } };
  }
}

const db = loadDB();

function ensureWhatsApp() {
  if (!db.settings || typeof db.settings.whatsapp !== 'string' || !db.settings.whatsapp.trim()) {
    db.settings = { ...(db.settings || {}), whatsapp: WHATSAPP_NUMBER };
  }
}

ensureWhatsApp();

// Compatibilidad con productos creados antes de soportar varias imágenes.
for (const product of db.products || []) {
  if (!Array.isArray(product.images)) {
    product.images = product.image ? [product.image] : [];
  }
}

let remoteReady = false;

function saveDB() {
  const tmp = DB_FILE + '.tmp';
  fs.writeFileSync(tmp, JSON.stringify(db, null, 2));
  fs.renameSync(tmp, DB_FILE);
  if (remoteReady) {
    saveJson(db).catch(e => console.error('Error al guardar la DB en Cloudinary:', e.message));
  }
}

// Render reinicia la instancia y pierde el sistema de archivos: la copia en
// Cloudinary es la fuente de verdad al arrancar.
async function initDB() {
  try {
    const remote = await loadJson();
    if (remote) {
      db.products = remote.products;
      db.orders = remote.orders || [];
      db.tokens = remote.tokens || [];
      db.settings = remote.settings || { whatsapp: WHATSAPP_NUMBER };
      ensureWhatsApp();
      for (const product of db.products) {
        if (!Array.isArray(product.images)) {
          product.images = product.image ? [product.image] : [];
        }
      }
      fs.writeFileSync(DB_FILE, JSON.stringify(db, null, 2));
      console.log('DB restaurada desde Cloudinary');
    } else {
      fs.writeFileSync(DB_FILE, JSON.stringify(db, null, 2));
      console.log('Sin DB remota: se usa la base local/inicial');
    }
    remoteReady = true;
    await saveJson(db);
  } catch (e) {
    console.error('No se pudo sincronizar la DB con Cloudinary:', e.message);
    remoteReady = true;
  }
}

module.exports = { db, saveDB, initDB };
