'use strict';

const ProductModel = require('../models/product');

const ProductController = {
  list(req, res) {
    res.json(ProductModel.all());
  },

  create(req, res) {
    const { errors, value } = ProductModel.validate(req.body || {});
    if (errors.length) return res.status(400).json({ errors });
    const product = ProductModel.create(value, req.body.image);
    res.status(201).json(product);
  },

  update(req, res) {
    const id = Number(req.params.id);
    const { errors, value } = ProductModel.validate(req.body || {});
    if (errors.length) return res.status(400).json({ errors });
    const product = ProductModel.update(id, value, req.body.image);
    if (!product) return res.status(404).json({ error: 'Producto no encontrado' });
    res.json(product);
  },

  remove(req, res) {
    const ok = ProductModel.remove(Number(req.params.id));
    if (!ok) return res.status(404).json({ error: 'Producto no encontrado' });
    res.json({ ok: true });
  },
};

module.exports = ProductController;
