'use strict';

// Express 4 no espera promesas: pasamos cualquier rechazo al manejador de errores.
module.exports = fn => (req, res, next) => Promise.resolve(fn(req, res, next)).catch(next);
