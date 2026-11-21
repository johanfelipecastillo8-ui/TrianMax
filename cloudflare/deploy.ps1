$env:WRANGLER_CACHE_DIR = Join-Path $env:TEMP 'wrangler-cache'
npx wrangler deploy
