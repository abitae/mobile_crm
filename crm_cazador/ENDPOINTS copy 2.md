## API Cazador - Endpoints

Base URL: `/api/cazador`
Versionado opcional: `/api/v1/cazador`

Autenticacion:
- Usa JWT en header `Authorization: Bearer <token>`
- Rutas protegidas con `auth:api` y middleware `cazador`
- Respuestas de lista incluyen `pagination` con `links` (`first`, `last`, `prev`, `next`) cuando aplica.

Formato de respuesta (alto nivel):
- Respuesta exitosa: `successResponse` con `message` y `data`.
- Respuesta con error: `errorResponse` o `validationErrorResponse`.

---

### Auth

POST `/auth/login`
- Descripcion: Inicia sesion para usuarios con acceso a Cazador.
- Auth: Publico.
- Body:
  - `email` (string, requerido)
  - `password` (string, requerido)
- Respuesta (data):
  - `token`, `token_type`, `expires_in`
  - `user`: `id`, `name`, `email`, `phone`, `role`, `is_active`

GET `/auth/me`
- Descripcion: Retorna el usuario autenticado.
- Auth: Requiere JWT.
- Respuesta (data): datos basicos de usuario.

POST `/auth/logout`
- Descripcion: Invalida el token actual.
- Auth: Requiere JWT.

POST `/auth/refresh`
- Descripcion: Renueva el token.
- Auth: Requiere JWT.

POST `/auth/change-password`
- Body:
  - `current_password` (string, requerido)
  - `new_password` (string, requerido, min 6, confirmed)
  - `new_password_confirmation` (string, requerido)
- Auth: Requiere JWT.

---

### Health

GET `/health`
- Descripcion: Health check publico del API.
- Auth: Publico.
- Respuesta (data):
  - `status`: `healthy` | `degraded`
  - `checks`: `database`, `cache`, `storage`

---

### Clientes

Notas:
- Auth: Requiere JWT.
- Permisos: solo clientes asignados o creados por el cazador.

GET `/clients`
- Descripcion: Lista clientes asignados o creados por el cazador.
- Query:
  - `per_page` (int, opcional)
  - `search` (string, opcional)
  - `status` (string, opcional)
  - `type` (string, opcional)
  - `source` (string, opcional)
  - `create_type` (string, opcional)
  - `include` (string, opcional, ej: `activities,reservations`)
- Respuesta:
  - `clients` (array de clientes formateados)
  - `pagination` (objeto con `current_page`, `per_page`, `total`, `last_page`, `from`, `to`, `links`)
- Ejemplo:
  - `/clients?search=juan&status=nuevo&include=activities,reservations`
- Notas:
  - La busqueda (`search`) aplica sobre `name`, `document_number` (DNI) y `phone`.

GET `/clients/suggestions`
- Descripcion: Sugerencias de clientes por texto.
- Query:
  - `q` (string, requerido, min 2)
  - `limit` (int, opcional)
- Notas:
  - La busqueda (`q`) aplica sobre `name`, `document_number` (DNI) y `phone`.

GET `/clients/batch?ids=1,2,3`
- Descripcion: Obtiene multiples clientes por IDs.
- Notas:
  - Solo retorna clientes permitidos por el cazador.

POST `/clients/batch`
- Descripcion: Crea o actualiza clientes en batch.
- Body:
  - `clients` (array, requerido)
- Notas:
  - Si un item incluye `id`, se interpreta como update.
  - Respuesta incluye `created`, `updated` y `errors` por indice.
  - Si un item falla por `phone` o `document_number` duplicado, `errors` incluye `duplicate_owner`.

POST `/clients/validate`
- Descripcion: Valida payload de cliente sin persistir.
- Respuesta:
  - `valid` (bool)
  - `errors` (objeto) cuando aplica
