# API Cazador – Documentación de endpoints

Documentación de referencia de la API para la aplicación Cazador (vendedores/asesores). Incluye descripción de rutas, parámetros, validaciones y ejemplos de request/response.

---

## Información general

| Concepto | Valor |
|----------|--------|
| **Base URL** | `{{base_url}}/api/cazador` (prueba . `https://v1.lotesenremate.pe/api/cazador`; produccion . `https://crm.lotesenremate.pe/api/cazador`) |
| **Autenticación** | JWT en header: `Authorization: Bearer <token>` |
| **Content-Type** | `application/json` para bodies JSON |
| **Middleware** | Rutas protegidas: `auth:api` + `cazador` (solo Admin, Líder, Cazador/vendedor) |

**Formato de respuesta estándar:**

- **Éxito:** `{ "success": true, "message": "...", "data": { ... } }`
- **Error de validación (422):** `{ "success": false, "message": "...", "errors": { "campo": ["mensaje"] } }`
- **Error genérico (4xx/5xx):** `{ "success": false, "message": "..." }` (opcionalmente `errors`)

**Paginación:** Las listas devuelven en `data` un objeto `pagination` con: `current_page`, `per_page`, `total`, `last_page`, `from`, `to`, `links` (`first`, `last`, `prev`, `next`).

**Health check (fuera de Cazador):** `GET /api/health` — público; retorna estado del sistema.

---

## 1. Autenticación (Auth)

Todas las rutas bajo el prefijo `/auth`. Login es público con rate limit 5 req/min; el resto requiere JWT.

| Método | Ruta | Descripción | Auth |
|--------|------|-------------|------|
| POST | `/auth/login` | Inicio de sesión (email + PIN 6 dígitos) | Público |
| GET | `/auth/me` | Usuario autenticado | JWT |
| POST | `/auth/logout` | Invalida el token actual | JWT |
| POST | `/auth/refresh` | Renueva el token | JWT |
| POST | `/auth/change-password` | Cambia PIN/contraseña | JWT |

### POST `/auth/login`

Inicia sesión con email y PIN de 6 dígitos numéricos. Solo pueden acceder usuarios con rol Administrador, Líder o Cazador (vendedor); los dateros reciben 403.

**Request (body JSON):**

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| email | string | Sí | Correo electrónico (formato válido) |
| password | string | Sí | PIN de 6 dígitos numéricos |

**Ejemplo request:**

```json
{
  "email": "vendedor@ejemplo.com",
  "password": "123456"
}
```

**Respuesta 200 (éxito):**

```json
{
  "success": true,
  "message": "Inicio de sesión exitoso",
  "data": {
    "token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
    "token_type": "bearer",
    "expires_in": 43200,
    "user": {
      "id": 1,
      "name": "Juan Pérez",
      "email": "vendedor@ejemplo.com",
      "phone": "987654321",
      "role": "vendedor",
      "is_active": true
    }
  }
}
```

**Posibles errores:** 401 (credenciales inválidas), 403 (rol no permitido o cuenta inactiva), 422 (validación).

---

### GET `/auth/me`

Devuelve los datos del usuario autenticado según el token JWT.

**Headers:** `Authorization: Bearer <token>`

**Respuesta 200:**

```json
{
  "success": true,
  "message": "Operación exitosa",
  "data": {
    "id": 1,
    "name": "Juan Pérez",
    "email": "vendedor@ejemplo.com",
    "phone": "987654321",
    "role": "vendedor",
    "is_active": true
  }
}
```

---

### POST `/auth/logout`

Invalida el token actual. No requiere body.

**Respuesta 200:**

```json
{
  "success": true,
  "message": "Sesión cerrada exitosamente"
}
```

---

### POST `/auth/refresh`

Devuelve un nuevo token renovado. Header: `Authorization: Bearer <token_actual>`.

**Respuesta 200:**

```json
{
  "success": true,
  "message": "Operación exitosa",
  "data": {
    "token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
    "token_type": "bearer",
    "expires_in": 43200
  }
}
```

---

### POST `/auth/change-password`

Cambia el PIN/contraseña del usuario autenticado.

**Request (body JSON):**

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| current_password | string | Sí | PIN actual (6 dígitos) |
| new_password | string | Sí | Nuevo PIN (6 dígitos) |
| new_password_confirmation | string | Sí | Confirmación del nuevo PIN |

