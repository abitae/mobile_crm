# API Cazador - Clientes

## 📋 Descripción

Endpoints para gestionar clientes. Los cazadores solo pueden ver y gestionar clientes que les están asignados o que ellos mismos crearon.

## 👥 Endpoints

### 1. Listar Clientes

Obtiene una lista paginada de clientes asignados al cazador autenticado.

**Endpoint**: `GET /api/cazador/clients`

**Autenticación**: Requerida (JWT)

**Rate Limit**: 60 requests por minuto

#### Parámetros de Query

| Parámetro | Tipo | Requerido | Descripción |
|-----------|------|-----------|-------------|
| `per_page` | integer | No | Elementos por página (máximo 100, por defecto 15) |
| `page` | integer | No | Número de página (por defecto 1) |
| `search` | string | No | Búsqueda en nombre, teléfono o número de documento |
| `status` | string | No | Estado del cliente |
| `type` | string | No | Tipo de cliente |
| `source` | string | No | Origen del cliente |

#### Ejemplo de Solicitud

```bash
curl -X GET "https://tu-dominio.com/api/cazador/clients?per_page=20&status=activo" \
  -H "Authorization: Bearer {token}"
```

#### Respuesta Exitosa (200)

```json
{
  "success": true,
  "message": "Clientes obtenidos exitosamente",
  "data": {
    "clients": [
      {
        "id": 1,
        "name": "Carlos Rodríguez",
        "phone": "+51987654321",
        "document_type": "dni",
        "document_number": "12345678",
        "address": "Av. Principal 456",
        "birth_date": "1990-05-15",
        "client_type": "comprador",
        "source": "referido",
        "status": "activo",
        "score": 85,
        "notes": "Cliente interesado en lotes de 300m²",
        "assigned_advisor": {
          "id": 2,
          "name": "Juan Pérez",
          "email": "juan@example.com"
        },
        "created_at": "2024-01-01 10:00:00",
        "updated_at": "2024-01-15 14:30:00"
      }
    ],
    "pagination": {
      "current_page": 1,
      "per_page": 20,
      "total": 50,
      "last_page": 3,
      "from": 1,
      "to": 20
    }
  }
}
```

---

### 2. Obtener Cliente Específico

Obtiene los detalles completos de un cliente específico.

**Endpoint**: `GET /api/cazador/clients/{id}`

**Autenticación**: Requerida (JWT)

**Rate Limit**: 60 requests por minuto

#### Ejemplo de Solicitud

```bash
curl -X GET https://tu-dominio.com/api/cazador/clients/1 \
  -H "Authorization: Bearer {token}"
```

#### Respuesta Exitosa (200)

```json
{
  "success": true,
  "message": "Cliente obtenido exitosamente",
  "data": {
    "client": {
      "id": 1,
      "name": "Carlos Rodríguez",
      "phone": "+51987654321",
      "document_type": "dni",
      "document_number": "12345678",
      "address": "Av. Principal 456",
      "birth_date": "1990-05-15",
      "client_type": "comprador",
      "source": "referido",
      "status": "activo",
      "score": 85,
      "notes": "Cliente interesado en lotes de 300m²",
      "assigned_advisor": {
        "id": 2,
        "name": "Juan Pérez",
        "email": "juan@example.com"
      },
      "opportunities_count": 3,
      "activities_count": 12,
      "tasks_count": 2,
      "created_at": "2024-01-01 10:00:00",
      "updated_at": "2024-01-15 14:30:00"
    }
  }
}
```

#### Errores Posibles

- **401**: No autenticado
- **403**: No tienes permiso para acceder a este cliente
- **404**: Cliente no encontrado
- **500**: Error del servidor

---

### 3. Crear Cliente

Crea un nuevo cliente y lo asigna automáticamente al cazador autenticado.

**Endpoint**: `POST /api/cazador/clients`

**Autenticación**: Requerida (JWT)

**Rate Limit**: 60 requests por minuto

#### Parámetros

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| `name` | string | Sí | Nombre completo del cliente |
| `phone` | string | Sí | Teléfono de contacto |
| `document_type` | string | No | Tipo de documento (dni, ce, pasaporte) |
| `document_number` | string | No | Número de documento (único si se proporciona) |
| `address` | string | No | Dirección |
| `birth_date` | date | No | Fecha de nacimiento (formato: YYYY-MM-DD) |
| `client_type` | string | No | Tipo de cliente (comprador, vendedor, ambos) |
| `source` | string | No | Origen del cliente |
| `status` | string | No | Estado (por defecto: nuevo) |
| `score` | integer | No | Puntuación del cliente (0-100, por defecto: 0) |
| `notes` | string | No | Notas adicionales |

#### Ejemplo de Solicitud

```bash
curl -X POST https://tu-dominio.com/api/cazador/clients \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "María González",
    "phone": "+51912345678",
    "document_type": "dni",
    "document_number": "87654321",
    "address": "Av. Los Olivos 789",
    "birth_date": "1985-03-20",
    "client_type": "comprador",
    "source": "web",
    "status": "nuevo",
    "score": 0,
    "notes": "Cliente interesado en proyectos de lotes"
  }'
```

#### Respuesta Exitosa (201)

