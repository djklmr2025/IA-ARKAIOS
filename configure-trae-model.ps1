# Script para configurar el modelo Arkaios Lab en TRAE
# Configuración automática del modelo local

Write-Host "🚀 Configurando modelo Arkaios Lab en TRAE..." -ForegroundColor Green

# Configuración del modelo
$modelConfig = @{
    name = "Arkaios Lab (Local)"
    provider = "OpenAI Compatible"
    baseUrl = "http://127.0.0.1:4000/v1"
    apiKey = "sk_arkaios_proxy_8y28hsy72hs82js9"
    modelId = "lab"
    capabilities = @("text-generation", "code-completion", "chat", "analysis")
}

Write-Host "📋 Configuración del modelo:" -ForegroundColor Cyan
Write-Host "  Nombre: $($modelConfig.name)" -ForegroundColor White
Write-Host "  Proveedor: $($modelConfig.provider)" -ForegroundColor White
Write-Host "  Base URL: $($modelConfig.baseUrl)" -ForegroundColor White
Write-Host "  Model ID: $($modelConfig.modelId)" -ForegroundColor White
Write-Host "  API Key: $($modelConfig.apiKey)" -ForegroundColor White

# Verificar que los servicios estén funcionando
Write-Host "`n🔍 Verificando servicios locales..." -ForegroundColor Yellow

# Verificar Arkaios Service Proxy
try {
    $proxyResponse = Invoke-RestMethod -Uri "http://127.0.0.1:4000/v1/models" -Method GET -Headers @{"Authorization" = "Bearer $($modelConfig.apiKey)"}
    Write-Host "✅ Arkaios Service Proxy funcionando correctamente" -ForegroundColor Green
    Write-Host "   Modelos disponibles: $($proxyResponse.data.Count)" -ForegroundColor Gray
} catch {
    Write-Host "❌ Error conectando con Arkaios Service Proxy: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "   Asegúrate de que el proxy esté ejecutándose en puerto 4000" -ForegroundColor Yellow
    exit 1
}

# Verificar endpoint de chat completions
try {
    $testPayload = @{
        model = "lab"
        messages = @(
            @{
                role = "user"
                content = "Hola, ¿estás funcionando correctamente?"
            }
        )
        max_tokens = 100
        temperature = 0.7
    } | ConvertTo-Json -Depth 10

    $headers = @{
        "Authorization" = "Bearer $($modelConfig.apiKey)"
        "Content-Type" = "application/json"
    }

    $chatResponse = Invoke-RestMethod -Uri "http://127.0.0.1:4000/v1/chat/completions" -Method POST -Body $testPayload -Headers $headers
    Write-Host "✅ Chat completions funcionando correctamente" -ForegroundColor Green
    Write-Host "   Respuesta de prueba recibida exitosamente" -ForegroundColor Gray
} catch {
    Write-Host "❌ Error en chat completions: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host "`n📝 INSTRUCCIONES PARA CONFIGURAR EN TRAE:" -ForegroundColor Magenta
Write-Host "=" * 60 -ForegroundColor Magenta

Write-Host "`n1. Abre TRAE IDE" -ForegroundColor White
Write-Host "2. Haz clic en el icono de configuración (⚙️) en la esquina superior derecha del chat" -ForegroundColor White
Write-Host "3. Selecciona 'Models' en el menú" -ForegroundColor White
Write-Host "4. Haz clic en '+ Add Model'" -ForegroundColor White
Write-Host "5. Configura los siguientes valores:" -ForegroundColor White

Write-Host "`n   📌 CONFIGURACIÓN EXACTA:" -ForegroundColor Yellow
Write-Host "   Provider: OpenAI Compatible" -ForegroundColor Cyan
Write-Host "   Model: Other Models -> lab" -ForegroundColor Cyan
Write-Host "   API Key: sk_arkaios_proxy_8y28hsy72hs82js9" -ForegroundColor Cyan
Write-Host "   Base URL: http://127.0.0.1:4000/v1" -ForegroundColor Cyan

Write-Host "`n6. Haz clic en 'Add Model'" -ForegroundColor White
Write-Host "7. TRAE verificará la conexión automáticamente" -ForegroundColor White
Write-Host "8. Una vez agregado, selecciona 'lab' en el selector de modelos" -ForegroundColor White
Write-Host "9. Prueba enviando un mensaje para verificar que funciona" -ForegroundColor White

Write-Host "`n🎯 VALIDACIÓN:" -ForegroundColor Green
Write-Host "Las respuestas del modelo 'lab' deberían mostrar:" -ForegroundColor White
Write-Host "- Texto humanizado y natural" -ForegroundColor Gray
Write-Host "- Indicador 'via: local' o 'via: gateway|local'" -ForegroundColor Gray

Write-Host "`n💡 NOTAS IMPORTANTES:" -ForegroundColor Blue
Write-Host "- Los servicios locales deben estar ejecutándose" -ForegroundColor Gray
Write-Host "- El puerto 4000 debe estar disponible" -ForegroundColor Gray
Write-Host "- La API Key es específica para el proxy local" -ForegroundColor Gray

Write-Host "`n✨ ¡Configuración lista! Ahora configura el modelo en TRAE siguiendo las instrucciones." -ForegroundColor Green

# Guardar configuración en archivo JSON para referencia
$configFile = "arkaios-trae-model-config.json"
$modelConfig | ConvertTo-Json -Depth 10 | Out-File -FilePath $configFile -Encoding UTF8
Write-Host "`n📄 Configuración guardada en: $configFile" -ForegroundColor Cyan