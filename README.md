# TRIAN MAX — Catálogo 2026

Catálogo web con carrito y pedidos por WhatsApp, panel de administración y backend propio.

## Stack

- **App (cliente + panel):** Flutter Web (Dart) → `app/`
- **Backend:** Node.js + Express → `server/`
- **Datos:** `server/data/db.json` (productos, pedidos, ajustes) e imágenes en **Cloudinary** (`server/uploads/` queda solo como legacy para productos antiguos)

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
| `PORT`           | Puerto del servidor                           | `3000`          |
| `ADMIN_PASSWORD` | Clave del panel del dueño                     | `trianmax2026`  |
| `WHATSAPP_NUMBER`| Ignorada: el número se edita en Ajustes y se restaura de la DB | — |
| `CLOUDINARY_CLOUD_NAME` | Cloud name de tu cuenta de Cloudinary | — |
| `CLOUDINARY_API_KEY` | API key de Cloudinary | — |
| `CLOUDINARY_API_SECRET` | API secret de Cloudinary (solo en el servidor) | — |
| `CLOUDINARY_FOLDER` | Carpeta donde se guardan las fotos | `trianmax` |

Si Render todavía tiene `WHATSAPP_NUMBER` con el valor antiguo, no afecta: el servidor ya no lee esa variable. El número vigente es el que quede guardado en Ajustes, con `573209080898` como valor inicial.

Las tres variables de Cloudinary son obligatorias para subir imágenes desde el panel. Configúralas en el entorno donde corra el servidor (nunca en la app Flutter). Las fotos nuevas se guardan en `https://res.cloudinary.com/<cloud_name>/image/upload/...` y esa URL se guarda en cada producto.

Además, la base de datos (`productos`, pedidos, ajustes y tokens) se respalda en Cloudinary como `trianmax_db.json` y se restaura al arrancar; cada cambio invalida la copia en caché y al arrancar se lee siempre la última versión del archivo. Esto evita perder los cambios cuando Render reinicia la instancia (su sistema de archivos es temporal). Si no hay credenciales de Cloudinary, se usa solo `server/data/db.json`.

## Desarrollo de la app Flutter

```bash
cd app
flutter run -d web-server --web-port=8080 --dart-define=API_BASE=http://localhost:3000
```

La app abre en http://localhost:8080 y habla con el backend en el puerto 3000.
