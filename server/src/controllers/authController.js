'use strict';

const SettingsModel = require('../models/settings');
const { ADMIN_PASSWORD } = require('../config');
const { extractToken } = require('../middleware/auth');

const AuthController = {
  login(req, res) {
    const { password } = req.body || {};
    if (password !== ADMIN_PASSWORD) return res.status(401).json({ error: 'Contraseña incorrecta' });
    res.json({ token: SettingsModel.createToken() });
  },

  logout(req, res) {
    SettingsModel.revokeToken(extractToken(req));
    res.json({ ok: true });
  },
};

module.exports = AuthController;
