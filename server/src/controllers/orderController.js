'use strict';

const OrderModel = require('../models/order');
const { ORDER_STATUSES } = require('../config');

const OrderController = {
  list(req, res) {
    res.json(OrderModel.all());
  },

  async create(req, res) {
    const { errors, order } = OrderModel.build(req.body || {});
    if (errors.length) return res.status(400).json({ errors });
    // Esperamos a que la copia remota termine antes de confirmar el pedido.
    try {
      const saved = await OrderModel.create(order);
      return res.status(201).json(saved);
    } catch (e) {
      if (e.code === 'INSUFFICIENT_STOCK') return res.status(400).json({ errors: [e.message] });
      console.error('Error al registrar el pedido:', e);
      return res.status(500).json({ errors: ['No se pudo registrar el pedido'] });
    }
  },

  async setStatus(req, res) {
    const status = String((req.body || {}).status || '');
    if (!ORDER_STATUSES.includes(status)) return res.status(400).json({ error: 'Estado inválido' });
    const order = await OrderModel.setStatus(Number(req.params.id), status);
    if (!order) return res.status(404).json({ error: 'Pedido no encontrado' });
    res.json(order);
  },
};

module.exports = OrderController;
