'use strict';

const crypto = require('crypto');
const { db, saveDB } = require('../db');
const { MAX_TOKENS } = require('../config');

const SettingsModel = {
  getWhatsApp() {
    return db.settings.whatsapp;
  },

  saveWhatsApp(number) {
    const wa = String(number || '').replace(/\D/g, '');
    if (wa.length < 9) return null;
    db.settings.whatsapp = wa;
    saveDB();
    return wa;
  },

  createToken() {
    const token = crypto.randomBytes(24).toString('hex');
    db.tokens.push(token);
    if (db.tokens.length > MAX_TOKENS) db.tokens = db.tokens.slice(-MAX_TOKENS);
    saveDB();
    return token;
  },

  hasToken(token) {
    return db.tokens.includes(token);
  },

  revokeToken(token) {
    db.tokens = db.tokens.filter(t => t !== token);
    saveDB();
  },
};

module.exports = SettingsModel;