- Notas:
  - `create_mode` es obligatorio: `dni` o `phone`.
  - Si `create_mode` es `phone`, `document_type` y `document_number` son opcionales.
  - Si `create_mode` es `dni`, `document_type` y `document_number` son obligatorios.
  - Si el `phone` o `document_number` ya existe, `errors` puede incluir `duplicate_owner`.

POST `/clients`
- Descripcion: Crea un cliente y lo asigna al cazador autenticado.
- Body:
  - `create_mode` (string, requerido: `dni|phone`)
  - `name` (string, requerido)
  - `phone` (string, requerido, 9 digitos y empieza en 9, unico)
  - `document_type` (string, requerido si `create_mode = dni`)
  - `document_number` (string, requerido si `create_mode = dni`)
  - `address` (string, opcional)
  - `birth_date` (date, requerido)
  - `client_type` (string, requerido)
  - `source` (string, requerido)
  - `status` (string, requerido)
  - `create_type` (string, opcional)
  - `score` (int, requerido, 0-100)
  - `notes` (string, opcional)
- Notas:
  - `assigned_advisor_id` se asigna al usuario autenticado.
  - Se aplican sanitizaciones basicas (telefono, documento, notas).
  - Validacion de telefono: 9 digitos empezando con 9, unico.
  - Si `create_mode = phone`, no se requiere DNI.
  - Si el `phone` o `document_number` ya existe, el API devuelve el nombre del vendedor que lo registro.

GET `/clients/options`
- Descripcion: Opciones para formularios (tipos, estados, fuentes, etc).

GET `/clients/{id}`
- Descripcion: Obtiene un cliente especifico.
- Query:
  - `include` (string, opcional)
- Respuesta:
  - `client` (objeto con campos del cliente y contadores `opportunities_count`, `activities_count`, `tasks_count`)
- Notas:
  - Solo accesible si el cliente esta asignado o fue creado por el cazador.

PUT/PATCH `/clients/{id}`
- Descripcion: Actualiza un cliente asignado o creado por el cazador.
- Body: mismos campos que POST (incluye `create_mode`).
- Notas:
  - No permite cambiar `assigned_advisor_id` si no pertenece al cazador.

POST `/clients/{client}/activities`
- Descripcion: Crea una actividad para el cliente.
- Body: campos de actividad segun `ActivityService`.

GET `/clients/{client}/activities`
- Descripcion: Lista actividades del cliente con filtros.
- Query:
  - `per_page` (int, opcional)
  - `status` (string, opcional)
  - `activity_type` (string, opcional)
  - `priority` (string, opcional)
  - `start_date_from` (date, opcional)
  - `start_date_to` (date, opcional)
  - `search` (string, opcional)
- Respuesta:
  - `activities` (array de actividades con relaciones `advisor` y `assigned_to`)
  - `pagination` (objeto con `current_page`, `per_page`, `total`, `last_page`, `from`, `to`, `links`)

PUT/PATCH `/clients/{client}/activities/{activity}`
- Descripcion: Actualiza una actividad del cliente (campos limitados).
- Body:
  - `status` (string, opcional)
  - `result` (string, opcional)
  - `notes` (string, opcional)
  - `start_date` (date, opcional)
  - `assigned_to` (int, opcional)
- Notas:
  - La actividad debe pertenecer al cliente.
  - Se actualiza `updated_by` con el usuario autenticado.

POST `/clients/{client}/tasks`
- Descripcion: Crea una tarea para el cliente.
- Body: campos de tarea segun `TaskService`.

GET `/clients/suggestions`
- Descripcion: Sugerencias de clientes por texto.
- Query:
  - `q` (string, requerido, min 2)
  - `limit` (int, opcional, max 20)
- Respuesta:
  - `suggestions` (array con `id`, `name`, `phone`, `document_number`)

GET `/clients/export`
- Descripcion: Exporta clientes en CSV (aplica filtros).
- Respuesta:
  - Archivo `text/csv` descargable.

---

### Proyectos

Notas:
- Auth: Requiere JWT.
- Acceso: lista completa de proyectos (no solo publicados).

