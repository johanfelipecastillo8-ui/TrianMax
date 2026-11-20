'use strict';

const { db, saveDB } = require('../db');

class ProductModel {
  static all() {
    return db.products;
  }

  static find(id) {
    return db.products.find(p => p.id === id) || null;
  }

  static validate(body) {
    const errors = [];
    const name = String(body.name || '').trim();
    const category = String(body.category || '').trim();
    const price = Number(body.price);
    const rawOld = body.oldPrice;
    const oldPrice = rawOld === null || rawOld === undefined || rawOld === '' ? null : Number(rawOld);
    const stock = Number(body.stock);
    const description = String(body.description || '').trim();

    if (!name) errors.push('El nombre es obligatorio');
    if (!category) errors.push('La categoría es obligatoria');
    if (!Number.isFinite(price) || price < 0) errors.push('Precio inválido');
    if (oldPrice !== null && (!Number.isFinite(oldPrice) || oldPrice < 0)) errors.push('Precio anterior inválido');
    if (!Number.isInteger(stock) || stock < 0) errors.push('Stock inválido');

    const rawImages = body.images;
    const legacyImage = typeof body.image === 'string' ? body.image : null;
    let images = Array.isArray(rawImages)
      ? rawImages.filter(url => typeof url === 'string').map(url => url.trim()).filter(Boolean)
      : (legacyImage ? [legacyImage.trim()] : []);
    images = [...new Set(images)].filter(url => url.startsWith('/uploads/') || /^https?:\/\//i.test(url));
    if (images.length > 8) {
      errors.push('Máximo 8 imágenes por producto');
      images = images.slice(0, 8);
    }

    return {
      errors,
      value: {
        name,
        category,
        price: Math.round(price),
        oldPrice: oldPrice === null ? null : Math.round(oldPrice),
        stock,
        description,
        images,
        image: images[0] || null,
      },
    };
  }

  static create(data) {
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
    saveDB();
    return product;
  }

  static update(id, data) {
    const product = ProductModel.find(id);
    if (!product) return null;
    const images = Array.isArray(data.images)
      ? data.images
      : (Array.isArray(product.images) ? product.images : (product.image ? [product.image] : []));
    Object.assign(product, data, { images, image: images[0] || null });
    saveDB();
    return product;
  }

  static remove(id) {
    const before = db.products.length;
    db.products = db.products.filter(p => p.id !== id);
    if (db.products.length === before) return false;
    saveDB();
    return true;
  }
}

module.exports = ProductModel;
