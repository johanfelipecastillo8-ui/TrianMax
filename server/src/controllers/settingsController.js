'use strict';

const SettingsModel = require('../models/settings');

const SettingsController = {
  get(req, res) {
    res.json({ whatsapp: SettingsModel.getWhatsApp() });
  },

  update(req, res) {
    const wa = SettingsModel.saveWhatsApp((req.body || {}).whatsapp);
    if (!wa) return res.status(400).json({ error: 'Número de WhatsApp inválido' });
    res.json({ whatsapp: wa });
  },
};

module.exports = SettingsController;