GET `/projects`
- Descripcion: Lista proyectos con filtros.
- Query:
  - `per_page` (int, opcional)
  - `search` (string, opcional)
  - `project_type` (string, opcional)
  - `lote_type` (string, opcional)
  - `stage` (string, opcional)
  - `legal_status` (string, opcional)
  - `status` (string, opcional)
  - `district` (string, opcional)
  - `province` (string, opcional)
  - `region` (string, opcional)
  - `has_available_units` (bool, opcional)
  - `include` (string, opcional, ej: `advisors,reservations`)

GET `/projects/suggestions`
- Descripcion: Sugerencias de proyectos por texto.
- Query:
  - `q` (string, requerido, min 2)
  - `limit` (int, opcional)

GET `/projects/{id}`
- Descripcion: Detalle del proyecto. Incluye unidades disponibles si `include_units=true`.
- Query:
  - `include_units` (bool, opcional, default true)
  - `units_per_page` (int, opcional)
  - `include` (string, opcional, ej: `reservations`)

GET `/projects/{id}/units`
- Descripcion: Lista unidades disponibles del proyecto.
- Query:
  - `per_page` (int, opcional)

---

### Dateros

Notas:
- Auth: Requiere JWT.
- Permisos: cazador/lider/admin.

GET `/dateros`
- Descripcion: Lista dateros del cazador o lider autenticado.
- Query:
  - `per_page` (int, opcional)
  - `search` (string, opcional)
  - `is_active` (bool, opcional)

POST `/dateros`
- Descripcion: Registra un datero. El `lider_id` se toma del usuario autenticado.
- Body:
  - `name` (string, requerido)
  - `email` (string, requerido)
  - `phone` (string, requerido)
  - `dni` (string, requerido)
  - `pin` (string, requerido)
  - `ocupacion` (string, opcional)
  - `banco` (string, opcional)
  - `cuenta_bancaria` (string, opcional)
  - `cci_bancaria` (string, opcional)

GET `/dateros/{id}`
- Descripcion: Obtiene un datero especifico del cazador.

PUT/PATCH `/dateros/{id}`
- Descripcion: Actualiza un datero del cazador.
- Body: mismos campos que POST (con `sometimes`).

---

### Dashboard

GET `/dashboard/stats`
- Descripcion: Estadisticas agregadas (clientes, dateros, proyectos, reservas).
- Auth: Requiere JWT.
- Cache: 5 minutos.

---

### Reservas

Notas:
- Auth: Requiere JWT.
- Permisos: si no es admin/lider, solo reservas del propio asesor.

GET `/reservations`
- Descripcion: Lista reservas (filtradas por asesor si no es admin/lider).
- Query:
  - `per_page` (int, opcional)
  - `search` (string, opcional)
  - `status` (string, opcional)
  - `payment_status` (string, opcional)
  - `project_id` (int, opcional)
  - `client_id` (int, opcional)
  - `advisor_id` (int, opcional)
  - `include` (string, opcional)

POST `/reservations/validate`
- Descripcion: Valida payload de reserva sin persistir.
- Respuesta:
  - `valid` (bool)
  - `errors` (objeto) cuando aplica

POST `/reservations`
- Descripcion: Crea una reserva en estado `activa`.
- Body:
  - `client_id` (int, requerido)
  - `project_id` (int, requerido)
  - `unit_id` (int, requerido)
  - `reservation_amount` (numeric, requerido)
  - `payment_method` (string, opcional)
  - `payment_reference` (string, opcional)
  - `notes` (string, opcional)
  - `terms_conditions` (string, opcional)
- Notas:
  - `reservation_type` se fuerza a `pre_reserva`.
  - `payment_status` se fuerza a `pendiente`.
  - `reservation_date` es automatica.
  - `expiration_date` se fija al final del dia.
  - `reservation_percentage` se calcula con `total_price` y `reservation_amount`.
  - `advisor_id` se toma del usuario autenticado.

