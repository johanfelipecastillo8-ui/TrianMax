'use strict';

const crypto = require('crypto');
const { store, saveDB } = require('../db');

const SettingsModel = {
  async getWhatsApp() {
    return store.getSetting('whatsapp');
  },

  async saveWhatsApp(number) {
    const wa = String(number || '').replace(/\D/g, '');
    if (wa.length < 9) return null;
    await store.setSetting('whatsapp', wa);
    saveDB();
    return wa;
  },

  async createToken() {
    const token = crypto.randomBytes(24).toString('hex');
    await store.createToken(token);
    saveDB();
    return token;
  },

  async hasToken(token) {
    return store.hasToken(token);
  },

  async revokeToken(token) {
    await store.revokeToken(token);
    saveDB();
  },
};

module.exports = SettingsModel;
