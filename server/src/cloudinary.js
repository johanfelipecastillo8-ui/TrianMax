'use strict';

const cloudinary = require('cloudinary').v2;
const {
  CLOUDINARY_CLOUD_NAME,
  CLOUDINARY_API_KEY,
  CLOUDINARY_API_SECRET,
  CLOUDINARY_FOLDER,
} = require('./config');

const configured = Boolean(CLOUDINARY_CLOUD_NAME && CLOUDINARY_API_KEY && CLOUDINARY_API_SECRET);

if (configured) {
  cloudinary.config({
    cloud_name: CLOUDINARY_CLOUD_NAME,
    api_key: CLOUDINARY_API_KEY,
    api_secret: CLOUDINARY_API_SECRET,
    secure: true,
  });
}

/** Sube bytes a Cloudinary y devuelve la URL pública segura. */
function uploadImage(buffer) {
  if (!configured) {
    const error = new Error('Faltan variables de Cloudinary (cloud name, API key y API secret)');
    error.code = 'CLOUDINARY_NOT_CONFIGURED';
    throw error;
  }

  return new Promise((resolve, reject) => {
    const stream = cloudinary.uploader.upload_stream(
      { folder: CLOUDINARY_FOLDER, resource_type: 'image', overwrite: false },
      (error, result) => {
        if (error) return reject(error);
        if (!result || !result.secure_url) return reject(new Error('Cloudinary no devolvió una URL'));
        resolve(result.secure_url);
      },
    );
    stream.end(buffer);
  });
}

module.exports = { uploadImage, configured };
