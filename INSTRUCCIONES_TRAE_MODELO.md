# Configuración del Modelo Arkaios Lab en TRAE

## ✅ Estado de Servicios Verificado
- **Arkaios Service Proxy**: Funcionando correctamente en puerto 4000
- **Chat Completions**: Endpoint verificado y funcional
- **Modelos Disponibles**: 3 modelos detectados

## 📋 Configuración Exacta para TRAE

### Paso 1: Acceder a la Configuración de Modelos
1. Abre **TRAE IDE**
2. Haz clic en el **icono de configuración** (engranaje) en la esquina superior derecha del panel de chat
3. Selecciona **"Models"** en el menú desplegable
4. Haz clic en **"+ Add Model"**

### Paso 2: Configurar el Modelo
En el formulario "Add Model", ingresa **EXACTAMENTE** estos valores:

| Campo | Valor |
|-------|-------|
| **Provider** | `OpenAI Compatible` |
| **Model** | Selecciona "Other Models" y escribe: `lab` |
| **API Key** | `sk_arkaios_proxy_8y28hsy72hs82js9` |
| **Base URL** | `http://127.0.0.1:4000/v1` |

### Paso 3: Guardar y Verificar
1. Haz clic en **"Add Model"**
2. TRAE verificará automáticamente la conexión
3. Si la conexión es exitosa, el modelo aparecerá en tu lista

### Paso 4: Usar el Modelo
1. En el selector de modelos (parte inferior del chat), selecciona **"lab"**
2. Envía un mensaje de prueba: "Hola, ¿estás funcionando correctamente?"
3. Verifica que la respuesta sea natural y humanizada

## 🎯 Validación Exitosa
Las respuestas del modelo "lab" deberían mostrar:
- ✅ Texto humanizado y natural
- ✅ Indicador "via: local" o "via: gateway|local"
- ✅ Respuestas rápidas (procesamiento local)

## 🔧 Configuración Técnica
```json
{
  "name": "Arkaios Lab (Local)",
  "provider": "OpenAI Compatible",
  "baseUrl": "http://127.0.0.1:4000/v1",
  "apiKey": "sk_arkaios_proxy_8y28hsy72hs82js9",
  "modelId": "lab"
}
```

## 🚨 Solución de Problemas

### Si no puedes agregar el modelo:
1. Verifica que los servicios estén ejecutándose:
   - API Lab: puerto 3000
   - MCP HTTP Wrapper: activo
   - Arkaios Service Proxy: puerto 4000

2. Prueba la conexión manualmente:
```bash
curl -X GET "http://127.0.0.1:4000/v1/models" \
  -H "Authorization: Bearer sk_arkaios_proxy_8y28hsy72hs82js9"
```

### Si el modelo no responde:
1. Verifica que seleccionaste "lab" en el selector de modelos
2. Revisa que la API Key sea exactamente: `sk_arkaios_proxy_8y28hsy72hs82js9`
3. Confirma que la Base URL sea: `http://127.0.0.1:4000/v1`

## 💡 Notas Importantes
- **Servicios Locales**: Deben estar ejecutándose antes de usar el modelo
- **Puerto 4000**: Debe estar disponible y no bloqueado por firewall
- **API Key**: Es específica para el proxy local, no es una clave real de OpenAI
- **Modelo ID**: Debe ser exactamente "lab" (minúsculas)

## ✨ ¡Listo!
Una vez configurado, tendrás acceso completo al modelo Arkaios Lab directamente desde TRAE, con procesamiento local y respuestas humanizadas.

---
**Archivo generado automáticamente por el sistema de configuración Arkaios**