'use strict';

const express = require('express');
const fs = require('fs');
const path = require('path');
const { UPLOAD_DIR, WEB_DIR } = require('./config');
const apiRoutes = require('./routes');

fs.mkdirSync(UPLOAD_DIR, { recursive: true });

const app = express();

app.use(express.json({ limit: '2mb' }));

app.use((req, res, next) => {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET,POST,PUT,PATCH,DELETE,OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type,Authorization');
  if (req.method === 'OPTIONS') return res.sendStatus(204);
  next();
});

app.use('/api', apiRoutes);
app.use('/uploads', express.static(UPLOAD_DIR));

if (fs.existsSync(WEB_DIR)) {
  app.use(express.static(WEB_DIR));
  app.get('*', (req, res) => res.sendFile(path.join(WEB_DIR, 'index.html')));
}

app.use((err, req, res, next) => {
  console.error(err);
  res.status(500).json({ error: 'Error interno del servidor' });
});

module.exports = app;