**Ejemplo:**

```json
{
  "current_password": "123456",
  "new_password": "654321",
  "new_password_confirmation": "654321"
}
```

**Respuesta 200:** `{ "success": true, "message": "..." }`  
**Errores:** 422 (validación), 403 (PIN actual incorrecto).

---

## 2. Clientes (Clients)

Prefijo: `/clients`. Todas las rutas requieren JWT. El cazador solo ve y gestiona clientes cuyo `assigned_advisor_id` sea su propio `id`. Throttle: 60 req/min (options y suggestions pueden tener cache y límites distintos).

| Método | Ruta | Descripción |
|--------|------|-------------|
| GET | `/clients` | Lista clientes (paginada, filtros, include) |
| GET | `/clients/options` | Opciones para formularios (tipos, estados, fuentes, documento) |
| GET | `/clients/suggestions` | Sugerencias por texto (autocompletado) |
| GET | `/clients/batch` | Múltiples clientes por lista de IDs |
| GET | `/clients/export` | Exportar clientes a CSV |
| POST | `/clients/validate` | Valida datos de cliente sin crear (misma validación que POST /clients) |
| POST | `/clients` | Crear un cliente |
| POST | `/clients/batch` | Crear o actualizar clientes en lote |
| GET | `/clients/{id}` | Detalle de un cliente |
| PUT / PATCH | `/clients/{id}` | Actualizar cliente (solo reasignación de asesor) |
| GET | `/clients/{client}/activities` | Lista actividades del cliente |
| POST | `/clients/{client}/activities` | Crear actividad |
| PUT / PATCH | `/clients/{client}/activities/{activity}` | Actualizar actividad |

---

### GET `/clients`

Lista paginada de clientes asignados al cazador autenticado.

**Query params:**

| Parámetro | Tipo | Descripción |
|-----------|------|-------------|
| per_page | int | Resultados por página (default 15, max 100) |
| page | int | Página (default 1) |
| search | string | Búsqueda en nombre, teléfono, documento |
| status | string | Filtrar por estado del cliente |
| type | string | Filtrar por tipo de cliente |
| source | string | Filtrar por fuente |
| create_type | string | Filtrar por tipo de creación (propio, datero) |
| include | string | Relaciones extra: `assignedAdvisor`, `createdBy`, `activities`, `reservations`, `tasks`, `opportunities` (separadas por coma) |

**Ejemplo request:**

```
GET /api/cazador/clients?per_page=10&search=maria&status=nuevo
Authorization: Bearer <token>
```

**Respuesta 200:**

```json
{
  "success": true,
  "message": "Clientes obtenidos exitosamente",
  "data": {
    "clients": [
      {
        "id": 1,
        "name": "María García López",
        "phone": "987654321",
        "document_type": "DNI",
        "document_number": "12345678",
        "address": "Av. Ejemplo 123",
        "city_id": 1,
        "birth_date": "1990-05-15",
        "client_type": "comprador",
        "source": "referidos",
        "status": "nuevo",
        "create_type": "propio",
        "create_mode": "dni",
        "score": 0,
        "notes": null,
        "created_at": "2026-02-20 10:00:00",
        "updated_at": "2026-02-20 10:00:00",
        "city": { "id": 1, "name": "Lima" },
        "assigned_advisor": { "id": 2, "name": "Juan Pérez", "email": "vendedor@ejemplo.com" }
      }
    ],
    "pagination": {
      "current_page": 1,
      "per_page": 10,
      "total": 25,
      "last_page": 3,
      "from": 1,
      "to": 10,
      "links": {
        "first": "https://api.ejemplo.com/api/cazador/clients?page=1",
        "last": "https://api.ejemplo.com/api/cazador/clients?page=3",
        "prev": null,
        "next": "https://api.ejemplo.com/api/cazador/clients?page=2"
      }
    }
  }
}
```

---

### GET `/clients/options`

Devuelve opciones para combos/selects de formularios de cliente. Cache recomendado: 300 s.

**Respuesta 200:**