GET `/reservations/{id}`
- Descripcion: Obtiene una reserva especifica (solo propia si no es admin/lider).
- Query:
  - `include` (string, opcional)

PUT/PATCH `/reservations/{id}`
- Descripcion: Actualiza una reserva activa.
- Body:
  - `client_id` (int, opcional)
  - `advisor_id` (int, opcional)
  - `reservation_type` (string, opcional)
  - `reservation_date` (date, opcional)
  - `expiration_date` (date, opcional)
  - `reservation_amount` (numeric, opcional)
  - `payment_method` (string, opcional)
  - `payment_status` (string, opcional)
  - `payment_reference` (string, opcional)
  - `notes` (string, opcional)
  - `terms_conditions` (string, opcional)
- Notas:
  - `project_id` y `unit_id` no se actualizan.
  - `reservation_percentage` se recalcula automaticamente.

POST `/reservations/{id}/confirm`
- Descripcion: Confirma la reserva subiendo comprobante.
- Body (multipart/form-data):
  - `image` (file, requerido)
  - `reservation_date` (date, opcional)
  - `expiration_date` (date, opcional)
  - `reservation_amount` (numeric, opcional)
  - `payment_method` (string, opcional)
  - `payment_status` (string, opcional)
  - `payment_reference` (string, opcional)
- Notas:
  - Cambia status a `confirmada`.
  - Marca la unidad como `reservado`.
  - `reservation_percentage` se recalcula automaticamente.

POST `/reservations/{id}/cancel`
- Descripcion: Cancela una reserva activa o confirmada.
- Body:
  - `cancel_note` (string, requerido, min 10, max 500)

POST `/reservations/batch`
- Descripcion: Crea reservas en batch.
- Body:
  - `reservations` (array, requerido)
- Notas:
  - Respuesta incluye `created` y `errors` por indice.

GET `/reservations/export`
- Descripcion: Exporta reservas en CSV (aplica filtros).
- Respuesta:
  - Archivo `text/csv` descargable.

POST `/reservations/{id}/convert-to-sale`
- Descripcion: Convierte la reserva confirmada a venta.

---

### Documentos

POST `/documents/search`
- Descripcion: Busca documento en servicio externo.
- Body: segun `DocumentController::search`.
- Auth: Requiere JWT.

POST `/documents/validate-dni`
- Descripcion: Valida formato de DNI.
- Auth: Requiere JWT.

---

### Sync

GET `/sync?since=2025-01-01T00:00:00Z`
- Descripcion: Sincroniza cambios desde una fecha.
- Auth: Requiere JWT.
- Respuesta:
  - `clients`, `reservations`, `projects`, `sync_timestamp`.

---

### Reportes

GET `/reports/sales`
- Descripcion: Exporta reporte de ventas en CSV.
- Query:
  - `date_from` (date, opcional)
  - `date_to` (date, opcional)
- Auth: Requiere JWT.
- Respuesta:
  - Archivo `text/csv` descargable.

---

## Ejemplos Postman (request/response)

Notas generales:
- Base URL: `{{base_url}}/api/cazador` (o `{{base_url}}/api/v1/cazador`)
- Header: `Authorization: Bearer {{token}}`

### Auth

POST `/auth/login`
Body (JSON):
```json
{
  "email": "asesor@example.com",
  "password": "secret123"
}
```
Respuesta (JSON):
```json
{
  "message": "Inicio de sesión exitoso",
  "data": {
    "token": "jwt-token",
    "token_type": "bearer",
    "expires_in": 3600,
    "user": {
      "id": 10,
      "name": "Juan Perez",
      "email": "asesor@example.com",
      "phone": "999888777",
      "role": "cazador",
      "is_active": true
    }
  }
}
```

GET `/auth/me`
Respuesta (JSON):
```json
{
  "data": {
    "id": 10,
    "name": "Juan Perez",
    "email": "asesor@example.com",
    "phone": "999888777",
    "role": "cazador",
    "is_active": true
  }
}
```

