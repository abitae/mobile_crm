# Documentación - Búsqueda de Documentos API

## 📋 Índice

1. [Introducción](#introducción)
2. [Configuración Base](#configuración-base)
3. [Endpoint de Búsqueda](#endpoint-de-búsqueda)
4. [Parámetros](#parámetros)
5. [Respuestas](#respuestas)
6. [Ejemplos de Uso](#ejemplos-de-uso)
7. [Manejo de Errores](#manejo-de-errores)
8. [Notas Importantes](#notas-importantes)

---

## 🎯 Introducción

El servicio de búsqueda de documentos permite consultar información completa de personas (DNI) o empresas (RUC) utilizando el servicio externo de Facturalahoy. Este servicio está disponible tanto para la aplicación **Datero** como para la aplicación **Cazador**.

### Características

- ✅ Búsqueda por DNI (8 dígitos)
- ✅ Búsqueda por RUC (11 dígitos)
- ✅ Verificación previa en base de datos local
- ✅ Sanitización automática de números de documento
- ✅ Validación estricta de formatos
- ✅ Información completa de la persona/empresa
- ✅ Información de ubigeo incluida
- ✅ Logging de todas las búsquedas para auditoría

### Flujo de Búsqueda

1. **Validación y sanitización** de los datos de entrada
2. **Verificación en base de datos local:** Se verifica si el documento ya está registrado
   - Si está registrado: Retorna información del cliente y cazador responsable
   - Si no está registrado: Continúa con la búsqueda externa
3. **Búsqueda en servicio externo** (Facturalahoy) si no está registrado
4. **Retorno de resultados** con información completa

---

## ⚙️ Configuración Base

### Base URL

```
Producción: https://lotesenremate.pe/api
Desarrollo: http://crm_inmobiliaria.test/api
```

### Endpoints Disponibles

- **Aplicación Datero:** `POST /api/datero/documents/search`
- **Aplicación Cazador:** `POST /api/cazador/documents/search`

### Headers Requeridos

```
Authorization: Bearer {token}
Content-Type: application/json
Accept: application/json
```

### Rate Limiting

**30 solicitudes por minuto** por usuario autenticado.

---

## 🔍 Endpoint de Búsqueda

### Aplicación Datero

**Endpoint:** `POST /api/datero/documents/search`

### Aplicación Cazador

**Endpoint:** `POST /api/cazador/documents/search`

Ambos endpoints funcionan de manera idéntica, solo cambia el prefijo de la ruta según la aplicación.

---

## 📝 Parámetros

### Request Body

```json
{
    "document_type": "dni",
    "document_number": "12345678"
}
```

### Parámetros Detallados

| Parámetro | Tipo | Requerido | Descripción |
|-----------|------|-----------|-------------|
| `document_type` | string | Sí | Tipo de documento: `"dni"` o `"ruc"` |
| `document_number` | string | Sí | Número de documento (solo dígitos) |

### Validaciones

#### DNI
- Debe tener **exactamente 8 dígitos**
- Solo se aceptan números (0-9)
- El sistema sanitiza automáticamente, eliminando caracteres no numéricos

#### RUC
- Debe tener **exactamente 11 dígitos**
- Solo se aceptan números (0-9)
- El sistema sanitiza automáticamente, eliminando caracteres no numéricos

### Sanitización Automática

El sistema realiza las siguientes sanitizaciones automáticamente:

1. **Eliminación de caracteres no numéricos:** Si envías `"1234-5678"`, se convierte a `"12345678"`
2. **Normalización de tipo:** El `document_type` se convierte automáticamente a minúsculas
3. **Eliminación de espacios:** Se eliminan espacios al inicio y final

**Ejemplo:**
```json
// Input del usuario
{
    "document_type": "DNI",
    "document_number": "1234-5678"
}

// Después de sanitización
{
    "document_type": "dni",
    "document_number": "12345678"
}
```

---

## 📤 Respuestas

### Respuesta Exitosa (200)

```json
{
    "success": true,
    "message": "Datos encontrados exitosamente",
    "data": {
        "found": true,
        "document_type": "dni",
        "document_number": "12345678",
        "data": {
            "nombre": "JUAN PEREZ GARCIA",
            "apellido_paterno": "PEREZ",
            "apellido_materno": "GARCIA",
            "fecha_nacimiento": "1990-05-15",
            "codigo_ubigeo": "150101",
            "api": {
                "result": {
                    "depaDireccion": "LIMA",
                    "provDireccion": "LIMA",
                    "distDireccion": "LIMA"
                }
            }
        },
        "ubigeo": {
            "text": "LIMA - LIMA - LIMA",
            "code": "150101"
        }
    }
}
```

### Estructura de Datos

#### Campos Principales

- `found`: Indica si se encontró información (siempre `true` en respuesta exitosa)
- `document_type`: Tipo de documento consultado (`dni` o `ruc`)
- `document_number`: Número de documento consultado
- `data`: Objeto con toda la información de la persona/empresa
- `ubigeo`: Información de ubicación geográfica (si está disponible)

#### Información de Ubigeo

Cuando está disponible, se incluye:

```json
{
    "ubigeo": {
        "text": "LIMA - LIMA - LIMA",
        "code": "150101"
    }
}
```

- `text`: Texto completo de la ubicación (Departamento - Provincia - Distrito)
- `code`: Código de ubigeo

---

## ❌ Manejo de Errores

### Cliente Ya Registrado (409)

**Causa:** El documento ya está registrado en la base de datos del sistema

```json
{
    "success": false,
    "message": "Cliente registrado por el cazador responsable de ese cliente",
    "errors": {
        "client_registered": true,
        "client_id": 123,
        "client_name": "Juan Pérez García",
        "assigned_advisor": {
            "id": 5,
            "name": "Carlos Vendedor",
            "email": "carlos@example.com"
        },
        "message": "El cliente ya está registrado. Cazador responsable: Carlos Vendedor"
    }
}
```

**Información Incluida:**
- `client_registered`: Indica que el cliente ya está registrado (siempre `true`)
- `client_id`: ID del cliente en el sistema
- `client_name`: Nombre del cliente registrado
- `assigned_advisor`: Información del cazador responsable (puede ser `null` si no tiene asignado)
  - `id`: ID del cazador
  - `name`: Nombre del cazador
  - `email`: Email del cazador
- `message`: Mensaje descriptivo con el nombre del cazador responsable

**Nota:** Este error se retorna **antes** de consultar el servicio externo, evitando costos innecesarios.

### Error de Validación (422)

**Causa:** Parámetros inválidos o faltantes

```json
{
    "success": false,
    "message": "Error de validación",
    "errors": {
        "document_type": ["El tipo de documento es obligatorio."],
        "document_number": [
            "El número de documento es obligatorio.",
            "El número de documento solo debe contener dígitos.",
            "El DNI debe tener exactamente 8 dígitos."
        ]
    }
}
```

**Errores Comunes:**

| Error | Causa | Solución |
|-------|-------|----------|
| `El tipo de documento es obligatorio` | No se envió `document_type` | Incluir el campo en el request |
| `El tipo de documento debe ser "dni" o "ruc"` | Tipo inválido | Usar `"dni"` o `"ruc"` |
| `El número de documento es obligatorio` | No se envió `document_number` | Incluir el campo en el request |
| `El número de documento solo debe contener dígitos` | Contiene caracteres no numéricos | Enviar solo números (se sanitiza automáticamente) |
| `El DNI debe tener exactamente 8 dígitos` | DNI con longitud incorrecta | Verificar que tenga 8 dígitos |
| `El RUC debe tener exactamente 11 dígitos` | RUC con longitud incorrecta | Verificar que tenga 11 dígitos |

### Documento No Encontrado (404)

**Causa:** El documento no existe en la base de datos externa

```json
{
    "success": false,
    "message": "No se encontró información para el documento proporcionado"
}
```

### Error del Servidor (500)

**Causa:** Error al procesar la búsqueda o problema con el servicio externo

```json
{
    "success": false,
    "message": "Error al procesar la búsqueda. Por favor, intente nuevamente.",
    "errors": {
        "error": "Error interno del servidor"
    }
}
```

**Nota:** En modo desarrollo (`APP_DEBUG=true`), se incluyen detalles adicionales del error.

### Error de Autenticación (401)

**Causa:** Token JWT inválido o expirado

```json
{
    "success": false,
    "message": "No autenticado"
}
```

### Error de Autorización (403)

**Causa:** Usuario sin permisos para acceder al servicio

```json
{
    "success": false,
    "message": "Acceso denegado"
}
```

---

## 💻 Ejemplos de Uso

### Flutter/Dart

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<Map<String, dynamic>> searchDocument({
  required String token,
  required String documentType,
  required String documentNumber,
}) async {
  final response = await http.post(
    Uri.parse('https://lotesenremate.pe/api/datero/documents/search'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
    body: jsonEncode({
      'document_type': documentType,
      'document_number': documentNumber,
    }),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Error al buscar documento: ${response.body}');
  }
}

// Uso
try {
  final result = await searchDocument(
    token: 'tu_token_jwt',
    documentType: 'dni',
    documentNumber: '12345678',
  );
  
  if (result['success']) {
    final data = result['data']['data'];
    print('Nombre: ${data['nombre']}');
    print('Ubigeo: ${result['data']['ubigeo']['text']}');
  } else {
    // Verificar si el cliente ya está registrado
    if (result['errors'] != null && result['errors']['client_registered'] == true) {
      final advisor = result['errors']['assigned_advisor'];
      print('Cliente ya registrado');
      print('Cazador responsable: ${advisor['name']} (${advisor['email']})');
    } else {
      print('Error: ${result['message']}');
    }
  }
} catch (e) {
  print('Error: $e');
}
```

### JavaScript/React Native

```javascript
const searchDocument = async (token, documentType, documentNumber) => {
  try {
    const response = await fetch(
      'https://lotesenremate.pe/api/datero/documents/search',
      {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: JSON.stringify({
          document_type: documentType,
          document_number: documentNumber,
        }),
      }
    );

    const data = await response.json();

    if (!response.ok) {
      throw new Error(data.message || 'Error al buscar documento');
    }

    return data;
  } catch (error) {
    console.error('Error:', error);
    throw error;
  }
};

// Uso
try {
  const result = await searchDocument('tu_token_jwt', 'dni', '12345678');
  
  if (result.success) {
    const personData = result.data.data;
    console.log('Nombre:', personData.nombre);
    console.log('Ubigeo:', result.data.ubigeo?.text);
  } else {
    // Verificar si el cliente ya está registrado
    if (result.errors?.client_registered) {
      const advisor = result.errors.assigned_advisor;
      console.log('Cliente ya registrado');
      console.log('Cazador responsable:', advisor?.name, `(${advisor?.email})`);
    } else {
      console.error('Error:', result.message);
    }
  }
} catch (error) {
  console.error('Error al buscar documento:', error.message);
}
```

### cURL

```bash
# Búsqueda por DNI
curl -X POST https://lotesenremate.pe/api/datero/documents/search \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "document_type": "dni",
    "document_number": "12345678"
  }'

# Búsqueda por RUC
curl -X POST https://lotesenremate.pe/api/cazador/documents/search \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "document_type": "ruc",
    "document_number": "20123456789"
  }'
```

### Python

```python
import requests

def search_document(token, document_type, document_number):
    url = "https://lotesenremate.pe/api/datero/documents/search"
    
    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json",
        "Accept": "application/json"
    }
    
    data = {
        "document_type": document_type,
        "document_number": document_number
    }
    
    response = requests.post(url, json=data, headers=headers)
    
    # No lanzar excepción para código 409 (cliente registrado)
    if response.status_code == 409:
        return response.json()
    
    response.raise_for_status()
    return response.json()

# Uso
try:
    result = search_document("tu_token_jwt", "dni", "12345678")
    
    if result["success"]:
        person_data = result["data"]["data"]
        print(f"Nombre: {person_data['nombre']}")
        
        if "ubigeo" in result["data"]:
            print(f"Ubigeo: {result['data']['ubigeo']['text']}")
    else:
        # Verificar si el cliente ya está registrado
        errors = result.get("errors", {})
        if errors.get("client_registered"):
            advisor = errors.get("assigned_advisor")
            print("Cliente ya registrado")
            if advisor:
                print(f"Cazador responsable: {advisor['name']} ({advisor['email']})")
        else:
            print(f"Error: {result['message']}")
except requests.exceptions.RequestException as e:
    print(f"Error: {e}")
```

---

## 📝 Notas Importantes

### Servicio Externo

Este servicio consulta datos de la API externa de **Facturalahoy**. Por lo tanto:

- ⚠️ **Dependencia externa:** El servicio depende de la disponibilidad de Facturalahoy
- ⏱️ **Tiempo de respuesta:** Puede variar según la carga del servicio externo
- 🔄 **Reintentos:** Se recomienda implementar lógica de reintentos en caso de fallo

### Sanitización Automática

El sistema sanitiza automáticamente los datos de entrada:

- ✅ Elimina caracteres no numéricos de `document_number`
- ✅ Normaliza `document_type` a minúsculas
- ✅ Elimina espacios al inicio y final

**Recomendación:** Aunque el sistema sanitiza, es mejor enviar datos ya limpios desde el cliente.

### Logging y Auditoría

Todas las búsquedas se registran en los logs del sistema con:

- 📅 Timestamp de la búsqueda
- 👤 ID del usuario autenticado
- 📄 Tipo y número de documento consultado
- 🌐 Dirección IP del cliente
- ✅/❌ Resultado de la búsqueda (éxito o error)

**Ejemplo de log:**
```
[2025-11-24 15:30:00] INFO: Búsqueda de documento exitosa
User ID: 1
Document Type: dni
Document Number: 12345678
IP: 192.168.1.100
```

### Rate Limiting

- **Límite:** 30 solicitudes por minuto por usuario
- **Exceder límite:** Retorna código HTTP `429` (Too Many Requests)
- **Recomendación:** Implementar caché en el cliente para evitar búsquedas repetidas

### Información de Ubigeo

La información de ubigeo se obtiene de la base de datos local cuando está disponible en la respuesta del servicio externo. No todos los documentos tienen información de ubigeo completa.

### Verificación de Cliente Registrado

**Antes de consultar el servicio externo**, el sistema verifica si el documento ya está registrado en la base de datos local:

1. **Búsqueda en base de datos:** Se busca por `document_number` y `document_type`
2. **Si está registrado:**
   - Retorna código HTTP `409` (Conflict)
   - Incluye información del cliente y cazador responsable
   - **No consulta** el servicio externo (ahorra costos)
3. **Si no está registrado:**
   - Continúa con la búsqueda en el servicio externo
   - Retorna información completa de la persona/empresa

**Ventajas:**
- ✅ Evita consultas innecesarias al servicio externo
- ✅ Proporciona información del cazador responsable
- ✅ Previene duplicación de clientes
- ✅ Mejora la experiencia del usuario

### Seguridad

- 🔒 **Autenticación requerida:** Todas las búsquedas requieren token JWT válido
- 🛡️ **Validación estricta:** Se valida el formato antes de consultar el servicio externo
- 📊 **Auditoría completa:** Todas las búsquedas se registran para auditoría
- 🚫 **Prevención de abuso:** Rate limiting para prevenir uso excesivo

### Mejores Prácticas

1. **Validar en el cliente:** Validar formato antes de enviar la petición
2. **Manejar errores:** Implementar manejo robusto de errores
3. **Caché local:** Guardar resultados en caché para evitar búsquedas repetidas
4. **Reintentos:** Implementar lógica de reintentos con backoff exponencial
5. **Loading states:** Mostrar estados de carga mientras se procesa la búsqueda
6. **Validación de datos:** Verificar que los datos recibidos sean válidos antes de usarlos

---

## 🔗 Referencias

- [Documentación Principal de la API](./API_DOCUMENTATION.md)
- [Colección Postman](./API_POSTMAN_COLLECTION.json)
- [Referencia Rápida](./API_QUICK_REFERENCE.md)

---

## 📞 Soporte

Para soporte técnico o consultas sobre este servicio, contactar al equipo de desarrollo.

---

**Última actualización:** 2025-11-24  
**Versión del servicio:** 1.1

