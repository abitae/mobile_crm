# API Cazador - Búsqueda de Documentos

## 📋 Descripción

Endpoint para buscar información completa de personas (DNI) o empresas (RUC) utilizando el servicio externo de Facturalahoy. El sistema verifica primero si el documento ya está registrado en la base de datos antes de realizar la búsqueda externa.

## 🔍 Endpoint

### Buscar Documento (DNI/RUC)

Busca información completa de una persona o empresa por su número de documento.

**Endpoint**: `POST /api/cazador/documents/search`

**Autenticación**: Requerida (JWT)

**Rate Limit**: 30 requests por minuto

#### Parámetros

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| `document_type` | string | Sí | Tipo de documento: `dni` o `ruc` |
| `document_number` | string | Sí | Número de documento (solo dígitos) |

#### Validaciones

- **DNI**: Debe tener exactamente 8 dígitos
- **RUC**: Debe tener exactamente 11 dígitos
- El número de documento solo puede contener dígitos (0-9)

#### Ejemplo de Solicitud

```bash
curl -X POST https://tu-dominio.com/api/cazador/documents/search \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "document_type": "dni",
    "document_number": "12345678"
  }'
```

#### Respuesta Exitosa (200) - Documento Encontrado

Cuando el documento se encuentra en el servicio externo y no está registrado en la base de datos:

```json
{
  "success": true,
  "message": "Datos encontrados exitosamente",
  "data": {
    "found": true,
    "document_type": "dni",
    "document_number": "12345678",
    "data": {
      "respuesta": "ok",
      "api": {
        "result": {
          "dni": "12345678",
          "nombres": "JUAN CARLOS",
          "apellidoPaterno": "PÉREZ",
          "apellidoMaterno": "GARCÍA",
          "codVerifica": "1",
          "depaDireccion": "LIMA",
          "provDireccion": "LIMA",
          "distDireccion": "SAN ISIDRO",
          "direccion": "AV. PRINCIPAL 123",
          "estadoCivil": "SOLTERO",
          "fechaNacimiento": "1990-05-15"
        }
      }
    },
    "ubigeo": {
      "text": "LIMA - LIMA - SAN ISIDRO",
      "code": "150131"
    }
  }
}
```

#### Respuesta de Error (409) - Cliente Ya Registrado

Cuando el documento ya está registrado en la base de datos:

```json
{
  "success": false,
  "message": "Cliente registrado por el cazador responsable de ese cliente",
  "errors": {
    "client_registered": true,
    "client_id": 5,
    "client_name": "Juan Carlos Pérez García",
    "assigned_advisor": {
      "id": 3,
      "name": "María González",
      "email": "maria@example.com"
    },
    "message": "El cliente ya está registrado. Cazador responsable: María González"
  }
}
```

#### Respuesta de Error (404) - Documento No Encontrado

Cuando el documento no se encuentra en el servicio externo:

```json
{
  "success": false,
  "message": "No se encontró información para el documento proporcionado"
}
```

#### Respuesta de Error (422) - Error de Validación

```json
{
  "success": false,
  "message": "Error de validación",
  "errors": {
    "document_type": ["El tipo de documento es obligatorio."],
    "document_number": ["El DNI debe tener exactamente 8 dígitos."]
  }
}
```

#### Errores Posibles

- **400**: Solicitud incorrecta
- **401**: No autenticado
- **404**: Documento no encontrado en el servicio externo
- **409**: Cliente ya registrado en la base de datos
- **422**: Error de validación (formato incorrecto)
- **500**: Error del servidor

---

## 📊 Estructura de Datos

### Respuesta Exitosa

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `found` | boolean | Indica si el documento fue encontrado |
| `document_type` | string | Tipo de documento (dni o ruc) |
| `document_number` | string | Número de documento |
| `data` | object | Datos completos del documento desde el servicio externo |
| `ubigeo` | object | Información de ubigeo (opcional) |

### Datos de DNI

Cuando `document_type` es `dni`, la respuesta incluye:

- `dni`: Número de DNI
- `nombres`: Nombres completos
- `apellidoPaterno`: Apellido paterno
- `apellidoMaterno`: Apellido materno
- `codVerifica`: Código de verificación
- `depaDireccion`: Departamento de dirección
- `provDireccion`: Provincia de dirección
- `distDireccion`: Distrito de dirección
- `direccion`: Dirección completa
- `estadoCivil`: Estado civil
- `fechaNacimiento`: Fecha de nacimiento

### Datos de RUC

Cuando `document_type` es `ruc`, la respuesta incluye información de la empresa:

- `ruc`: Número de RUC
- `razonSocial`: Razón social
- `nombreComercial`: Nombre comercial
- `estado`: Estado del contribuyente
- `condicion`: Condición del contribuyente
- `direccion`: Dirección completa
- `ubigeo`: Código de ubigeo

### Información de Ubigeo

Cuando está disponible, se incluye:

```json
{
  "ubigeo": {
    "text": "LIMA - LIMA - SAN ISIDRO",
    "code": "150131"
  }
}
```

---

## 🔄 Flujo de Búsqueda

### Proceso Completo

1. **Validación de Entrada**
   - Valida que `document_type` sea `dni` o `ruc`
   - Valida que `document_number` contenga solo dígitos
   - Valida longitud: DNI = 8 dígitos, RUC = 11 dígitos

2. **Verificación en Base de Datos**
   - Busca si el documento ya está registrado como cliente
   - Si está registrado:
     * Retorna error 409 con información del cliente
     * Incluye información del asesor asignado
     * No realiza búsqueda externa