```json
{
  "success": true,
  "message": "Opciones obtenidas exitosamente",
  "data": {
    "document_types": { "DNI": "DNI" },
    "client_types": {
      "inversor": "Inversor",
      "comprador": "Comprador",
      "empresa": "Empresa",
      "constructor": "Constructor"
    },
    "sources": {
      "redes_sociales": "Redes Sociales",
      "ferias": "Ferias",
      "referidos": "Referidos",
      "formulario_web": "Formulario Web",
      "publicidad": "Publicidad"
    },
    "statuses": {
      "nuevo": "Nuevo",
      "contacto_inicial": "Contacto Inicial",
      "en_seguimiento": "En Seguimiento",
      "cierre": "Cierre",
      "perdido": "Perdido"
    }
  }
}
```

---

### GET `/clients/suggestions`

Sugerencias para autocompletado por nombre, teléfono o documento.

**Query params:**

| Parámetro | Tipo | Descripción |
|-----------|------|-------------|
| q | string | Texto de búsqueda (mín. 2 caracteres) |
| limit | int | Máximo de sugerencias (default 10, max 20) |

**Ejemplo:** `GET /api/cazador/clients/suggestions?q=mar&limit=5`

**Respuesta 200:**

```json
{
  "success": true,
  "message": "Sugerencias obtenidas",
  "data": {
    "suggestions": [
      { "id": 1, "name": "María García", "phone": "987654321", "document_number": "12345678" }
    ]
  }
}
```

Si `q` tiene menos de 2 caracteres, `suggestions` viene vacío.

---

### POST `/clients/validate`

Valida los datos del formulario de cliente **sin crear** el cliente. Pensado para que la app móvil valide antes de enviar el formulario definitivo. Mismo body que POST `/clients`; mismas reglas (teléfono obligatorio y único, documento opcional y único si se envía, tipo solo DNI, etc.).

**Request (body JSON):** Los mismos campos que POST `/clients` (name, phone, document_type, document_number, address, city_id, birth_date, client_type, source, status, score, notes, create_mode, etc.).

**Respuesta 200 (válido):**

```json
{
  "success": true,
  "message": "Validación de cliente exitosa",
  "data": { "valid": true }
}
```

**Respuesta 200 (inválido):** Se devuelve 200 con `valid: false` y los errores (y opcionalmente quién tiene el teléfono/documento si ya existe).

```json
{
  "success": true,
  "message": "Telefono registrado por \"Ana López\"",
  "data": {
    "valid": false,
    "errors": { "phone": ["El teléfono ya está en uso."] },
    "duplicate_owner": { "name": "Ana López", "user_id": 3, "client_id": 10, "field": "phone" }
  }
}
```

---

### POST `/clients`

Crea un cliente asignado al cazador autenticado (`assigned_advisor_id` y `created_by` = usuario actual). El tipo de documento admitido es solo **DNI**; `document_type` y `document_number` son **opcionales**. El **teléfono es obligatorio** y debe ser único (9 dígitos, empezando por 9). Si se envía `document_number`, debe ser único (se excluyen valor null y `00000000`).

**Request (body JSON):**

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| name | string | Sí | Nombre completo (max 255) |
| phone | string | Sí | Teléfono 9 dígitos, empieza en 9, único |
| document_type | string | No | Solo aceptado: `DNI` (opcional) |
| document_number | string | No | Número de documento (max 20). Si se envía, único (null y 00000000 excluidos) |
| address | string | No | Dirección (max 500) |
| city_id | int | Sí | ID de ciudad (exists en `cities`) |
| birth_date | string | Sí | Fecha nacimiento (Y-m-d) |
| client_type | string | Sí | `inversor`, `comprador`, `empresa`, `constructor` |
| source | string | Sí | `redes_sociales`, `ferias`, `referidos`, `formulario_web`, `publicidad` |
| status | string | Sí | `nuevo`, `contacto_inicial`, `en_seguimiento`, `cierre`, `perdido` |
| score | int | Sí | 0–100 |
| notes | string | No | Notas |
| create_mode | string | No | `dni` o `phone`. Si no se envía: `phone` si no hay document_number, sino `dni` |
| create_type | string | No | No necesario; el servicio asigna según rol |

**Ejemplo request (con DNI opcional):**

