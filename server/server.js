'use strict';

const app = require('./src/app');
const { PORT, ADMIN_PASSWORD } = require('./src/config');

app.listen(PORT, () => {
  console.log(`TRIAN MAX server → http://localhost:${PORT}`);
  console.log(`Panel admin → http://localhost:${PORT}/#/admin  (clave: ${ADMIN_PASSWORD})`);
});
