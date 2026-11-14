'use strict';

const multer = require('multer');
const crypto = require('crypto');
const path = require('path');
const { UPLOAD_DIR } = require('../config');

const storage = multer.diskStorage({
  destination: UPLOAD_DIR,
  filename: (req, file, cb) => {
    const ext = path.extname(file.originalname).toLowerCase() || '.jpg';
    cb(null, `p_${Date.now()}_${crypto.randomBytes(4).toString('hex')}${ext}`);
  },
});

const upload = multer({
  storage,
  limits: { fileSize: 5 * 1024 * 1024 },
  fileFilter: (req, file, cb) => {
    const validMime = /^image\/(jpeg|jpg|png|webp|gif)$/i.test(file.mimetype);
    const validExt = /\.(jpe?g|png|webp|gif)$/i.test(path.extname(file.originalname));
    if (validMime || validExt) {
      cb(null, true);
    } else {
      cb(new Error('Solo se permiten imágenes JPG, PNG o WebP'));
    }
  },
});

const UploadController = {
  image(req, res) {
    upload.single('image')(req, res, err => {
      if (err) return res.status(400).json({ error: err.message });
      if (!req.file) return res.status(400).json({ error: 'No se recibió ninguna imagen' });
      res.status(201).json({ url: `/uploads/${req.file.filename}` });
    });
  },
};

module.exports = UploadController;
