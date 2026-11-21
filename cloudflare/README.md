# Dominio gratuito con Cloudflare Workers

Este Worker da una URL pública gratis tipo:

```
https://trianmax-catalogo-2026.<tu-subdomain>.workers.dev
```

y redirige todo el tráfico a `https://trianmax.onrender.com`, sin cambiar el servidor ni el bundle Flutter. Además genera automáticamente:

- `/robots.txt`
- `/sitemap.xml`
- `<link rel="canonical">`
- Open Graph / Twitter Cards
- Datos estructurados JSON-LD de la tienda

El dominio final depende del subdomain `workers.dev` que elijas al crear tu cuenta de Cloudflare.

## 1. Crear la cuenta

1. Crea una cuenta gratis en Cloudflare.
2. Entra a **Workers & Pages**.
3. Si te pide activar tu subdomain `workers.dev`, elige uno, por ejemplo `mitienda`.
4. Tu URL será `https://trianmax-catalogo-2026.mitienda.workers.dev`.

## 2. Desplegar

Necesitas Node.js 18 o superior.

```powershell
cd cloudflare
npx wrangler login
.\deploy.ps1
```

`deploy.ps1` define `WRANGLER_CACHE_DIR` en una carpeta temporal. Esto evita el error:

```
A permission error occurred while accessing the file system.
Affected path: D:\node_modules\.cache\wrangler
```

Wrangler intenta usar la primera carpeta `node_modules` que encuentra hacia arriba; en esta PC dio con `D:\node_modules`, que es de solo lectura.

Si prefieres hacerlo manualmente:

```powershell
$env:WRANGLER_CACHE_DIR = Join-Path $env:TEMP 'wrangler-cache'
npx wrangler deploy
```

Si el nombre `trianmax-catalogo-2026` ya está ocupado, cámbialo en `wrangler.toml` y vuelve a desplegar.

Wrangler imprimirá la URL final. Ábrela y comprueba que cargue el catálogo.

## 3. Ponerla en Google

1. Entra a **Google Search Console**.
2. Agrega una propiedad de **URL prefix** con la URL que te dio Wrangler:
   `https://trianmax-catalogo-2026.mitienda.workers.dev`
3. Verifica la propiedad con **Archivo HTML** (ver sección siguiente).
4. Envía el sitemap:
   `https://trianmax-catalogo-2026.mitienda.workers.dev/sitemap.xml`
5. Pide indexación de la homepage.

## Verificación con archivo HTML en Search Console

Como el Worker proxya todo a Render, no puedes “subir” el archivo por FTP. En su lugar, guárdalo como un secreto de Cloudflare:

1. En Search Console, descarga el archivo `googleXXXXXXXX.html`.
2. Ábrelo con el Bloc de notas y copia **todo** el contenido (una sola línea, por ejemplo `google-site-verification: googleXXXXXXXX.html`).
3. Pon el archivo descargado dentro de la carpeta `cloudflare` (o copia su ruta).
4. En la terminal, dentro de `cloudflare`:

```powershell
.\verify.ps1 .\googleXXXXXXXX.html
```

El script lee el archivo y configura el secreto automáticamente. Si prefieres hacerlo manualmente:

```powershell
npx wrangler secret put GOOGLE_SITE_VERIFICATION
```

Pega el contenido cuando Wrangler te lo pida y presiona Enter.

5. Vuelve a Search Console y haz clic en **Verificar**.

El Worker responderá automáticamente a cualquier ruta `googleXXXXXXXX.html` con ese contenido. No necesitas volver a desplegar después de cambiar el secreto.

### Alternativa: etiqueta HTML

Si prefieres el método **Etiqueta HTML**, copia el valor del atributo `content` que te da Google y ejecuta:

```powershell
npx wrangler secret put GOOGLE_META_CONTENT
```

El Worker inyectará `<meta name="google-site-verification" ...>` en el `<head>`.

## Notas

- El plan gratuito de Cloudflare Workers incluye 100 000 requests/día, más que suficiente para este catálogo.
- El plan gratuito de Render duerme el servicio cuando no hay tráfico; la primera visita puede tardar unos segundos.
- `trianmax.onrender.com` sigue funcionando igual. El Worker solo es la fachada pública.
- Esto es un subdomain gratuito, no un dominio propio como `trianmax.com`. Para un dominio real, conecta tu dominio a Render desde **Settings → Custom Domains**.
