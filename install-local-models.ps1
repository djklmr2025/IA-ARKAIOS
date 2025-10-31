<#
 Script: install-local-models.ps1
 Purpose: Instala configuraciones de modelos locales ('aida' y 'lab') para TRAE AI usando el proxy OpenAI-compatible en http://localhost:4000/v1.
 Author: Arkaios AI System
#>

param(
  [string]$BaseUrl = "http://localhost:4000/v1",
  [string]$ApiKey = "sk_arkaios_proxy_8y28hsy72hs82js9"
)

Write-Host "Instalando modelos locales para TRAE (aida y lab)…" -ForegroundColor Cyan

# Validar directorio de TRAE
$traeDir = "$env:USERPROFILE\.trae"
if (-not (Test-Path $traeDir)) {
  Write-Host "No se encontró la instalación de Trae AI en $traeDir" -ForegroundColor Red
  Write-Host "Asegúrate de que Trae AI esté instalado y se haya iniciado al menos una vez." -ForegroundColor Yellow
  exit 1
}
Write-Host "Directorio de Trae: $traeDir" -ForegroundColor Green

$customConfigDir = "$traeDir\custom-models"
if (-not (Test-Path $customConfigDir)) { New-Item -ItemType Directory -Path $customConfigDir | Out-Null }

function Write-ModelConfig($id, $name) {
  $config = @{ id = $id; name = $name; provider = "OpenAI"; apiKey = $ApiKey; baseUrl = $BaseUrl; enabled = $true }
  $file = "$customConfigDir\$id.json"
  $json = @{ model = $config } | ConvertTo-Json -Depth 6
  $json | Set-Content -Path $file -Encoding UTF8
  Write-Host "Modelo '$id' creado en $file" -ForegroundColor Green
}

Write-ModelConfig -id "aida" -name "A.I.D.A. (Gateway)"
Write-ModelConfig -id "lab" -name "Arkaios Lab (MCP)"

# Probar /v1/models
try {
  $models = Invoke-RestMethod -Method Get -Uri "$BaseUrl/models" -Headers @{ Authorization = "Bearer $ApiKey" }
  Write-Host "Modelos detectados en el proxy:" -ForegroundColor Yellow
  $models.data | ForEach-Object { Write-Host " - $($_.id)" -ForegroundColor DarkYellow }
} catch {
  Write-Host "No se pudo consultar /v1/models: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "Listo. Abre Trae AI > Settings > Models y selecciona 'OpenAI' como proveedor, elige 'aida' o 'lab'." -ForegroundColor Cyan