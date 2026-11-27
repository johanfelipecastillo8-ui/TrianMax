'use strict';

const fs = require('fs');
const { DATABASE_URL, DB_FILE } = require('./config');
const { saveJson } = require('./cloudinary');
const FileStore = require('./fileStore');
const PgStore = require('./pgStore');

// Supabase (PostgreSQL) es la fuente de verdad cuando hay DATABASE_URL.
// Sin ella se mantiene el comportamiento original con db.json.
const usingPostgres = Boolean(DATABASE_URL);
const store = usingPostgres ? PgStore : FileStore;

let saveQueue = Promise.resolve();

function writeLocal(snapshot) {
  const tmp = DB_FILE + '.tmp';
  fs.writeFileSync(tmp, JSON.stringify(snapshot, null, 2));
  fs.renameSync(tmp, DB_FILE);
}

/**
 * Guarda un snapshot de la DB en db.json y en Cloudinary. Las copias se
 * encolan en serie: cada snapshot se toma después de terminar la anterior,
 * así una escritura antigua nunca sobrescribe una reciente.
 */
function persistDB() {
  saveQueue = saveQueue.catch(() => {}).then(async () => {
    try {
      const snapshot = await store.snapshot();
      writeLocal(snapshot);
      for (let attempt = 0; attempt < 3; attempt++) {
        try {
          await saveJson(snapshot); // No hace nada si faltan credenciales.
          return;
        } catch (e) {
          if (attempt === 2) throw e;
          await new Promise(resolve => setTimeout(resolve, 400 * (attempt + 1)));
        }
      }
    } catch (e) {
      console.error('Error al guardar el respaldo de la DB:', e.message || e);
    }
  });
  return saveQueue;
}

// Compatibilidad con llamadores que no esperan el respaldo (productos/ajustes).
function saveDB() {
  persistDB().catch(() => {});
}

async function initDB() {
  await store.init();
  await persistDB();
}

module.exports = { store, usingPostgres, initDB, saveDB, persistDB };
