const APP_NAME = 'TRIAN MAX';
const APP_DESCRIPTION = 'Catálogo oficial TRIAN MAX 2026. Audio, belleza, smartwatch y más. Pedidos por WhatsApp.';
const WHATSAPP = '573209080898';
const DEFAULT_ORIGIN = 'https://trianmax.onrender.com';

const escapeHtml = (value) => String(value)
  .replace(/&/g, '&amp;')
  .replace(/</g, '&lt;')
  .replace(/>/g, '&gt;')
  .replace(/"/g, '&quot;');

const escapeXml = (value) => escapeHtml(value).replace(/'/g, '&apos;');

function siteBase(request) {
  const url = new URL(request.url);
  return `${url.protocol}//${url.host}`;
}

function textResponse(body, contentType, status = 200) {
  return new Response(body, {
    status,
    headers: {
      'content-type': contentType,
      'cache-control': 'public, max-age=3600',
    },
  });
}

function seoFiles(pathname, base) {
  if (pathname === '/robots.txt') {
    return textResponse(
      `User-agent: *\nAllow: /\n\nSitemap: ${base}/sitemap.xml\n`,
      'text/plain; charset=utf-8',
    );
  }

  if (pathname === '/sitemap.xml') {
    const xml = `<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  <url>
    <loc>${escapeXml(base)}/</loc>
    <changefreq>weekly</changefreq>
    <priority>1.0</priority>
  </url>
</urlset>
`;
    return textResponse(xml, 'application/xml; charset=utf-8');
  }

  return null;
}

function rewriteLocation(response, base, origin) {
  const location = response.headers.get('location');
  if (!location) return;

  try {
    const target = new URL(location, origin);
    const upstream = new URL(origin);
    if (target.host !== upstream.host) return;
    response.headers.set('location', `${base}${target.pathname}${target.search}${target.hash}`);
  } catch (_) {
    // Si no es una URL válida, la dejamos intacta.
  }
}

async function addSeo(response, base) {
  const type = response.headers.get('content-type') || '';
  if (!type.toLowerCase().includes('text/html')) return response;

  const html = await response.text();
  const canonical = escapeHtml(`${base}/`);
  const structuredData = escapeHtml(JSON.stringify({
    '@context': 'https://schema.org',
    '@type': 'Store',
    name: APP_NAME,
    url: `${base}/`,
    telephone: `+${WHATSAPP}`,
    description: APP_DESCRIPTION,
  }));

  const tags = [
    '',
    `  <link rel="canonical" href="${canonical}">`,
    `  <meta property="og:type" content="website">`,
    `  <meta property="og:site_name" content="${APP_NAME}">`,
    `  <meta property="og:url" content="${canonical}">`,
    `  <meta property="og:title" content="${APP_NAME} — Catálogo 2026">`,
    `  <meta property="og:description" content="${escapeHtml(APP_DESCRIPTION)}">`,
    `  <meta name="twitter:card" content="summary_large_image">`,
    `  <script type="application/ld+json">${structuredData}</script>`,
  ].join('\n');

  const patched = html.includes('rel="canonical"')
    ? html
    : html.replace('</head>', `${tags}\n  </head>`);

  const headers = new Headers(response.headers);
  headers.delete('content-encoding');
  headers.delete('content-length');
  headers.set('content-type', 'text/html; charset=utf-8');
  headers.set('cache-control', 'no-cache');

  return new Response(patched, {
    status: response.status,
    statusText: response.statusText,
    headers,
  });
}

export default {
  async fetch(request, env) {
    const base = siteBase(request);
    const url = new URL(request.url);
    const origin = String(env.ORIGIN || DEFAULT_ORIGIN).replace(/\/$/, '');

    if (request.method === 'GET' || request.method === 'HEAD') {
      const special = seoFiles(url.pathname, base);
      if (special) return special;
    }

    try {
      const target = `${origin}${url.pathname}${url.search}`;
      const headers = new Headers(request.headers);
      headers.delete('connection');
      headers.delete('keep-alive');
      headers.delete('proxy-authenticate');
      headers.delete('proxy-authorization');
      headers.delete('te');
      headers.delete('trailer');
      headers.delete('transfer-encoding');
      headers.delete('upgrade');

      const init = { method: request.method, headers, redirect: 'manual' };
      if (request.method !== 'GET' && request.method !== 'HEAD' && request.body) {
        init.body = request.body;
      }

      const response = await fetch(target, init);
      rewriteLocation(response, base, origin);

      if (request.method === 'HEAD') {
        return new Response(null, { status: response.status, headers: response.headers });
      }

      return await addSeo(response, base);
    } catch (error) {
      return textResponse(
        `${APP_NAME} no está disponible en este momento. Intenta nuevamente en unos segundos.`,
        'text/plain; charset=utf-8',
        502,
      );
    }
  },
};