```json
{
  "name": "Rosa Martínez",
  "phone": "987654321",
  "document_type": "DNI",
  "document_number": "87654321",
  "address": "Calle Los Pinos 456",
  "city_id": 1,
  "birth_date": "1985-03-20",
  "client_type": "comprador",
  "source": "referidos",
  "status": "nuevo",
  "score": 0,
  "notes": "Cliente referido por María"
}
```

**Ejemplo request (sin documento):**

```json
{
  "name": "Luis Fernández",
  "phone": "912345678",
  "address": null,
  "city_id": 2,
  "birth_date": "1992-08-10",
  "client_type": "comprador",
  "source": "redes_sociales",
  "status": "nuevo",
  "score": 0,
  "notes": null
}
```

**Respuesta 201 (éxito):**

```json
{
  "success": true,
  "message": "Cliente creado exitosamente",
  "data": {
    "client": {
      "id": 42,
      "name": "Rosa Martínez",
      "phone": "987654321",
      "document_type": "DNI",
      "document_number": "87654321",
      "address": "Calle Los Pinos 456",
      "city_id": 1,
      "birth_date": "1985-03-20",
      "client_type": "comprador",
      "source": "referidos",
      "status": "nuevo",
      "create_type": "propio",
      "create_mode": "dni",
      "score": 0,
      "notes": "Cliente referido por María",
      "created_at": "2026-02-20 14:30:00",
      "updated_at": "2026-02-20 14:30:00",
      "city": { "id": 1, "name": "Lima" },
      "assigned_advisor": { "id": 2, "name": "Juan Pérez", "email": "vendedor@ejemplo.com" }
    }
  }
}
```

**Respuesta 422 (validación – duplicado):** Si el teléfono o el documento ya existen, se incluye información del titular:

```json
{
  "success": false,
  "message": "Telefono registrado por \"Ana López\"",
  "errors": {
    "phone": ["El teléfono ya está en uso."]
  },
  "duplicate_owner": {
    "name": "Ana López",
    "user_id": 3,
    "client_id": 10,
    "field": "phone"
  }
}
```

---

### POST `/clients/batch`

Crea y/o actualiza varios clientes en una sola petición. Cada ítem del array puede ser creación (sin `id`) o actualización (con `id`). En actualización solo se permite cambiar `assigned_advisor_id`.

**Request (body JSON):**

| Campo | Tipo | Descripción |
|-------|------|-------------|
| clients | array | Lista de objetos cliente (ver campos de POST /clients para creación; para actualización: `id` y opcionalmente `assigned_advisor_id`) |

**Ejemplo request:**

```json
{
  "clients": [
    {
      "name": "Cliente Nuevo 1",
      "phone": "998877665",
      "city_id": 1,
      "birth_date": "1990-01-01",
      "client_type": "comprador",
      "source": "referidos",
      "status": "nuevo",
      "score": 0
    },
    {
      "id": 5,
      "assigned_advisor_id": 2
    }
  ]
}
```

**Respuesta 200:**

```json
{
  "success": true,
  "message": "Batch de clientes procesado",
  "data": {
    "created": [
      { "id": 43, "name": "Cliente Nuevo 1", "phone": "998877665", ... }
    ],
    "updated": [
      { "id": 5, "name": "...", "assigned_advisor_id": 2, ... }
    ],
    "errors": [
      { "index": 2, "errors": { "phone": ["El teléfono ya está en uso."] }, "duplicate_owner": { ... }, "message": "..." }
    ]
  }
}
```

`errors` contiene por cada ítem fallido: `index`, `errors` y opcionalmente `duplicate_owner` y `message`.

---

### GET `/clients/batch`

Obtiene varios clientes por una lista de IDs. Solo se devuelven clientes asignados al cazador.

**Query params:**

| Parámetro | Tipo | Descripción |
|-----------|------|-------------|
| ids | string | IDs separados por coma (ej. `1,2,3`) |

**Ejemplo:** `GET /api/cazador/clients/batch?ids=1,2,5`

**Respuesta 200:** `data.clients` es un array de objetos cliente con el mismo formato que en GET `/clients`.

---

### GET `/clients/{id}`

Detalle de un cliente. Solo se permite si el cliente está asignado al cazador.

**Query params:** `include` (opcional), mismos valores que en GET `/clients`.

**Respuesta 200:** `data.client` incluye los mismos campos que en la lista, más (si aplica) `opportunities_count`, `activities_count`, `tasks_count`.

