param(
  [Parameter(Mandatory = $true)]
  [string]$File
)

if (-not (Test-Path $File)) {
  throw "No se encontró el archivo: $File"
}

$content = (Get-Content -Raw -Path $File).Trim()
if (-not $content) {
  throw "El archivo está vacío: $File"
}

$content | npx wrangler secret put GOOGLE_SITE_VERIFICATION
Write-Host "Secreto configurado. Vuelve a Search Console y haz clic en Verificar."
