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

GET `/clients/suggestions`
- Descripcion: Sugerencias de clientes por texto.
- Query:
  - `q` (string, requerido, min 2)
  - `limit` (int, opcional)

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

POST `/clients/validate`
- Descripcion: Valida payload de cliente sin persistir.
- Respuesta:
  - `valid` (bool)
  - `errors` (objeto) cuando aplica

POST `/clients`
- Descripcion: Crea un cliente y lo asigna al cazador autenticado.
- Body:
  - `name` (string, requerido)
  - `phone` (string, opcional)
  - `document_type` (string, opcional)
  - `document_number` (string, opcional)
  - `address` (string, opcional)
  - `birth_date` (date, opcional)
  - `client_type` (string, requerido)
  - `source` (string, requerido)
  - `status` (string, opcional, default `nuevo`)
  - `create_type` (string, opcional)
  - `score` (int, opcional, default 0)
  - `notes` (string, opcional)
- Notas:
  - `assigned_advisor_id` se asigna al usuario autenticado.
  - Se aplican sanitizaciones basicas (telefono, documento, notas).

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
- Body: mismos campos que POST.
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
