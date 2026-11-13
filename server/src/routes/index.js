'use strict';

const express = require('express');
const { requireAuth } = require('../middleware/auth');
const AuthController = require('../controllers/authController');
const ProductController = require('../controllers/productController');
const OrderController = require('../controllers/orderController');
const SettingsController = require('../controllers/settingsController');
const UploadController = require('../controllers/uploadController');

const router = express.Router();

/* Auth */
router.post('/login', AuthController.login);
router.post('/logout', requireAuth, AuthController.logout);

/* Productos */
router.get('/products', ProductController.list);
router.post('/products', requireAuth, ProductController.create);
router.put('/products/:id', requireAuth, ProductController.update);
router.delete('/products/:id', requireAuth, ProductController.remove);

/* Pedidos */
router.get('/orders', requireAuth, OrderController.list);
router.post('/orders', OrderController.create);
router.put('/orders/:id/status', requireAuth, OrderController.setStatus);

/* Ajustes */
router.get('/settings', SettingsController.get);
router.put('/settings', requireAuth, SettingsController.update);

/* Imágenes */
router.post('/upload', requireAuth, UploadController.image);

module.exports = router;
