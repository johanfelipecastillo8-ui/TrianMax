'use strict';

const app = require('./src/app');
const { initDB } = require('./src/db');
const { PORT, ADMIN_PASSWORD } = require('./src/config');

initDB().finally(() => {
  app.listen(PORT, () => {
    console.log(`TRIAN MAX server → http://localhost:${PORT}`);
    console.log(`Panel admin → http://localhost:${PORT}/#/admin  (clave: ${ADMIN_PASSWORD})`);
  });
});
