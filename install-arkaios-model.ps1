# Script para instalar automaticamente el modelo Arkaios en Trae AI
# Autor: Arkaios AI System
# Fecha: 2025-01-30

Write-Host "Instalando modelo Arkaios en Trae AI..." -ForegroundColor Cyan

# Configuracion del modelo Arkaios
$arkaiossConfig = @{
    id = "arkaios"
    name = "Arkaios"
    provider = "Custom Provider"
    type = "OpenAI Compatible"
    apiKey = "sk_arkaios_proxy_8y28hsy72hs82js9"
    baseUrl = "https://arkaios-service-proxy.onrender.com/v1"
}

# Verificar que Trae este instalado
$traeDir = "$env:USERPROFILE\.trae"
if (-not (Test-Path $traeDir)) {
    Write-Host "No se encontro la instalacion de Trae AI" -ForegroundColor Red
    Write-Host "Por favor, asegurate de que Trae AI este instalado correctamente." -ForegroundColor Yellow
    exit 1
}

Write-Host "Directorio de Trae encontrado: $traeDir" -ForegroundColor Green

# Crear directorio de configuracion personalizada si no existe
$customConfigDir = "$traeDir\custom-models"
if (-not (Test-Path $customConfigDir)) {
    New-Item -ItemType Directory -Path $customConfigDir -Force | Out-Null
    Write-Host "Creado directorio de modelos personalizados" -ForegroundColor Green
}

# Crear archivo de configuracion del modelo Arkaios
$configFile = "$customConfigDir\arkaios.json"
$configContent = @{
    model = $arkaiossConfig
    metadata = @{
        installed = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        version = "1.0.0"
        status = "active"
    }
} | ConvertTo-Json -Depth 10

$configContent | Out-File -FilePath $configFile -Encoding UTF8
Write-Host "Configuracion guardada en: $configFile" -ForegroundColor Green

# Verificar conectividad con el servicio Arkaios
Write-Host "Verificando conectividad con el servicio Arkaios..." -ForegroundColor Yellow

try {
    $response = Invoke-WebRequest -Uri "https://arkaios-service-proxy.onrender.com/v1" -Method GET -TimeoutSec 10
    if ($response.StatusCode -eq 200) {
        Write-Host "Servicio Arkaios esta activo y respondiendo" -ForegroundColor Green
    }
} catch {
    Write-Host "Advertencia: No se pudo verificar la conectividad con el servicio" -ForegroundColor Yellow
    Write-Host "El modelo se ha configurado, pero verifica tu conexion a internet" -ForegroundColor Yellow
}

# Crear archivo de instrucciones
$instructionsContent = @"
# Modelo Arkaios - Configuracion Completada

## Estado de la Instalacion
Modelo ID: arkaios
Provider: Custom Provider  
Tipo: OpenAI Compatible
API Key: sk_arkaios_proxy_8y28hsy72hs82js9
Base URL: https://arkaios-service-proxy.onrender.com/v1

## Proximos Pasos en Trae AI
1. Ve a Settings - Models - Add Custom Server/Custom OpenAI Endpoint
2. Configura los valores mostrados arriba
3. Selecciona arkaios en el selector de modelos
4. Realiza una consulta de prueba

## Archivos Creados
- Configuracion: $configFile
- Script de instalacion: $PSCommandPath

Instalado automaticamente por Arkaios AI System
Fecha: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
"@

$instructionsFile = "$env:USERPROFILE\Documents\trae_projects\IA ARKAIOS\INSTRUCCIONES_ARKAIOS.md"
$instructionsContent | Out-File -FilePath $instructionsFile -Encoding UTF8
Write-Host "Instrucciones guardadas en: $instructionsFile" -ForegroundColor Green

Write-Host ""
Write-Host "Instalacion completada exitosamente!" -ForegroundColor Green
Write-Host "Consulta el archivo de instrucciones para los proximos pasos" -ForegroundColor Cyan
Write-Host "URL del servicio: https://arkaios-service-proxy.onrender.com/v1" -ForegroundColor Blue
Write-Host ""