3. **Búsqueda Externa** (si no está registrado)
   - Consulta el servicio de Facturalahoy
   - Obtiene información completa del documento
   - Procesa información de ubigeo si está disponible

4. **Respuesta**
   - Formatea los datos obtenidos
   - Incluye información de ubigeo si está disponible
   - Registra la búsqueda en logs

---

## 🔒 Validaciones y Reglas

### Validaciones de Entrada

1. **Tipo de Documento**
   - Debe ser exactamente `dni` o `ruc` (case insensitive)
   - No se aceptan otros tipos

2. **Número de Documento**
   - Solo puede contener dígitos (0-9)
   - DNI: exactamente 8 dígitos
   - RUC: exactamente 11 dígitos
   - Se sanitiza automáticamente (elimina caracteres no numéricos)

3. **Sanitización Automática**
   - El tipo de documento se convierte a minúsculas
   - El número de documento se limpia de caracteres no numéricos
   - Se eliminan espacios en blanco

### Verificación de Cliente Registrado

- **Búsqueda**: Por `document_number` y `document_type`
- **Relaciones**: Incluye información del asesor asignado
- **Respuesta**: Si está registrado, retorna error 409 con detalles

---

## 📝 Casos de Uso

### Caso 1: Buscar DNI Nuevo

**Solicitud**:
```json
{
  "document_type": "dni",
  "document_number": "12345678"
}
```

**Resultado**: Retorna datos completos de la persona si se encuentra en el servicio externo.

### Caso 2: Buscar RUC Nuevo

**Solicitud**:
```json
{
  "document_type": "ruc",
  "document_number": "20123456789"
}
```

**Resultado**: Retorna datos completos de la empresa si se encuentra en el servicio externo.

### Caso 3: Documento Ya Registrado

**Solicitud**:
```json
{
  "document_type": "dni",
  "document_number": "87654321"
}
```

**Resultado**: Retorna error 409 con información del cliente y su asesor asignado.

### Caso 4: Documento No Encontrado

**Solicitud**:
```json
{
  "document_type": "dni",
  "document_number": "00000000"
}
```

**Resultado**: Retorna error 404 indicando que no se encontró información.

---

## 🔍 Logging

Todas las búsquedas se registran en los logs del sistema:

### Logs de Búsqueda Exitosa

```php
Log::info('Búsqueda de documento exitosa', [
    'document_type' => 'dni',
    'document_number' => '12345678',
    'user_id' => 1
]);
```

### Logs de Cliente Ya Registrado

```php
Log::info('Intento de búsqueda de documento ya registrado', [
    'document_type' => 'dni',
    'document_number' => '12345678',
    'client_id' => 5,
    'assigned_advisor_id' => 3,
    'user_id' => 1
]);
```

### Logs de Error

```php
Log::warning('Error en búsqueda de documento', [
    'document_type' => 'dni',
    'document_number' => '12345678',
    'error' => 'Mensaje de error',
    'user_id' => 1
]);
```

---

## ⚠️ Notas Importantes

1. **Servicio Externo**: Utiliza el servicio de Facturalahoy para búsquedas
2. **Verificación Previa**: Siempre verifica si el cliente ya está registrado antes de buscar externamente
3. **Información de Asesor**: Si el cliente está registrado, se incluye información del asesor asignado
4. **Ubigeo**: La información de ubigeo se obtiene de la base de datos local basada en el código del servicio externo
5. **Sanitización**: Los datos de entrada se sanitizan automáticamente
6. **Rate Limiting**: 30 requests por minuto para prevenir abuso
7. **Timeout**: El servicio externo tiene un timeout de 400 segundos

---

## 🔐 Seguridad

### Validaciones de Seguridad

1. **Autenticación**: Requiere token JWT válido
2. **Validación de Formato**: Valida formato de DNI/RUC antes de consultar
3. **Sanitización**: Limpia y normaliza datos de entrada
4. **Logging**: Registra todas las búsquedas para auditoría
5. **Rate Limiting**: Limita el número de consultas por minuto

### Información Sensible

- Los números de documento se registran en logs (para auditoría)
- La información del cliente registrado se retorna solo si el usuario tiene acceso
- Los errores detallados solo se muestran en modo debug

---

## 📈 Ejemplos de Integración

### Ejemplo en JavaScript (Fetch)

```javascript
async function searchDocument(documentType, documentNumber) {
  try {
    const response = await fetch('https://tu-dominio.com/api/cazador/documents/search', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        document_type: documentType,
        document_number: documentNumber
      })
    });

    const data = await response.json();

    if (data.success) {
      console.log('Documento encontrado:', data.data);
      return data.data;
    } else {
      if (response.status === 409) {
        console.log('Cliente ya registrado:', data.errors);
      } else {
        console.error('Error:', data.message);
      }
      return null;
    }
  } catch (error) {
    console.error('Error de red:', error);
    return null;
  }
}

// Uso
searchDocument('dni', '12345678');
```

### Ejemplo en PHP (Guzzle)

```php
use GuzzleHttp\Client;

$client = new Client();

$response = $client->post('https://tu-dominio.com/api/cazador/documents/search', [
    'headers' => [
        'Authorization' => 'Bearer ' . $token,
        'Content-Type' => 'application/json',
    ],
    'json' => [
        'document_type' => 'dni',
        'document_number' => '12345678',
    ],
]);

$data = json_decode($response->getBody(), true);

if ($data['success']) {
    echo "Documento encontrado: " . $data['data']['data']->api->result->nombres;
} else {
    echo "Error: " . $data['message'];
}
```

---

**Última actualización**: 2024-01-01

