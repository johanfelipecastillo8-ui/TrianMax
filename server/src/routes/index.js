'use strict';

const express = require('express');
const { requireAuth } = require('../middleware/auth');
const asyncHandler = require('../middleware/asyncHandler');
const AuthController = require('../controllers/authController');
const ProductController = require('../controllers/productController');
const OrderController = require('../controllers/orderController');
const SettingsController = require('../controllers/settingsController');
const UploadController = require('../controllers/uploadController');

const router = express.Router();

/* Auth */
router.post('/login', asyncHandler(AuthController.login));
router.post('/logout', asyncHandler(requireAuth), asyncHandler(AuthController.logout));

/* Productos */
router.get('/products', asyncHandler(ProductController.list));
router.post('/products', asyncHandler(requireAuth), asyncHandler(ProductController.create));
router.put('/products/:id', asyncHandler(requireAuth), asyncHandler(ProductController.update));
router.delete('/products/:id', asyncHandler(requireAuth), asyncHandler(ProductController.remove));

/* Pedidos */
router.get('/orders', asyncHandler(requireAuth), asyncHandler(OrderController.list));
router.post('/orders', asyncHandler(OrderController.create));
router.put('/orders/:id/status', asyncHandler(requireAuth), asyncHandler(OrderController.setStatus));

/* Ajustes */
router.get('/settings', asyncHandler(SettingsController.get));
router.put('/settings', asyncHandler(requireAuth), asyncHandler(SettingsController.update));

/* Imágenes */
router.post('/upload', asyncHandler(requireAuth), UploadController.image);

module.exports = router;
