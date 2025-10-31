param(
  [string]$TraeModelsDir = "$env:USERPROFILE\.trae\custom-models",
  [string]$ProxyDir = "$PSScriptRoot\arkaios-service-proxy",
  [string]$LabStarterDir = "$PSScriptRoot\arkaios-lab-starter",
  [string]$ProxyUrl = "http://localhost:4000/v1",
  [string]$McpUrl = "http://localhost:8090/mcp/health",
  [switch]$AutoStartServices = $true
)

function Test-Url {
  param([string]$Url)
  try {
    Invoke-WebRequest -Uri $Url -UseBasicParsing -TimeoutSec 3 | Out-Null
    return $true
  } catch {
    return $false
  }
}

function Wait-ForUrl {
  param([string]$Url, [int]$TimeoutSec = 25)
  $start = Get-Date
  do {
    if (Test-Url $Url) { return $true }
    Start-Sleep -Milliseconds 800
  } while ((Get-Date) - $start -lt ([TimeSpan]::FromSeconds($TimeoutSec)))
  return (Test-Url $Url)
}

function Start-ProxyControlled {
  Write-Host "[TRAE launcher] Intentando iniciar Proxy en $ProxyDir (puerto 4000)..." -ForegroundColor Yellow
  $cmd = "cd '$ProxyDir'; `$env:PORT=4000; npm start"
  Start-Process -FilePath powershell -ArgumentList "-NoExit", "-Command", $cmd -WindowStyle Normal | Out-Null
  if (Wait-ForUrl "$ProxyUrl/models" 30) {
    Write-Host "[TRAE launcher] Proxy iniciado y operativo: $ProxyUrl" -ForegroundColor Green
  } else {
    Write-Warning "Proxy no responde tras el intento de arranque. Revisa la ventana de la terminal iniciada."
  }
}

function Start-McpControlled {
  Write-Host "[TRAE launcher] Intentando iniciar MCP HTTP en $LabStarterDir (puerto 8090)..." -ForegroundColor Yellow
  $cmd = "cd '$LabStarterDir'; `$env:MCP_HTTP_PORT=8090; `$env:AIDA_GATEWAY_URL='https://arkaios-gateway-open.onrender.com/aida/gateway'; `$env:AIDA_AUTH_TOKEN=''; `$env:LOCAL_BASE='http://localhost:8080'; npm run mcp:http"
  Start-Process -FilePath powershell -ArgumentList "-NoExit", "-Command", $cmd -WindowStyle Normal | Out-Null
  if (Wait-ForUrl $McpUrl 30) {
    Write-Host "[TRAE launcher] MCP HTTP iniciado y operativo: $McpUrl" -ForegroundColor Green
  } else {
    Write-Warning "MCP HTTP no responde tras el intento de arranque. Revisa la ventana de la terminal iniciada."
  }
}

Write-Host "[TRAE launcher] Preparando entorno local para modelo 'lab'..." -ForegroundColor Cyan

# 1) Asegurar modelos locales instalados en TRAE
if (-not (Test-Path $TraeModelsDir)) {
  Write-Host "[TRAE launcher] Creando carpeta de modelos: $TraeModelsDir"
  New-Item -ItemType Directory -Force -Path $TraeModelsDir | Out-Null
}

$labModelPath = Join-Path $TraeModelsDir 'lab.json'
if (-not (Test-Path $labModelPath)) {
  Write-Host "[TRAE launcher] Modelo 'lab' no encontrado en TRAE. Ejecutando install-local-models.ps1..." -ForegroundColor Yellow
  $installer = Join-Path $PSScriptRoot 'install-local-models.ps1'
  if (Test-Path $installer) {
    & $installer
  } else {
    Write-Warning "No se encontró install-local-models.ps1 en $PSScriptRoot"
  }
} else {
  Write-Host "[TRAE launcher] Modelo 'lab' ya instalado en: $labModelPath" -ForegroundColor Green
}

# 2) Verificar proxy (puerto 4000)
if (Test-Url "$ProxyUrl/models") {
  Write-Host "[TRAE launcher] Proxy activo: $ProxyUrl" -ForegroundColor Green
} elseif ($AutoStartServices) {
  Start-ProxyControlled
} else {
  Write-Host "[TRAE launcher] Proxy no responde en $ProxyUrl. Inícialo manualmente en una terminal:" -ForegroundColor Yellow
  Write-Host "cd '$ProxyDir'; $env:PORT=4000; npm start" -ForegroundColor White
}

# 3) Verificar MCP HTTP (puerto 8090)
if (Test-Url $McpUrl) {
  Write-Host "[TRAE launcher] MCP HTTP activo: $McpUrl" -ForegroundColor Green
} elseif ($AutoStartServices) {
  Start-McpControlled
} else {
  Write-Host "[TRAE launcher] MCP HTTP no responde. Inícialo manualmente en otra terminal:" -ForegroundColor Yellow
  Write-Host "cd '$LabStarterDir'; $env:MCP_HTTP_PORT=8090; $env:AIDA_GATEWAY_URL='https://arkaios-gateway-open.onrender.com/aida/gateway'; $env:AIDA_AUTH_TOKEN=''; $env:LOCAL_BASE='http://localhost:8080'; npm run mcp:http" -ForegroundColor White
}

# 4) Crear pista/hint (no oficial) para recordar selección en TRAE
$hintPath = Join-Path "$env:USERPROFILE\.trae" 'model_hint.json'
$hint = @{ provider = 'OpenAI'; model = 'lab'; base_url = $ProxyUrl; api_key = 'sk_arkaios_proxy_8y28hsy72hs82js9' }
$hint | ConvertTo-Json -Depth 5 | Set-Content -Path $hintPath -Encoding UTF8
Write-Host "[TRAE launcher] Pista creada: $hintPath (algunas instalaciones de TRAE no la leen; úsala como referencia)" -ForegroundColor DarkCyan

# 5) Abrir salud de servicios en navegador (opcional)
try {
  Start-Process "$ProxyUrl/models" | Out-Null
  Start-Process $McpUrl | Out-Null
  Write-Host "[TRAE launcher] Abriendo health endpoints en el navegador..." -ForegroundColor DarkCyan
} catch {
  Write-Warning "No se pudo abrir el navegador automáticamente."
}

Write-Host "\n[TRAE launcher] Pasos en la UI de TRAE para dejar 'lab' por defecto:" -ForegroundColor Cyan
Write-Host "1) TRAE > Settings > Models" -ForegroundColor White
Write-Host "2) Provider: OpenAI" -ForegroundColor White
Write-Host "3) Model: lab" -ForegroundColor White
Write-Host "4) Abrir un chat nuevo: debería mostrar OpenAI • lab ($ProxyUrl)" -ForegroundColor White

Write-Host "\n[TRAE launcher] Prueba rápida (copy/paste):" -ForegroundColor Cyan
Write-Host "Modo Builder: Resume y propone 3 acciones para presentar arkaios-lab-starter. Indica via: gateway o via: local." -ForegroundColor White

Write-Host "\n[TRAE launcher] Listo. Si quieres que el script intente iniciar los servicios automáticamente, dime y lo ajusto (cuidado con procesos duplicados)." -ForegroundColor Green