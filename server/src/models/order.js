'use strict';

const { store, persistDB } = require('../db');
const { saveOrder } = require('../cloudinary');
const { SHIP_METHODS, PAYMENT_METHODS } = require('../config');
const ProductModel = require('./product');

class OrderModel {
  static all() {
    return store.listOrders();
  }

  static find(id) {
    return store.findOrder(id);
  }

  static shipMethods() {
    return SHIP_METHODS;
  }

  /* Valida items contra el catálogo y calcula totales en servidor. */
  static async build(input) {
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
      const product = await ProductModel.find(Number(item.id));
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
    // Validación temprana para responder rápido; la transaction del store
    // vuelve a comprobar stock y precios contra la fuente de verdad.
    for (const item of order.items) {
      const product = await ProductModel.find(item.id);
      if (!product || product.stock < item.qty) {
        const error = new Error(`Stock insuficiente de ${item.name}`);
        error.code = 'INSUFFICIENT_STOCK';
        throw error;
      }
    }
    const saved = await store.createOrder(order);
    // Doble escritura: respaldo general + respaldo propio del pedido.
    await Promise.all([
      persistDB(),
      // Si el respaldo falla, el pedido igual queda en la base principal.
      saveOrder(saved).catch(e => console.error('Error al respaldar el pedido:', e.message)),
    ]);
    return saved;
  }

  static async setStatus(id, status) {
    const order = await store.setOrderStatus(id, status);
    if (!order) return null;
    await Promise.all([
      persistDB(),
      // Si el respaldo falla, el pedido igual queda en la base principal.
      saveOrder(order).catch(e => console.error('Error al respaldar el pedido:', e.message)),
    ]);
    return order;
  }
}

module.exports = OrderModel;