POST `/auth/logout`
Respuesta (JSON):
```json
{
  "message": "Sesión cerrada exitosamente"
}
```

POST `/auth/refresh`
Respuesta (JSON):
```json
{
  "message": "Token renovado exitosamente",
  "data": {
    "token": "jwt-token",
    "token_type": "bearer",
    "expires_in": 3600
  }
}
```

POST `/auth/change-password`
Body (JSON):
```json
{
  "current_password": "secret123",
  "new_password": "newSecret123",
  "new_password_confirmation": "newSecret123"
}
```

### Health

GET `/health`
Respuesta (JSON):
```json
{
  "status": "healthy",
  "checks": {
    "database": { "status": "ok", "message": "Operational" },
    "cache": { "status": "ok", "message": "Operational" },
    "storage": { "status": "ok", "message": "Operational" }
  },
  "timestamp": "2026-01-23T12:00:00Z"
}
```

### Clientes

GET `/clients?search=juan&status=nuevo&include=activities,reservations`
Respuesta (JSON):
```json
{
  "data": {
    "clients": [
      {
        "id": 1,
        "name": "Juan Perez",
        "phone": "999888777",
        "document_type": "DNI",
        "document_number": "12345678",
        "client_type": "comprador",
        "status": "nuevo"
      }
    ],
    "pagination": {
      "current_page": 1,
      "per_page": 15,
      "total": 1,
      "last_page": 1,
      "from": 1,
      "to": 1,
      "links": {
        "first": "https://api.example.com/api/cazador/clients?page=1",
        "last": "https://api.example.com/api/cazador/clients?page=1",
        "prev": null,
        "next": null
      }
    }
  }
}
```

POST `/clients`
Body (JSON):
```json
{
  "create_mode": "dni",
  "name": "Maria Torres",
  "phone": "988776655",
  "document_type": "DNI",
  "document_number": "87654321",
  "address": "Av. Central 123",
  "birth_date": "1990-05-10",
  "client_type": "comprador",
  "source": "redes_sociales",
  "status": "nuevo",
  "create_type": "propio",
  "score": 60,
  "notes": "Cliente interesado en preventa."
}
```

Respuesta 422 (duplicado de telefono o DNI):
```json
{
  "success": false,
  "message": "Error de validación",
  "errors": {
    "errors": {
      "phone": ["El teléfono ya está en uso."]
    },
    "duplicate_owner": {
      "name": "Juan Perez",
      "user_id": 10,
      "client_id": 5,
      "field": "phone"
    }
  }
}
```

POST `/clients` (modo telefono)
Body (JSON):
```json
{
  "create_mode": "phone",
  "name": "Rosa Diaz",
  "phone": "912345678",
  "birth_date": "1992-10-03",
  "client_type": "comprador",
  "source": "referidos",
  "status": "nuevo",
  "score": 50
}
```

GET `/clients/{id}`
Ejemplo: `/clients/1?include=activities,reservations`

PUT `/clients/{id}`
Body (JSON):
```json
{
  "phone": "977665544",
  "status": "en_seguimiento",
  "notes": "Seguimiento programado"
}
```

POST `/clients/batch`
Body (JSON):
```json
{
  "clients": [
    {
      "create_mode": "phone",
      "name": "Nuevo Cliente",
      "phone": "912345679",
      "birth_date": "1991-08-14",
      "client_type": "comprador",
      "source": "referidos",
      "status": "nuevo",
      "score": 50
    },
    {
      "id": 1,
      "create_mode": "dni",
      "phone": "966554433",
      "status": "contacto_inicial"
    }
  ]
}
```

GET `/clients/batch?ids=1,2,3`

POST `/clients/validate`
Body (JSON):
```json
{
  "create_mode": "phone",
  "name": "Validacion Cliente",
  "phone": "912345680",
  "birth_date": "1990-01-10",
  "client_type": "comprador",
  "source": "redes_sociales",
  "status": "nuevo",
  "score": 50
}
```

