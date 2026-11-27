# TRIAN MAX — Catálogo 2026

Catálogo web con carrito y pedidos por WhatsApp, panel de administración y backend propio.

## Stack

- **App (cliente + panel):** Flutter Web (Dart) → `app/`
- **Backend:** Node.js + Express → `server/`
- **Datos:** **Supabase (PostgreSQL)** cuando se define `DATABASE_URL`; sin ella, `server/data/db.json`. Imágenes y respaldo de la base en **Cloudinary** (`server/uploads/` queda solo como legacy para productos antiguos)

## Puesta en marcha

```bash
cd server
npm install
npm start
```

Esto levanta todo en **http://localhost:3000**:
- **Catálogo:** http://localhost:3000/
- **Panel del dueño:** http://localhost:3000/#/admin — clave por defecto `trianmax2026`

> El backend sirve la app compilada desde `app/build/web`. Si modificas el código Dart, vuelve a compilar:
>
> ```bash
> cd app
> flutter build web --release --wasm
> ```
>
> El flag `--wasm` genera WebAssembly (cuando el navegador lo soporta) y mantiene una versión JavaScript de respaldo.

## Publicación y SEO

- Producción: `https://trianmax.onrender.com`
- Dominio gratuito tipo `*.workers.dev` con proxy, `robots.txt`, `sitemap.xml` y metadatos SEO: ver [`cloudflare/README.md`](cloudflare/README.md).

## Panel del dueño

- **Productos:** crear, editar (nombre, categoría, precio, precio anterior/oferta, stock, descripción, foto) y eliminar.
- **Pedidos:** registro de todos los pedidos con cliente, productos, total y estado (nuevo → confirmado → entregado/cancelado). Cada pedido del catálogo se guarda automáticamente al enviarse.
- **Ajustes:** número de WhatsApp que recibe los pedidos.

## Configuración (variables de entorno)

| Variable         | Descripción                                   | Por defecto     |
| ---------------- | --------------------------------------------- | --------------- |
| `DATABASE_URL`   | URI de PostgreSQL de Supabase (ver abajo)      | — (usa `db.json`) |
| `SUPABASE_DB_URL`| Alias de `DATABASE_URL`                        | — |
| `PGSSLMODE`      | `disable` solo si usas PostgreSQL local sin TLS | — |
| `PORT`           | Puerto del servidor                           | `3000`          |
| `ADMIN_PASSWORD` | Clave del panel del dueño                     | `trianmax2026`  |
| `WHATSAPP_NUMBER`| Ignorada: el número se edita en Ajustes y se restaura de la DB | — |
| `CLOUDINARY_CLOUD_NAME` | Cloud name de tu cuenta de Cloudinary | — |
| `CLOUDINARY_API_KEY` | API key de Cloudinary | — |
| `CLOUDINARY_API_SECRET` | API secret de Cloudinary (solo en el servidor) | — |
| `CLOUDINARY_FOLDER` | Carpeta donde se guardan las fotos | `trianmax` |

Si Render todavía tiene `WHATSAPP_NUMBER` con el valor antiguo, no afecta: el servidor ya no lee esa variable. El número vigente es el que quede guardado en Ajustes, con `573209080898` como valor inicial.

Las tres variables de Cloudinary son obligatorias para subir imágenes desde el panel. Configúralas en el entorno donde corra el servidor (nunca en la app Flutter). Las fotos nuevas se guardan en `https://res.cloudinary.com/<cloud_name>/image/upload/...` y esa URL se guarda en cada producto.

La base de datos (`productos`, pedidos, ajustes y tokens) se respalda en Cloudinary como `trianmax_db.json`; cada cambio invalida la copia en caché. Con Supabase configurado, **la fuente de verdad es PostgreSQL** y Cloudinary/local son solo respaldos. Sin `DATABASE_URL`, se mantiene el comportamiento anterior: `db.json` es la fuente de verdad y se restaura desde Cloudinary al arrancar. Si no hay credenciales de Cloudinary, el respaldo remoto se omite.

## Base de datos con Supabase

1. Crea el proyecto en [supabase.com](https://supabase.com), ábrelo y haz clic en **Connect** (arriba, en la barra del proyecto). También está en **Project Settings → Data API → Connection strings** o en `https://supabase.com/dashboard/project/<REF>?showConnect=true`. No confundir con la *Project URL* (`https://...supabase.co`) ni con la *anon key*: para el backend se necesita la URI `postgresql://...`.
2. Copia la URI de conexión directa (puerto `5432`) o del **Session pooler** (también `5432`). Debe quedar como `postgresql://postgres.[REF]:[PASSWORD]@db.[REF].supabase.co:5432/postgres?sslmode=require`. Usuarios de SQL Editor con contraseña especial: codifícala en la URI (`@` → `%40`, `#` → `%23`, etc.).
3. Define `DATABASE_URL` en Render (**Environment**) y, para trabajar en local, copia `server/.env.example` a `server/.env` y pega ahí la URI. `server/.env` está ignorado por Git.
4. Arranca con `npm start` desde `server/`. El servidor ejecuta automáticamente [`sql/schema.sql`](server/sql/schema.sql) (idempotente). Si las tablas están vacías, importa los datos de `db.json`/Cloudinary una sola vez.
5. Confirma en los logs: `DB Supabase conectada: X productos, Y pedidos` o `Datos importados desde db.json/Cloudinary a Supabase`.

Tablas creadas: `products`, `orders`, `settings` y `tokens`. El stock se descuenta dentro de una transacción, por lo que dos pedidos concurrentes no pueden vender la misma unidad; los precios se recalculan desde la base al confirmar el pedido. Si prefieres crear las tablas a mano, ejecuta `server/sql/schema.sql` en el SQL Editor de Supabase antes de arrancar.

## Desarrollo de la app Flutter

```bash
cd app
flutter run -d web-server --web-port=8080 --dart-define=API_BASE=http://localhost:3000
```

La app abre en http://localhost:8080 y habla con el backend en el puerto 3000.
