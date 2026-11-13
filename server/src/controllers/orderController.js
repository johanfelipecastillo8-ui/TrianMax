'use strict';

const OrderModel = require('../models/order');
const { ORDER_STATUSES } = require('../config');

const OrderController = {
  list(req, res) {
    res.json(OrderModel.all());
  },

  create(req, res) {
    const { errors, order } = OrderModel.build(req.body || {});
    if (errors.length) return res.status(400).json({ errors });
    res.status(201).json(OrderModel.create(order));
  },

  setStatus(req, res) {
    const status = String((req.body || {}).status || '');
    if (!ORDER_STATUSES.includes(status)) return res.status(400).json({ error: 'Estado inválido' });
    const order = OrderModel.setStatus(Number(req.params.id), status);
    if (!order) return res.status(404).json({ error: 'Pedido no encontrado' });
    res.json(order);
  },
};

module.exports = OrderController;
