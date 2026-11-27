'use strict';

const SettingsModel = require('../models/settings');

const SettingsController = {
  async get(req, res) {
    res.json({ whatsapp: await SettingsModel.getWhatsApp() });
  },

  async update(req, res) {
    const wa = await SettingsModel.saveWhatsApp((req.body || {}).whatsapp);
    if (!wa) return res.status(400).json({ error: 'Número de WhatsApp inválido' });
    res.json({ whatsapp: wa });
  },
};

module.exports = SettingsController;
