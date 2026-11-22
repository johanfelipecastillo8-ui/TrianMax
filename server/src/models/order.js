'use strict';

const { db, persistDB } = require('../db');
const { SHIP_METHODS, PAYMENT_METHODS } = require('../config');
const ProductModel = require('./product');

class OrderModel {
  static all() {
    return db.orders;
  }

  static find(id) {
    return db.orders.find(o => o.id === id) || null;
  }

  static shipMethods() {
    return SHIP_METHODS;
  }

  /* Valida items contra el catálogo y calcula totales en servidor. */
  static build(input) {
    const name = String(input.name || '').trim();
    const phone = String(input.phone || '').replace(/\D/g, '');
    const address = String(input.address || '').trim();
    const note = String(input.note || '').trim();
    const payment = String(input.payment || '').trim();
    const shipMethod = String(input.shipMethod || 'recojo');
    const items = Array.isArray(input.items) ? input.items : [];

    const errors = [];
    if (!name) errors.push('El nombre es obligatorio');
    if (phone.length < 9) errors.push('Número de celular inválido');
    if (!address) errors.push('La dirección de residencia es obligatoria');
    if (!PAYMENT_METHODS.includes(payment)) errors.push('Método de pago inválido');
    if (!Object.prototype.hasOwnProperty.call(SHIP_METHODS, shipMethod)) errors.push('Método de entrega inválido');
    if (!items.length) errors.push('El pedido está vacío');
    if (errors.length) return { errors };

    let subtotal = 0;
    const orderItems = [];
    for (const item of items) {
      const product = ProductModel.find(Number(item.id));
      const qty = Number(item.qty);
      if (!product) return { errors: [`Producto ${item.id} no existe`] };
      if (!Number.isInteger(qty) || qty < 1) return { errors: [`Cantidad inválida para ${product.name}`] };
      if (qty > product.stock) return { errors: [`Stock insuficiente de ${product.name} (máx. ${product.stock})`] };
      subtotal += product.price * qty;
      orderItems.push({ id: product.id, name: product.name, price: product.price, qty });
    }

    const shipping = SHIP_METHODS[shipMethod];
    return {
      errors: [],
      order: {
        items: orderItems,
        subtotal,
        shipping,
        shipMethod,
        total: subtotal + shipping,
        name,
        phone,
        address,
        payment,
        note,
        status: 'nuevo',
        createdAt: new Date().toISOString(),
      },
    };
  }

  static async create(order) {
    // Revalidamos stock y asignamos el id aquí, de forma síncrona y atómica:
    // dos peticiones que validaron al mismo tiempo no pueden colisionar.
    for (const item of order.items) {
      const product = ProductModel.find(item.id);
      if (!product || product.stock < item.qty) {
        const error = new Error(`Stock insuficiente de ${item.name}`);
        error.code = 'INSUFFICIENT_STOCK';
        throw error;
      }
    }
    order.id = (db.orders.reduce((m, o) => Math.max(m, o.id), 0) || 1000) + 1;
    for (const item of order.items) {
      const product = ProductModel.find(item.id);
      product.stock -= item.qty;
    }
    db.orders.unshift(order);
    await persistDB();
    return order;
  }

  static async setStatus(id, status) {
    const order = OrderModel.find(id);
    if (!order) return null;
    order.status = status;
    await persistDB();
    return order;
  }
}

module.exports = OrderModel;
