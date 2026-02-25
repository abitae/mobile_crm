# API Cazador – Documentación de endpoints

Documento único de referencia para la API de la aplicación Cazador (vendedores/asesores).

---

## Información general

| Concepto | Valor |
|----------|--------|
| **Base URL** | `{{base_url}}/api/cazador` o `{{base_url}}/api/v1/cazador` |
| **Autenticación** | JWT en header `Authorization: Bearer <token>` |
| **Middleware** | Rutas protegidas usan `auth:api` y middleware `cazador` |
| **Paginación** | Listas incluyen `pagination` con `current_page`, `per_page`, `total`, `last_page`, `from`, `to`, `links` (`first`, `last`, `prev`, `next`) |

**Formato de respuesta:**
- Éxito: `{ "success": true, "message": "...", "data": { ... } }`
- Error: `{ "success": false, "message": "...", "errors": { ... } }` (validación: código 422)

**Health check (fuera de Cazador):** `GET /api/health` — público; retorna `status`, `checks` (database, cache, storage).

---

## 1. Auth

| Método | Ruta | Descripción | Auth |
|--------|------|-------------|------|
| POST | `/auth/login` | Inicia sesión (email + PIN 6 dígitos) | Público (throttle 5/min) |
| GET | `/auth/me` | Usuario autenticado | JWT |
| POST | `/auth/logout` | Invalida token | JWT |
| POST | `/auth/refresh` | Renueva token | JWT |
| POST | `/auth/change-password` | Cambia contraseña | JWT |

**POST `/auth/login`**  
- Body: `email` (string, requerido), `password` (string, requerido; en la app es PIN de 6 dígitos).  
- Respuesta (data): `token`, `token_type`, `expires_in`, `user` (`id`, `name`, `email`, `phone`, `role`, `is_active`).

**POST `/auth/change-password`**  
- Body: `current_password`, `new_password`, `new_password_confirmation` (string, requerido; new_password min 6, confirmed).

---

## 2. Clientes

Todas las rutas de clientes requieren JWT. Solo se accede a clientes asignados o creados por el cazador.

| Método | Ruta | Descripción |
|--------|------|-------------|
| GET | `/clients` | Lista clientes (paginada, filtros, include) |
| GET | `/clients/suggestions` | Sugerencias por texto (`q`, `limit`) |
| GET | `/clients/options` | Opciones para formularios (tipos, estados, fuentes) |
| GET | `/clients/batch` | Múltiples clientes por `ids` |
| POST | `/clients/validate` | Valida payload sin guardar |
| POST | `/clients` | Crea cliente (asignado al cazador) |
| POST | `/clients/batch` | Crea/actualiza en batch |
| GET | `/clients/{id}` | Detalle de un cliente |
| PUT/PATCH | `/clients/{id}` | Actualiza cliente |
| GET | `/clients/{client}/activities` | Lista actividades del cliente |
| POST | `/clients/{client}/activities` | Crea actividad |
| PUT/PATCH | `/clients/{client}/activities/{activity}` | Actualiza actividad |
| GET | `/clients/export` | Exporta clientes CSV |

**GET `/clients`**  
- Query: `per_page`, `search`, `status`, `type`, `source`, `create_type`, `include` (ej. `activities,reservations`).  
- Respuesta: `clients` (array), `pagination`. Búsqueda sobre `name`, `document_number`, `phone`.

**GET `/clients/suggestions`**  
- Query: `q` (requerido, min 2), `limit` (opcional, max 20).  
- Respuesta: `suggestions` con `id`, `name`, `phone`, `document_number`.

**POST `/clients`**  
- Body: `create_mode` (requerido: `dni`|`phone`), `name`, `phone` (9 dígitos, empieza en 9, único), `document_type`/`document_number` (requeridos si `create_mode=dni`), `address`, `birth_date`, `client_type`, `source`, `status`, `create_type`, `score` (0-100), `notes`, `city_id` (requerido, exists:cities).  
- Si `create_mode=phone`, DNI opcional. Si teléfono o DNI ya existe, se devuelve info `duplicate_owner`.

**POST `/clients/batch`**  
- Body: `clients` (array). Si un item tiene `id` se interpreta como actualización. Respuesta: `created`, `updated`, `errors` por índice.

**GET `/clients/{id}`**  
- Query: `include` (opcional). Respuesta: `client` (incluye contadores como `opportunities_count`, `activities_count`, `tasks_count` si aplica).

**Actividades:**  
- GET actividades: query `per_page`, `status`, `activity_type`, `priority`, `start_date_from`, `start_date_to`, `search`.  
- POST actividad: body según ActivityService (ej. `title`, `activity_type`, `start_date`).  
- PUT/PATCH actividad: `status`, `result`, `notes`, `start_date`, `assigned_to`.

---

## 3. Ciudades

| Método | Ruta | Descripción | Auth |
|--------|------|-------------|------|
| GET | `/cities` | Lista ciudades (paginada, búsqueda) | JWT |

**GET `/cities`**  
- Query: `search` (string, opcional), `per_page` (int, opcional, max 500; por defecto 100).  
- Respuesta: `cities` (array de `{ "id", "name" }`), `pagination`.  
- Orden: por nombre. Cache recomendado: 300 s.

