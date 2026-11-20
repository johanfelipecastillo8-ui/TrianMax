# TRIAN MAX — Catálogo 2026

Catálogo web con carrito y pedidos por WhatsApp, panel de administración y backend propio.

## Stack

- **App (cliente + panel):** Flutter Web (Dart) → `app/`
- **Backend:** Node.js + Express → `server/`
- **Datos:** `server/data/db.json` (productos, pedidos, ajustes) e imágenes en `server/uploads/`

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

## Panel del dueño

- **Productos:** crear, editar (nombre, categoría, precio, precio anterior/oferta, stock, descripción, foto) y eliminar.
- **Pedidos:** registro de todos los pedidos con cliente, productos, total y estado (nuevo → confirmado → entregado/cancelado). Cada pedido del catálogo se guarda automáticamente al enviarse.
- **Ajustes:** número de WhatsApp que recibe los pedidos.

## Configuración (variables de entorno)

| Variable         | Descripción                                   | Por defecto     |
| ---------------- | --------------------------------------------- | --------------- |
| `PORT`           | Puerto del servidor                           | `3000`          |
| `ADMIN_PASSWORD` | Clave del panel del dueño                     | `trianmax2026`  |
| `WHATSAPP_NUMBER`| Número inicial de WhatsApp (se edita en Ajustes) | `573223201720`   |

## Desarrollo de la app Flutter

```bash
cd app
flutter run -d web-server --web-port=8080 --dart-define=API_BASE=http://localhost:3000
```

La app abre en http://localhost:8080 y habla con el backend en el puerto 3000.
