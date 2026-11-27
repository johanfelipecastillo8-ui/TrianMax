'use strict';

const SettingsModel = require('../models/settings');
const { ADMIN_PASSWORD } = require('../config');
const { extractToken } = require('../middleware/auth');

const AuthController = {
  async login(req, res) {
    const { password } = req.body || {};
    if (password !== ADMIN_PASSWORD) return res.status(401).json({ error: 'Contraseña incorrecta' });
    res.json({ token: await SettingsModel.createToken() });
  },

  async logout(req, res) {
    await SettingsModel.revokeToken(extractToken(req));
    res.json({ ok: true });
  },
};

module.exports = AuthController;