**Errores:** 404 (cliente no encontrado), 403 (no asignado al cazador).

---

### PUT / PATCH `/clients/{id}`

Actualiza un cliente. En la API Cazador **solo se puede cambiar el asesor asignado** (`assigned_advisor_id`). El cliente debe estar asignado al cazador autenticado.

**Request (body JSON):**

| Campo | Tipo | Descripción |
|-------|------|-------------|
| assigned_advisor_id | int | ID del usuario (asesor) al que se reasigna el cliente (opcional) |

**Ejemplo:**

```json
{
  "assigned_advisor_id": 3
}
```

**Respuesta 200:** `data.client` con el cliente actualizado (incluyendo `assigned_advisor`).

**Errores:** 404, 403, 422 (si `assigned_advisor_id` no existe).

---

### GET `/clients/export`

Exporta los clientes del cazador a CSV. Query params de filtro iguales que GET `/clients` (search, status, type, source, create_type, etc.). Respuesta: contenido CSV con headers apropiados.

---

### Actividades del cliente

- **GET `/clients/{client}/activities`** — Lista actividades del cliente (paginada; query: per_page, status, activity_type, priority, fechas, search).
- **POST `/clients/{client}/activities`** — Crea una actividad (body según ActivityService: title, activity_type, start_date, etc.).
- **PUT/PATCH `/clients/{client}/activities/{activity}`** — Actualiza actividad (status, result, notes, start_date, assigned_to).

El `client` en la ruta es el ID del cliente; debe estar asignado al cazador.

---

## 3. Ciudades (Cities)

| Método | Ruta | Descripción | Auth |
|--------|------|-------------|------|
| GET | `/cities` | Lista ciudades (paginada, búsqueda) | JWT |

### GET `/cities`

Lista de ciudades para formularios y filtros.

**Query params:**

| Parámetro | Tipo | Descripción |
|-----------|------|-------------|
| search | string | Filtro por nombre (LIKE) |
| per_page | int | Por página (default 100, max 500) |

**Ejemplo:** `GET /api/cazador/cities?search=lim&per_page=50`

**Respuesta 200:**

```json
{
  "success": true,
  "message": "Ciudades obtenidas exitosamente",
  "data": {
    "cities": [
      { "id": 1, "name": "Lima" },
      { "id": 2, "name": "Lima Metropolitana" }
    ],
    "pagination": {
      "current_page": 1,
      "per_page": 50,
      "total": 2,
      "last_page": 1,
      "from": 1,
      "to": 2,
      "links": { "first": "...", "last": "...", "prev": null, "next": null }
    }
  }
}
```

Cache recomendado: 300 s.

---

## 4. Proyectos (Projects)

Prefijo: `/projects`. Acceso a lista completa de proyectos (no solo publicados).

| Método | Ruta | Descripción |
|--------|------|-------------|
| GET | `/projects` | Lista proyectos (filtros, include) |
| GET | `/projects/suggestions` | Sugerencias por texto (`q`, `limit`) |
| GET | `/projects/{id}` | Detalle de proyecto |
| GET | `/projects/{id}/units` | Unidades del proyecto |

**GET `/projects`** — Query: `per_page`, `search`, `project_type`, `lote_type`, `stage`, `legal_status`, `status`, `district`, `province`, `region`, `has_available_units`, `include`.

**GET `/projects/{id}`** — Opcionales: `include_units`, `units_per_page`, `include`.

---

## 5. Dateros

Prefijo: `/dateros`. Solo usuarios con acceso a API Cazador (Admin, Líder, Cazador).

| Método | Ruta | Descripción |
|--------|------|-------------|
| GET | `/dateros` | Lista dateros (per_page, search, is_active) |
| POST | `/dateros` | Registra datero (lider_id = usuario autenticado) |
| GET | `/dateros/{id}` | Detalle de un datero |
| PUT / PATCH | `/dateros/{id}` | Actualiza datero |

**POST `/dateros`** — Body: `name`, `email`, `phone`, `dni`, `pin` (requeridos); `ocupacion`, `banco`, `cuenta_bancaria`, `cci_bancaria` (opcionales). El datero queda con `lider_id` = id del usuario que hace la petición.

---

## 6. Dashboard

