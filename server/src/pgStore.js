'use strict';

// Backend PostgreSQL (Supabase). Es la fuente de verdad cuando DATABASE_URL
// está configurada; Cloudinary sigue siendo solo un respaldo.

const fs = require('fs');
const path = require('path');
const { Pool } = require('pg');
const { DATABASE_URL, WHATSAPP_NUMBER, MAX_TOKENS } = require('./config');
const FileStore = require('./fileStore');

const SCHEMA = fs.readFileSync(path.join(__dirname, '..', 'sql', 'schema.sql'), 'utf8');

function poolConfig() {
  const config = { connectionString: DATABASE_URL, max: 5, idleTimeoutMillis: 30000 };
  if ((process.env.PGSSLMODE || '').toLowerCase() === 'disable') return config;
  // Las URLs de Supabase requieren TLS. pg lo habilita con sslmode=require en
  // la URL; si el usuario no lo puso, lo activamos automáticamente.
  if (/supabase/i.test(DATABASE_URL) && !/[?&]sslmode=/.test(DATABASE_URL)) {
    config.ssl = { rejectUnauthorized: false };
  }
  return config;
}

const pool = new Pool(poolConfig());

pool.on('error', err => {
  console.error('Error inesperado en el pool de PostgreSQL:', err.message || err);
});

function productFromRow(row) {
  if (!row) return null;
  return {
    id: Number(row.id),
    name: row.name,
    category: row.category,
    price: Number(row.price),
    oldPrice: row.old_price === null || row.old_price === undefined ? null : Number(row.old_price),
    stock: Number(row.stock),
    description: row.description || '',
    image: row.image || null,
    images: Array.isArray(row.images) ? row.images : (row.image ? [row.image] : []),
    createdAt: row.created_at ? new Date(row.created_at).toISOString() : null,
  };
}

function orderFromRow(row) {
  if (!row) return null;
  const data = typeof row.data === 'string' ? JSON.parse(row.data) : (row.data || {});
  return {
    ...data,
    id: Number(row.id),
    status: row.status,
    createdAt: data.createdAt || (row.created_at ? new Date(row.created_at).toISOString() : null),
  };
}

function stockError(name) {
  const error = new Error(`Stock insuficiente de ${name}`);
  error.code = 'INSUFFICIENT_STOCK';
  return error;
}

async function insertOrder(client, order) {
  const data = { ...order, id: Number(order.id) };
  await client.query(
    `INSERT INTO public.orders (id, data, status, created_at)
     VALUES ($1, $2::jsonb, $3, $4)
     ON CONFLICT (id) DO NOTHING`,
    [data.id, JSON.stringify(data), data.status || 'nuevo', data.createdAt || new Date().toISOString()],
  );
}

async function insertProduct(client, p) {
  await client.query(
    `INSERT INTO public.products
       (id, name, category, price, old_price, stock, description, image, images, created_at)
     VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9::jsonb, $10)
     ON CONFLICT (id) DO NOTHING`,
    [
      p.id, p.name, p.category, p.price, p.oldPrice ?? null, p.stock,
      p.description || '', p.image || null, JSON.stringify(p.images || []),
      p.createdAt || new Date().toISOString(),
    ],
  );
}

async function syncSequences() {
  for (const table of ['products', 'orders']) {
    const { rows } = await pool.query(`SELECT COALESCE(MAX(id), 0)::bigint AS max FROM public.${table}`);
    const max = Number(rows[0].max);
    if (max > 0) {
      await pool.query('SELECT setval($1::regclass, $2, true)', [`public.${table}_id_seq`, max]);
    }
  }
}

async function importSnapshot(snapshot) {
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    for (const product of snapshot.products || []) await insertProduct(client, product);
    for (const order of snapshot.orders || []) await insertOrder(client, order);
    for (const [key, value] of Object.entries(snapshot.settings || {})) {
      await client.query(
        'INSERT INTO public.settings (key, value) VALUES ($1, $2) ON CONFLICT (key) DO NOTHING',
        [key, String(value)],
      );
    }
    for (const token of (snapshot.tokens || []).slice(-MAX_TOKENS)) {
      await client.query('INSERT INTO public.tokens (token) VALUES ($1) ON CONFLICT (token) DO NOTHING', [token]);
    }
    await client.query('COMMIT');
  } catch (e) {
    try { await client.query('ROLLBACK'); } catch (_) {}
    throw e;
  } finally {
    client.release();
  }
}