GET `/clients/suggestions?q=mar&limit=5`

GET `/clients/export`

#### Actividades del cliente

> Base: `Activity` (migración `2024_01_01_000007_create_activities_table.php`).
> Este recurso siempre está ligado a un `client_id` vía la ruta.
> Permiso: solo el asesor asignado al cliente o quien lo creó puede acceder/modificar.

GET `/clients/{client}/activities`

Query params:
- `per_page` (int, opcional, default 15, max 100)
- `status` (string, opcional): `programada|en_progreso|completada|cancelada`
- `activity_type` (string, opcional): `llamada|reunion|visita|seguimiento|tarea`
- `priority` (string, opcional): `baja|media|alta|urgente`
- `start_date_from` (date, opcional, formato `YYYY-MM-DD`)
- `start_date_to` (date, opcional, formato `YYYY-MM-DD`)
- `search` (string, opcional): busca en `title`, `description`, `notes`

Respuesta 200 (JSON):
```json
{
  "success": true,
  "message": "Actividades obtenidas exitosamente",
  "data": {
    "activities": [
      {
        "id": 10,
        "title": "Llamada inicial",
        "description": null,
        "activity_type": "llamada",
        "status": "programada",
        "priority": "media",
        "start_date": "2026-01-23 10:00:00",
        "duration": 30,
        "location": "Oficina",
        "client_id": 5,
        "project_id": null,
        "unit_id": null,
        "opportunity_id": null,
        "advisor_id": 8,
        "assigned_to": 12,
        "reminder_before": 15,
        "reminder_sent": false,
        "notes": "Confirmar interés.",
        "result": null,
        "created_by": 8,
        "updated_by": 8,
        "created_at": "2026-01-23 09:45:00",
        "updated_at": "2026-01-23 09:45:00",
        "advisor": { "id": 8, "name": "Ana Pérez", "email": "ana.perez@crm.com" },
        "assigned_to": { "id": 12, "name": "Luis Ramos", "email": "luis.ramos@crm.com" }
      }
    ],
    "pagination": {
      "current_page": 1,
      "per_page": 15,
      "total": 40,
      "last_page": 3,
      "from": 1,
      "to": 15,
      "links": {
        "first": "https://api.tuapp.com/api/v1/cazador/clients/5/activities?page=1",
        "last": "https://api.tuapp.com/api/v1/cazador/clients/5/activities?page=3",
        "prev": null,
        "next": "https://api.tuapp.com/api/v1/cazador/clients/5/activities?page=2"
      }
    }
  }
}
```

POST `/clients/{client}/activities`

Body (JSON) - campos según migración:
Campos requeridos:
- `title` (string)
- `activity_type` (string): `llamada|reunion|visita|seguimiento|tarea`
- `start_date` (datetime)

Campos opcionales:
- `description` (string)
- `status` (string): `programada|en_progreso|completada|cancelada` (default: `programada`)
- `priority` (string): `baja|media|alta|urgente` (default: `media`)
- `duration` (int, minutos)
- `location` (string)
- `project_id` (int, exists: `projects`)
- `unit_id` (int, exists: `units`)
- `opportunity_id` (int, exists: `opportunities`)
- `advisor_id` (int, exists: `users`)
- `assigned_to` (int, exists: `users`)
- `reminder_before` (int, minutos)
- `reminder_sent` (bool, default: `false`)
- `notes` (string)
- `result` (string)

Notas:
- `client_id` se toma de la ruta.
- `created_by` y `updated_by` se asignan al usuario autenticado.

Body ejemplo:
```json
{
  "title": "Llamada inicial",
  "activity_type": "llamada",
  "start_date": "2026-01-23 10:00:00",
  "status": "programada",
  "priority": "media",
  "duration": 30,
  "location": "Oficina",
  "assigned_to": 12,
  "notes": "Confirmar interés."
}
```

