'use strict';

const ProductModel = require('../models/product');

const ProductController = {
  async list(req, res) {
    res.json(await ProductModel.all());
  },

  async create(req, res) {
    const { errors, value } = ProductModel.validate(req.body || {});
    if (errors.length) return res.status(400).json({ errors });
    const product = await ProductModel.create(value);
    res.status(201).json(product);
  },

  async update(req, res) {
    const id = Number(req.params.id);
    const { errors, value } = ProductModel.validate(req.body || {});
    if (errors.length) return res.status(400).json({ errors });
    const product = await ProductModel.update(id, value);
    if (!product) return res.status(404).json({ error: 'Producto no encontrado' });
    res.json(product);
  },

  async remove(req, res) {
    const ok = await ProductModel.remove(Number(req.params.id));
    if (!ok) return res.status(404).json({ error: 'Producto no encontrado' });
    res.json({ ok: true });
  },
};

module.exports = ProductController;