| Método | Ruta | Descripción | Auth |
|--------|------|-------------|------|
| GET | `/dashboard/stats` | Estadísticas (clientes, dateros, proyectos, reservas) | JWT |

**GET `/dashboard/stats`** — Query opcionales de fechas/filtros. Respuesta: objeto con métricas según rol. Cache típico: 60 s.

---

## 7. Reservas (Reservations)

Prefijo: `/reservations`. Si el usuario no es admin/líder, solo ve sus propias reservas.

| Método | Ruta | Descripción |
|--------|------|-------------|
| GET | `/reservations` | Lista reservas (filtros) |
| GET | `/reservations/export` | Exporta reservas a CSV |
| POST | `/reservations` | Crea reserva (estado activa) |
| POST | `/reservations/batch` | Crea reservas en lote |
| GET | `/reservations/{id}` | Detalle |
| PUT / PATCH | `/reservations/{id}` | Actualiza reserva activa |
| POST | `/reservations/{id}/confirm` | Confirma (sube comprobante, multipart) |
| POST | `/reservations/{id}/cancel` | Cancela (body: cancel_note) |
| POST | `/reservations/{id}/convert-to-sale` | Convierte a venta |

**POST `/reservations`** — Body: `client_id`, `project_id`, `unit_id`, `reservation_amount` (requeridos); `payment_method`, `payment_reference`, `notes`, `terms_conditions` (opcionales). Se asigna `advisor_id` al usuario autenticado.

**POST `/reservations/{id}/confirm`** — Multipart: `image` (file requerido); opcionales: `reservation_date`, `expiration_date`, `reservation_amount`, `payment_method`, `payment_status`, `payment_reference`.

**POST `/reservations/{id}/cancel`** — Body: `cancel_note` (string, min 10, max 500).

---

## 8. Documentos

| Método | Ruta | Descripción | Auth |
|--------|------|-------------|------|
| POST | `/documents/search` | Búsqueda en servicio externo de documentos | JWT |

Throttle: 30 req/min. La validación de datos (incl. DNI) se realiza en los controladores que crean/actualizan recursos (clientes, etc.), no en un endpoint separado de validación.

---

## 9. Sincronización (Sync)

| Método | Ruta | Descripción | Auth |
|--------|------|-------------|------|
| GET | `/sync` | Sincroniza cambios desde una fecha | JWT |

**Query:** `since` (ej. `2026-01-01T00:00:00Z`).  
**Respuesta:** `clients`, `reservations`, `projects`, `sync_timestamp`. Throttle: 30 req/min.

---

## 10. Reportes

| Método | Ruta | Descripción | Auth |
|--------|------|-------------|------|
| GET | `/reports/sales` | Reporte de ventas en CSV | JWT |

**Query:** `date_from`, `date_to` (opcionales). Throttle: 30 req/min.

---

## Índice de rutas (resumen)

Todas relativas a la base URL de la API Cazador (ej. `/api/cazador`).

```
POST   /auth/login
GET    /auth/me
POST   /auth/logout
POST   /auth/refresh
POST   /auth/change-password

GET    /clients
GET    /clients/options
GET    /clients/suggestions
GET    /clients/batch
GET    /clients/export
POST   /clients/validate
POST   /clients
POST   /clients/batch
GET    /clients/{id}
PUT    /clients/{id}
PATCH  /clients/{id}
GET    /clients/{client}/activities
POST   /clients/{client}/activities
PUT    /clients/{client}/activities/{activity}
PATCH  /clients/{client}/activities/{activity}

GET    /cities

GET    /projects
GET    /projects/suggestions
GET    /projects/{id}
GET    /projects/{id}/units

GET    /dateros
POST   /dateros
GET    /dateros/{id}
PUT    /dateros/{id}
PATCH  /dateros/{id}

GET    /dashboard/stats

GET    /reservations
GET    /reservations/export
POST   /reservations
POST   /reservations/batch
GET    /reservations/{id}
PUT    /reservations/{id}
PATCH  /reservations/{id}
POST   /reservations/{id}/confirm
POST   /reservations/{id}/cancel
POST   /reservations/{id}/convert-to-sale

POST   /documents/search

GET    /sync

GET    /reports/sales
```

Health: `GET /api/health` (sin prefijo cazador).
