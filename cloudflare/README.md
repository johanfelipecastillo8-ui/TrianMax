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

```bash
cd cloudflare
npx wrangler login
npx wrangler deploy
```

Si el nombre `trianmax-catalogo-2026` ya está ocupado, cámbialo en `wrangler.toml` y vuelve a desplegar.

Wrangler imprimirá la URL final. Ábrela y comprueba que cargue el catálogo.

## 3. Ponerla en Google

1. Entra a **Google Search Console**.
2. Agrega una propiedad de **URL prefix** con la URL que te dio Wrangler:
   `https://trianmax-catalogo-2026.mitienda.workers.dev`
3. Verifica la propiedad (opción HTML tag o DNS, según te ofrezca Google).
4. Envía el sitemap:
   `https://trianmax-catalogo-2026.mitienda.workers.dev/sitemap.xml`
5. Pide indexación de la homepage.

## Notas

- El plan gratuito de Cloudflare Workers incluye 100 000 requests/día, más que suficiente para este catálogo.
- El plan gratuito de Render duerme el servicio cuando no hay tráfico; la primera visita puede tardar unos segundos.
- `trianmax.onrender.com` sigue funcionando igual. El Worker solo es la fachada pública.
- Esto es un subdomain gratuito, no un dominio propio como `trianmax.com`. Para un dominio real, conecta tu dominio a Render desde **Settings → Custom Domains**.