Respuesta 201 (JSON):
```json
{
  "success": true,
  "message": "Actividad creada correctamente",
  "data": {
    "activity": { "...": "..." }
  }
}
```

PUT/PATCH `/clients/{client}/activities/{activity}`

Campos permitidos para actualizar:
- `status` (string): `programada|en_progreso|completada|cancelada`
- `result` (string, nullable)
- `notes` (string, nullable)
- `start_date` (datetime, nullable)
- `assigned_to` (int, exists: `users`)

Body ejemplo:
```json
{
  "status": "completada",
  "result": "Cliente interesado",
  "notes": "Se agenda visita",
  "start_date": "2026-01-24 10:30:00",
  "assigned_to": 12
}
```

Respuesta 200 (JSON):
```json
{
  "success": true,
  "message": "Actividad actualizada correctamente",
  "data": {
    "activity": { "...": "..." }
  }
}
```

POST `/clients/{client}/tasks`
Body (JSON):
```json
{
  "title": "Enviar brochure",
  "task_type": "documento",
  "status": "pendiente",
  "priority": "media",
  "due_date": "2026-01-25",
  "notes": "PDF del proyecto."
}
```

### Proyectos

GET `/projects?search=sol&stage=venta_activa`

GET `/projects/suggestions?q=sol&limit=5`

GET `/projects/{id}?include_units=true&units_per_page=10`

GET `/projects/{id}/units?per_page=10`

### Dateros

GET `/dateros?search=ana&is_active=true`

POST `/dateros`
Body (JSON):
```json
{
  "name": "Ana Datero",
  "email": "ana.datero@example.com",
  "phone": "955443322",
  "dni": "44556677",
  "pin": "123456",
  "ocupacion": "Independiente"
}
```

GET `/dateros/{id}`

PATCH `/dateros/{id}`
Body (JSON):
```json
{
  "phone": "944332211",
  "is_active": true
}
```

### Dashboard

GET `/dashboard/stats`

### Reservas

GET `/reservations?status=activa&payment_status=pendiente`

POST `/reservations`
Body (JSON):
```json
{
  "client_id": 1,
  "project_id": 2,
  "unit_id": 5,
  "reservation_amount": 5000,
  "payment_method": "transferencia",
  "payment_reference": "TRX123",
  "notes": "Reserva inicial"
}
```

POST `/reservations/validate`
Body (JSON):
```json
{
  "client_id": 1,
  "project_id": 2,
  "unit_id": 5,
  "reservation_amount": 5000
}
```

GET `/reservations/{id}`

PATCH `/reservations/{id}`
Body (JSON):
```json
{
  "reservation_amount": 6000,
  "payment_status": "parcial",
  "notes": "Se ajusto el monto"
}
```

POST `/reservations/{id}/confirm`
Body (multipart/form-data):
- `image`: archivo de imagen
- `reservation_amount`: `6000`
- `payment_status`: `pagado`

POST `/reservations/{id}/cancel`
Body (JSON):
```json
{
  "cancel_note": "Cliente solicito cancelacion"
}
```

POST `/reservations/batch`
Body (JSON):
```json
{
  "reservations": [
    {
      "client_id": 1,
      "project_id": 2,
      "unit_id": 5,
      "reservation_amount": 3000
    },
    {
      "client_id": 2,
      "project_id": 2,
      "unit_id": 6,
      "reservation_amount": 3500
    }
  ]
}
```

GET `/reservations/export`

POST `/reservations/{id}/convert-to-sale`

### Documentos

POST `/documents/search`
Body (JSON):
```json
{
  "document_type": "dni",
  "document_number": "12345678"
}
```

POST `/documents/validate-dni`
Body (JSON):
```json
{
  "dni": "12345678"
}
```

### Sync

GET `/sync?since=2026-01-01T00:00:00Z`

### Reportes

GET `/reports/sales?date_from=2026-01-01&date_to=2026-01-31`
