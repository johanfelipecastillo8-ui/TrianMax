'use strict';

const app = require('./src/app');
const { initDB, usingPostgres } = require('./src/db');
const { PORT, ADMIN_PASSWORD } = require('./src/config');

initDB().then(() => {
  app.listen(PORT, () => {
    console.log(`TRIAN MAX server → http://localhost:${PORT}`);
    console.log(`Base de datos → ${usingPostgres ? 'Supabase (PostgreSQL)' : 'db.json local + Cloudinary'}`);
    console.log(`Panel admin → http://localhost:${PORT}/#/admin  (clave: ${ADMIN_PASSWORD})`);
  });
}).catch(error => {
  // Sin PostgreSQL el backend no puede servir datos: mejor fallar y que Render
  // reinicie el proceso que dejar la app respondiendo con errores.
  console.error('No se pudo iniciar la base de datos:', error.message || error);
  process.exit(1);
});
