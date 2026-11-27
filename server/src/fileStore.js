'use strict';

// Backend original: estado en memoria + db.json + respaldo en Cloudinary.
// Se usa cuando no hay DATABASE_URL configurada.

const fs = require('fs');
const { DATA_DIR, DB_FILE, WHATSAPP_NUMBER, MAX_TOKENS } = require('./config');
const { saveJson, loadJson, loadOrders } = require('./cloudinary');

fs.mkdirSync(DATA_DIR, { recursive: true });

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

function normalizeImages() {
  for (const product of db.products || []) {
    if (!Array.isArray(product.images)) {
      product.images = product.image ? [product.image] : [];
    }
  }
}

function writeLocal() {
  const tmp = DB_FILE + '.tmp';
  fs.writeFileSync(tmp, JSON.stringify(db, null, 2));
  fs.renameSync(tmp, DB_FILE);
}

ensureWhatsApp();
normalizeImages();

const FileStore = {
  async init() {
    let loaded = false;
    try {
      const remote = await loadJson();
      if (remote) {
        db.products = remote.products;
        db.orders = remote.orders || [];
        db.tokens = remote.tokens || [];
        db.settings = remote.settings || { whatsapp: WHATSAPP_NUMBER };
        loaded = true;
        console.log('DB local restaurada desde Cloudinary');
      } else {
        console.log('Sin DB remota: se usa la base local/inicial');
      }
      ensureWhatsApp();
      normalizeImages();

      // Los pedidos tienen respaldo individual: no deben perderse aunque la
      // copia principal esté desactualizada.
      const backups = await loadOrders();
      for (const order of backups) {
        if (!db.orders.some(o => o.id === order.id)) db.orders.push(order);
      }
      db.orders.sort((a, b) => b.id - a.id);

      writeLocal();
      if (loaded) await saveJson(db);
    } catch (e) {
      console.error('No se pudo sincronizar la DB local con Cloudinary:', e.message);
      writeLocal();
    }
  },

  async snapshot() {
    return JSON.parse(JSON.stringify(db));
  },

  async listProducts() {
    return db.products;
  },

  async findProduct(id) {
    return db.products.find(p => p.id === id) || null;
  },

  async createProduct(data) {
    const id = db.products.reduce((m, p) => Math.max(m, p.id), 0) + 1;
    const images = Array.isArray(data.images) ? data.images : [];
    const product = {
      id,
      ...data,
      images,
      image: images[0] || null,
      createdAt: new Date().toISOString(),
    };
    db.products.push(product);
    return product;
  },

  async updateProduct(id, data) {
    const product = await FileStore.findProduct(id);
    if (!product) return null;
    const images = Array.isArray(data.images)
      ? data.images
      : (Array.isArray(product.images) ? product.images : (product.image ? [product.image] : []));
    Object.assign(product, data, { images, image: images[0] || null });
    return product;
  },

  async deleteProduct(id) {
    const before = db.products.length;
    db.products = db.products.filter(p => p.id !== id);
    return db.products.length !== before;
  },

  async listOrders() {
    return db.orders;
  },

  async findOrder(id) {
    return db.orders.find(o => o.id === id) || null;
  },

  async createOrder(order) {
    const maxId = db.orders.reduce((m, o) => Math.max(m, Number(o.id) || 0), 1000);
    order.id = maxId + 1;
    for (const item of order.items) {
      const product = await FileStore.findProduct(item.id);
      if (product) product.stock -= item.qty;
    }
    db.orders.unshift(order);
    return order;
  },

  async rawInsertOrder(order) {
    if (db.orders.some(o => o.id === order.id)) return false;
    db.orders.push(order);
    db.orders.sort((a, b) => b.id - a.id);
    return true;
  },

  async setOrderStatus(id, status) {
    const order = await FileStore.findOrder(id);
    if (!order) return null;
    order.status = status;
    return order;
  },

  async getSetting(key) {
    ensureWhatsApp();
    return db.settings[key] ?? null;
  },

  async setSetting(key, value) {
    db.settings[key] = value;
  },

  async listTokens() {
    return db.tokens;
  },

  async hasToken(token) {
    return db.tokens.includes(token);
  },

  async createToken(token) {
    db.tokens.push(token);
    if (db.tokens.length > MAX_TOKENS) db.tokens = db.tokens.slice(-MAX_TOKENS);
  },

  async revokeToken(token) {
    db.tokens = db.tokens.filter(t => t !== token);
  },
};

module.exports = FileStore;
