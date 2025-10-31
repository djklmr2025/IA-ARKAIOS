# IA ARKAIOS - TRAE Integration

Configuración completa para integrar Arkaios AI con TRAE IDE mediante proxy OpenAI-compatible.

## 🚀 Estado Actual

✅ **Proxy Operativo**: Arkaios corriendo localmente en `http://localhost:4001`  
✅ **Compatibilidad OpenAI**: Endpoints `/v1/models` y `/v1/chat/completions` funcionando  
✅ **Configuración Optimizada**: Variables de entorno ajustadas para máximo rendimiento  
✅ **Scripts de Verificación**: Automatización completa de pruebas  

## 📁 Estructura del Proyecto

```
IA ARKAIOS/
├── arkaios-service-proxy/          # Proxy OpenAI-compatible para Arkaios
│   ├── server.js                   # Servidor principal con endpoints
│   ├── .env                        # Configuración de variables de entorno
│   └── logs/                       # Logs de verificación automática
├── verify-arkaios.ps1              # Script de verificación automática
├── configurar-arkaios-manual.ps1   # Script de configuración manual
├── install-arkaios-model.ps1       # Script de instalación del modelo
└── arkaios-model-config.json       # Configuración del modelo para TRAE
```

## ⚙️ Configuración Actual

### Variables de Entorno (.env)
```env
PORT=4001
PROXY_API_KEY=sk_arkaios_proxy_8y28hsy72hs82js9
ARKAIOS_BASE_URL=https://arkaios-api.onrender.com
ARKAIOS_INTERNAL_KEY=aOQ1ZQ4gyF5bkgxkiwPEFgkrUMW31ZEwVhOITkLRO5jaImetmUlYJegOdwG
ARKAIOS_REQ_FIELD=prompt
ARKAIOS_RESP_PATH=result.note
AIDA_BASE_URL=https://aida-gateway.onrender.com
AIDA_INTERNAL_KEY=vck_03CzZ8cn9GB0vU4zTS6wzWdDBGxOlTKw8whBRvRHTGu8Dc6VjF0NDXzc
```

### Endpoints Disponibles

- **GET** `/v1/models` - Lista modelos disponibles (arkaios, aida)
- **POST** `/v1/chat/completions` - Chat compatible con OpenAI
- **GET** `/debug/ping` - Diagnóstico de backends

## 🔧 Integración con TRAE

### Configuración del Proveedor
```json
{
  "provider": "OpenAI",
  "baseUrl": "http://localhost:4001",
  "apiKey": "sk_arkaios_proxy_8y28hsy72hs82js9",
  "modelId": "arkaios",
  "maxTokens": 1024,
  "temperature": 0.3
}
```

## 🧪 Verificación

### Comando Rápido
```powershell
# Verificar modelos
$APIKEY="sk_arkaios_proxy_8y28hsy72hs82js9"
$h=@{Authorization="Bearer $APIKEY"}
Invoke-RestMethod -Method GET -Uri "http://localhost:4001/v1/models" -Headers $h

# Probar chat
$h=@{Authorization="Bearer $APIKEY"; "Content-Type"="application/json"}
$body=@{model="arkaios"; messages=@(@{role="user"; content="Hola Arkaios"})} | ConvertTo-Json -Depth 10
Invoke-RestMethod -Method POST -Uri "http://localhost:4001/v1/chat/completions" -Headers $h -Body $body
```

### Script Automático
```powershell
PowerShell -NoProfile -ExecutionPolicy Bypass -File "verify-arkaios.ps1" -BaseUrl "http://localhost:4001" -ApiKey "sk_arkaios_proxy_8y28hsy72hs82js9" -Model "arkaios"
```

## 📊 Resultados de Verificación

- ✅ **Modelos**: `arkaios` y `aida` detectados correctamente
- ✅ **Chat**: Respuesta "Acción segura procesada" (texto limpio)
- ✅ **Latencia**: ~2-3 segundos promedio
- ✅ **Estabilidad**: Sin errores en múltiples pruebas

## 🔗 Repositorios Relacionados

- [arkaios-service-proxy](https://github.com/djklmr2025/arkaios-service-proxy) - Proxy principal
- Backend Arkaios: `https://arkaios-api.onrender.com`
- Gateway AIDA: `https://aida-gateway.onrender.com`

## 🚀 Inicio Rápido

1. **Clonar repositorio**:
   ```bash
   git clone https://github.com/djklmr2025/IA-ARKAIOS.git
   cd IA-ARKAIOS/arkaios-service-proxy
   ```

2. **Instalar dependencias**:
   ```bash
   npm install
   ```

3. **Iniciar proxy**:
   ```bash
   npm start
   ```

4. **Verificar funcionamiento**:
   ```powershell
   .\verify-arkaios.ps1 -BaseUrl "http://localhost:4001" -ApiKey "sk_arkaios_proxy_8y28hsy72hs82js9" -Model "arkaios"
   ```

5. **Integrar en TRAE**: Usar la configuración del proveedor mostrada arriba

## 📝 Notas Técnicas

- **Puerto**: Configurado en 4001 para evitar conflictos
- **Autenticación**: API Key personalizada para seguridad
- **Formato de Respuesta**: Texto limpio extraído de `result.note`
- **Fallback**: `/debug/ping` con fallback a raíz si `/healthz` no existe
- **Compatibilidad**: 100% compatible con especificación OpenAI v1

---

**Estado**: ✅ Completamente operativo y listo para producción  
**Última actualización**: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")  
**Mantenedor**: djklmr2025