const PgStore = {
  async init() {
    await pool.query(SCHEMA);
    await syncSequences();

    const { rows } = await pool.query(`
      SELECT
        (SELECT count(*) FROM public.products)::int  AS products,
        (SELECT count(*) FROM public.orders)::int    AS orders,
        (SELECT count(*) FROM public.settings)::int  AS settings,
        (SELECT count(*) FROM public.tokens)::int    AS tokens
    `);
    const counts = rows[0];
    const isEmpty = !counts.products && !counts.orders && !counts.settings && !counts.tokens;

    if (isEmpty) {
      // Primera puesta en marcha: importamos db.json / Cloudinary a Supabase.
      await FileStore.init();
      await importSnapshot(await FileStore.snapshot());
      await syncSequences();
      console.log('Datos importados desde db.json/Cloudinary a Supabase');
    } else {
      console.log(
        `DB Supabase conectada: ${counts.products} productos, ${counts.orders} pedidos`,
      );
    }

    // Asegura el ajuste de WhatsApp aunque vengamos de una BD creada a mano.
    await PgStore.getSetting('whatsapp');
  },

  async snapshot() {
    const [products, orders, settings, tokens] = await Promise.all([
      pool.query('SELECT * FROM public.products ORDER BY id'),
      pool.query('SELECT * FROM public.orders ORDER BY id DESC'),
      pool.query('SELECT key, value FROM public.settings'),
      pool.query('SELECT token FROM public.tokens ORDER BY created_at'),
    ]);
    return {
      products: products.rows.map(productFromRow),
      orders: orders.rows.map(orderFromRow),
      settings: Object.fromEntries(settings.rows.map(r => [r.key, r.value])),
      tokens: tokens.rows.map(r => r.token),
    };
  },

  async listProducts() {
    const { rows } = await pool.query('SELECT * FROM public.products ORDER BY id');
    return rows.map(productFromRow);
  },

  async findProduct(id) {
    const { rows } = await pool.query('SELECT * FROM public.products WHERE id = $1', [id]);
    return productFromRow(rows[0]);
  },

  async createProduct(data) {
    const { rows } = await pool.query(
      `INSERT INTO public.products
         (name, category, price, old_price, stock, description, image, images, created_at)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8::jsonb, $9)
       RETURNING *`,
      [
        data.name, data.category, data.price, data.oldPrice ?? null, data.stock,
        data.description || '', data.image || null, JSON.stringify(data.images || []),
        data.createdAt || new Date().toISOString(),
      ],
    );
    return productFromRow(rows[0]);
  },

  async updateProduct(id, data) {
    const current = await PgStore.findProduct(id);
    if (!current) return null;
    const images = Array.isArray(data.images)
      ? data.images
      : (Array.isArray(current.images) ? current.images : (current.image ? [current.image] : []));
    const { rows } = await pool.query(
      `UPDATE public.products
          SET name = $2, category = $3, price = $4, old_price = $5, stock = $6,
              description = $7, image = $8, images = $9::jsonb
        WHERE id = $1
        RETURNING *`,
      [
        id, data.name, data.category, data.price, data.oldPrice ?? null, data.stock,
        data.description || '', images[0] || null, JSON.stringify(images),
      ],
    );
    return productFromRow(rows[0]);
  },

  async deleteProduct(id) {
    const { rowCount } = await pool.query('DELETE FROM public.products WHERE id = $1', [id]);
    return rowCount > 0;
  },

  async listOrders() {
    const { rows } = await pool.query('SELECT * FROM public.orders ORDER BY created_at DESC, id DESC');
    return rows.map(orderFromRow);
  },

  async findOrder(id) {
    const { rows } = await pool.query('SELECT * FROM public.orders WHERE id = $1', [id]);
    return orderFromRow(rows[0]);
  },

  async createOrder(order) {
    // Transacción: bloqueamos los productos para que dos pedidos concurrentes
    // no puedan vender el mismo stock. Los precios se recalculan desde la BD.
    const client = await pool.connect();
    try {
      await client.query('BEGIN');
      const ids = order.items.map(item => Number(item.id));
      if (!ids.length) throw new Error('El pedido está vacío');
      const placeholders = ids.map((_, index) => `$${index + 1}`).join(', ');
      const { rows: locked } = await client.query(
        `SELECT * FROM public.products WHERE id IN (${placeholders}) FOR UPDATE`,
        ids,
      );
      const products = new Map(locked.map(p => [Number(p.id), productFromRow(p)]));

      let subtotal = 0;
      const items = [];
      for (const item of order.items) {
        const product = products.get(Number(item.id));
        const qty = Number(item.qty);
        if (!product) throw stockError(`Producto ${item.id} no existe`);
        if (!Number.isInteger(qty) || qty < 1) throw stockError(`Cantidad inválida de ${product.name}`);
        if (qty > product.stock) throw stockError(product.name);
        subtotal += product.price * qty;
        items.push({ id: product.id, name: product.name, price: product.price, qty });
      }

      // Las filas están bloqueadas por FOR UPDATE: asignar el stock calculado
      // es seguro y evita operaciones aritméticas con parámetros en SQL.
      for (const item of items) {
        const product = products.get(item.id);
        await client.query('UPDATE public.products SET stock = $1 WHERE id = $2', [
          product.stock - item.qty,
          item.id,
        ]);
      }

      const saved = {
        ...order,
        items,
        subtotal,
        total: subtotal + Number(order.shipping || 0),
        status: 'nuevo',
        createdAt: new Date().toISOString(),
      };
      const { rows } = await client.query(
        `INSERT INTO public.orders (data, status, created_at)
         VALUES ($1::jsonb, $2, $3)
         RETURNING id, data, status, created_at`,
        [JSON.stringify(saved), saved.status, saved.createdAt],
      );
      await client.query('COMMIT');
      return orderFromRow(rows[0]);
    } catch (e) {
      try { await client.query('ROLLBACK'); } catch (_) {}
      throw e;
    } finally {
      client.release();
    }
  },

  async rawInsertOrder(order) {
    const client = await pool.connect();
    try {
      await insertOrder(client, order);
      return true;
    } finally {
      client.release();
    }
  },

  async setOrderStatus(id, status) {
    const current = await PgStore.findOrder(id);
    if (!current) return null;
    const updated = { ...current, status };
    const { rows } = await pool.query(
      `UPDATE public.orders
          SET status = $2, data = $3::jsonb
        WHERE id = $1
        RETURNING id, data, status, created_at`,
      [id, status, JSON.stringify(updated)],
    );
    return orderFromRow(rows[0]);
  },

  async getSetting(key) {
    const { rows } = await pool.query('SELECT value FROM public.settings WHERE key = $1', [key]);
    if (rows.length) return rows[0].value;
    if (key === 'whatsapp') {
      await PgStore.setSetting(key, WHATSAPP_NUMBER);
      return WHATSAPP_NUMBER;
    }
    return null;
  },

  async setSetting(key, value) {
    await pool.query(
      `INSERT INTO public.settings (key, value) VALUES ($1, $2)
       ON CONFLICT (key) DO UPDATE SET value = EXCLUDED.value`,
      [key, String(value)],
    );
  },

  async listTokens() {
    const { rows } = await pool.query('SELECT token FROM public.tokens ORDER BY created_at');
    return rows.map(r => r.token);
  },

  async hasToken(token) {
    const { rows } = await pool.query('SELECT 1 FROM public.tokens WHERE token = $1', [token]);
    return rows.length > 0;
  },

  async createToken(token) {
    await pool.query('INSERT INTO public.tokens (token) VALUES ($1) ON CONFLICT (token) DO NOTHING', [token]);
    await pool.query(
      `DELETE FROM public.tokens
        WHERE token IN (SELECT token FROM public.tokens ORDER BY created_at DESC OFFSET $1)`,
      [MAX_TOKENS],
    );
  },

  async revokeToken(token) {
    await pool.query('DELETE FROM public.tokens WHERE token = $1', [token]);
  },

  async close() {
    await pool.end();
  },
};

module.exports = PgStore;
