'use strict';

const multer = require('multer');
const path = require('path');
const { uploadImage } = require('../cloudinary');

// Los bytes se mantienen en memoria y se envían directamente a Cloudinary.
const upload = multer({
  storage: multer.memoryStorage(),
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
    upload.single('image')(req, res, async err => {
      if (err) return res.status(400).json({ error: err.message });
      if (!req.file) return res.status(400).json({ error: 'No se recibió ninguna imagen' });
      try {
        const url = await uploadImage(req.file.buffer);
        res.status(201).json({ url });
      } catch (error) {
        console.error('Error al subir la imagen a Cloudinary:', error);
        const status = error.code === 'CLOUDINARY_NOT_CONFIGURED' ? 500 : 502;
        res.status(status).json({
          error: 'No se pudo subir la imagen a Cloudinary',
          detail: error.message ? String(error.message).slice(0, 200) : undefined,
        });
      }
    });
  },
};

module.exports = UploadController;
