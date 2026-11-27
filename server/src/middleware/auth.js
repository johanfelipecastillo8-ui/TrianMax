'use strict';

const SettingsModel = require('../models/settings');

function extractToken(req) {
  const header = req.headers.authorization || '';
  return header.startsWith('Bearer ') ? header.slice(7) : null;
}

async function requireAuth(req, res, next) {
  const token = extractToken(req);
  if (token && await SettingsModel.hasToken(token)) return next();
  return res.status(401).json({ error: 'No autorizado' });
}

module.exports = { requireAuth, extractToken };