```json
{
  "success": true,
  "message": "Cliente creado exitosamente",
  "data": {
    "client": {
      "id": 2,
      "name": "María González",
      "phone": "+51912345678",
      "document_type": "dni",
      "document_number": "87654321",
      "address": "Av. Los Olivos 789",
      "birth_date": "1985-03-20",
      "client_type": "comprador",
      "source": "web",
      "status": "nuevo",
      "score": 0,
      "notes": "Cliente interesado en proyectos de lotes",
      "assigned_advisor": {
        "id": 2,
        "name": "Juan Pérez",
        "email": "juan@example.com"
      },
      "created_at": "2024-01-20 10:00:00",
      "updated_at": "2024-01-20 10:00:00"
    }
  }
}
```

#### Errores Posibles

- **401**: No autenticado
- **422**: Error de validación
- **500**: Error del servidor

---

### 4. Actualizar Cliente

Actualiza la información de un cliente existente.

**Endpoint**: `PUT /api/cazador/clients/{id}` o `PATCH /api/cazador/clients/{id}`

**Autenticación**: Requerida (JWT)

**Rate Limit**: 60 requests por minuto

> ⚠️ **Nota**: Solo puedes actualizar clientes que te están asignados o que creaste.

#### Parámetros

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| `name` | string | No | Nombre completo del cliente |
| `phone` | string | No | Teléfono de contacto |
| `document_type` | string | No | Tipo de documento |
| `document_number` | string | No | Número de documento (único si se proporciona) |
| `address` | string | No | Dirección |
| `birth_date` | date | No | Fecha de nacimiento |
| `client_type` | string | No | Tipo de cliente |
| `source` | string | No | Origen del cliente |
| `status` | string | No | Estado |
| `score` | integer | No | Puntuación (0-100) |
| `notes` | string | No | Notas adicionales |

#### Ejemplo de Solicitud

```bash
curl -X PUT https://tu-dominio.com/api/cazador/clients/1 \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Carlos Rodríguez Actualizado",
    "phone": "+51987654321",
    "status": "activo",
    "score": 90,
    "notes": "Cliente muy interesado, seguimiento activo"
  }'
```

#### Respuesta Exitosa (200)

```json
{
  "success": true,
  "message": "Cliente actualizado exitosamente",
  "data": {
    "client": {
      "id": 1,
      "name": "Carlos Rodríguez Actualizado",
      "phone": "+51987654321",
      // ... resto de campos actualizados ...
      "updated_at": "2024-01-20 15:30:00"
    }
  }
}
```

#### Errores Posibles

- **401**: No autenticado
- **403**: No tienes permiso para actualizar este cliente
- **404**: Cliente no encontrado
- **422**: Error de validación
- **500**: Error del servidor

---

### 5. Obtener Opciones para Formularios

Obtiene las opciones disponibles para campos de formularios (tipos de documento, estados, etc.).

**Endpoint**: `GET /api/cazador/clients/options`

**Autenticación**: Requerida (JWT)

**Rate Limit**: 120 requests por minuto

#### Ejemplo de Solicitud

```bash
curl -X GET https://tu-dominio.com/api/cazador/clients/options \
  -H "Authorization: Bearer {token}"
```

#### Respuesta Exitosa (200)

```json
{
  "success": true,
  "message": "Opciones obtenidas exitosamente",
  "data": {
    "document_types": ["dni", "ce", "pasaporte"],
    "client_types": ["comprador", "vendedor", "ambos"],
    "statuses": ["nuevo", "activo", "inactivo", "prospecto"],
    "sources": ["web", "referido", "redes_sociales", "evento", "otro"]
  }
}
```

---

## 📊 Estructura de Datos

### Cliente

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `id` | integer | ID del cliente |
| `name` | string | Nombre completo |
| `phone` | string | Teléfono de contacto |
| `document_type` | string | Tipo de documento |
| `document_number` | string | Número de documento |
| `address` | string | Dirección |
| `birth_date` | date | Fecha de nacimiento |
| `client_type` | string | Tipo de cliente |
| `source` | string | Origen del cliente |
| `status` | string | Estado |
| `score` | integer | Puntuación (0-100) |
| `notes` | string | Notas adicionales |
| `assigned_advisor` | object | Asesor asignado |
| `created_at` | datetime | Fecha de creación |
| `updated_at` | datetime | Fecha de actualización |

---

## 🔒 Permisos y Restricciones

### Reglas de Acceso

1. **Solo clientes asignados**: Los cazadores solo pueden ver y gestionar clientes que:
   - Están asignados a ellos (`assigned_advisor_id`)
   - Fueron creados por ellos (`created_by`)

2. **Asignación automática**: Al crear un cliente, se asigna automáticamente al cazador autenticado

3. **No se puede cambiar asignación**: Los cazadores no pueden cambiar la asignación de un cliente

### Validaciones

- **Documento único**: Si se proporciona `document_number`, debe ser único en el sistema
- **Teléfono**: Se sanitiza automáticamente (solo números y caracteres permitidos)
- **Score**: Debe estar entre 0 y 100
- **Email**: Si se proporciona, debe ser válido y único

---

## 🔍 Filtros Disponibles

### Filtros de Cliente

- **Búsqueda de texto**: Busca en nombre, teléfono o número de documento
- **Estado**: Filtra por estado del cliente
- **Tipo**: Filtra por tipo de cliente
- **Origen**: Filtra por origen del cliente

---

## 📝 Notas Importantes

1. **Asignación automática**: Los clientes creados se asignan automáticamente al cazador autenticado
2. **Permisos**: Solo puedes gestionar clientes asignados a ti o creados por ti
3. **Sanitización**: Los campos de texto se sanitizan automáticamente
4. **Documento único**: El número de documento debe ser único si se proporciona
5. **Paginación**: El endpoint de listado utiliza paginación (máximo 100 por página)

---

**Última actualización**: 2024-01-01