---

## 4. Proyectos

Todas requieren JWT. Acceso a lista completa de proyectos (no solo publicados).

| Método | Ruta | Descripción |
|--------|------|-------------|
| GET | `/projects` | Lista proyectos (filtros, include) |
| GET | `/projects/suggestions` | Sugerencias por texto (`q`, `limit`) |
| GET | `/projects/{id}` | Detalle (opcional `include_units`, `units_per_page`, `include`) |
| GET | `/projects/{id}/units` | Unidades del proyecto |

**GET `/projects`**  
- Query: `per_page`, `search`, `project_type`, `lote_type`, `stage`, `legal_status`, `status`, `district`, `province`, `region`, `has_available_units`, `include`.

---

## 5. Dateros

Requieren JWT; permisos cazador/líder/admin.

| Método | Ruta | Descripción |
|--------|------|-------------|
| GET | `/dateros` | Lista dateros (`per_page`, `search`, `is_active`) |
| POST | `/dateros` | Registra datero (`lider_id` = usuario autenticado) |
| GET | `/dateros/{id}` | Detalle de un datero |
| PUT/PATCH | `/dateros/{id}` | Actualiza datero |

**POST `/dateros`**  
- Body: `name`, `email`, `phone`, `dni`, `pin` (requeridos); `ocupacion`, `banco`, `cuenta_bancaria`, `cci_bancaria` (opcionales).

---

## 6. Dashboard

| Método | Ruta | Descripción | Auth |
|--------|------|-------------|------|
| GET | `/dashboard/stats` | Estadísticas (clientes, dateros, proyectos, reservas) | JWT |

Cache típico: 60 s.

---

## 7. Reservas

Requieren JWT. Si no es admin/líder, solo reservas del asesor autenticado.

| Método | Ruta | Descripción |
|--------|------|-------------|
| GET | `/reservations` | Lista reservas (filtros) |
| POST | `/reservations/validate` | Valida payload sin guardar |
| GET | `/reservations/export` | Exporta CSV |
| POST | `/reservations` | Crea reserva (estado `activa`) |
| POST | `/reservations/batch` | Crea en batch |
| GET | `/reservations/{id}` | Detalle |
| PUT/PATCH | `/reservations/{id}` | Actualiza reserva activa |
| POST | `/reservations/{id}/confirm` | Confirma (sube comprobante, multipart) |
| POST | `/reservations/{id}/cancel` | Cancela (body: `cancel_note`) |
| POST | `/reservations/{id}/convert-to-sale` | Convierte a venta |

**POST `/reservations`**  
- Body: `client_id`, `project_id`, `unit_id`, `reservation_amount` (requeridos); `payment_method`, `payment_reference`, `notes`, `terms_conditions` (opcionales).  
- Se asigna `advisor_id`, `reservation_type=pre_reserva`, `payment_status=pendiente`; fechas y porcentaje se calculan.

**POST `/reservations/{id}/confirm`**  
- Multipart: `image` (file requerido); opcionales: `reservation_date`, `expiration_date`, `reservation_amount`, `payment_method`, `payment_status`, `payment_reference`.

**POST `/reservations/{id}/cancel`**  
- Body: `cancel_note` (string, min 10, max 500).

---

## 8. Documentos

| Método | Ruta | Descripción | Auth |
|--------|------|-------------|------|
| POST | `/documents/validate-dni` | Valida formato DNI | JWT |
| POST | `/documents/search` | Búsqueda en servicio externo | JWT |

Throttle: 30 req/min.

---

## 9. Sync

| Método | Ruta | Descripción | Auth |
|--------|------|-------------|------|
| GET | `/sync` | Sincroniza cambios desde una fecha | JWT |

Query: `since` (ej. `2026-01-01T00:00:00Z`). Respuesta: `clients`, `reservations`, `projects`, `sync_timestamp`. Throttle: 30 req/min.

---

## 10. Reportes

| Método | Ruta | Descripción | Auth |
|--------|------|-------------|------|
| GET | `/reports/sales` | Reporte de ventas en CSV | JWT |

Query: `date_from`, `date_to` (opcionales). Throttle: 30 req/min.

---

## Resumen de rutas (índice)

```
POST   /auth/login
GET    /auth/me
POST   /auth/logout
POST   /auth/refresh
POST   /auth/change-password

GET    /clients
GET    /clients/suggestions
GET    /clients/options
GET    /clients/batch
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
GET    /clients/export

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
POST   /reservations/validate
GET    /reservations/export
POST   /reservations
POST   /reservations/batch
GET    /reservations/{id}
PUT    /reservations/{id}
PATCH  /reservations/{id}
POST   /reservations/{id}/confirm
POST   /reservations/{id}/cancel
POST   /reservations/{id}/convert-to-sale

POST   /documents/validate-dni
POST   /documents/search

GET    /sync

GET    /reports/sales
```

Todas las rutas anteriores son relativas a la base URL de la API Cazador (`/api/cazador` o `/api/v1/cazador`).  
Health: `GET /api/health` (no lleva prefijo cazador).
