# Documentación API REST - CRM Inmobiliario

## 📋 Índice

1. [Introducción](#introducción)
2. [Configuración Base](#configuración-base)
3. [Autenticación](#autenticación)
4. [Aplicación Datero](#aplicación-datero)
5. [Aplicación Cazador](#aplicación-cazador)
6. [Rutas Públicas](#rutas-públicas)
7. [Modelos de Datos](#modelos-de-datos)
8. [Manejo de Errores](#manejo-de-errores)
9. [Rate Limiting](#rate-limiting)
10. [Ejemplos de Integración](#ejemplos-de-integración)

---

## 🎯 Introducción

Esta API REST está diseñada para dos aplicaciones móviles:

- **Aplicación Datero**: Para usuarios con rol "datero" que captan clientes y gestionan sus comisiones
- **Aplicación Cazador**: Para usuarios con rol "vendedor" (asesores) que gestionan clientes y proyectos completos

Ambas aplicaciones utilizan autenticación JWT (JSON Web Tokens) para acceder a los recursos protegidos.

---

## ⚙️ Configuración Base

### Base URL

```
Producción: https://lotesenremate.pe/api
Desarrollo: http://crm_inmobiliaria.test/api
```

### Headers Comunes

Todas las peticiones requieren:

```
Content-Type: application/json
Accept: application/json
```

Para peticiones autenticadas, agregar:

```
Authorization: Bearer {token}
```

### Formato de Respuesta Estándar

**Éxito:**
```json
{
    "success": true,
    "message": "Mensaje descriptivo",
    "data": { /* datos de la respuesta */ }
}
```

**Error:**
```json
{
    "success": false,
    "message": "Mensaje de error",
    "errors": { /* detalles de errores (opcional) */ }
}
```

### Códigos HTTP

- `200` - Éxito
- `201` - Creado exitosamente
- `400` - Solicitud incorrecta
- `401` - No autenticado
- `403` - Acceso denegado
- `404` - Recurso no encontrado
- `422` - Error de validación
- `500` - Error del servidor

---

## 🔐 Autenticación

### Aplicación Datero

#### Login

**Endpoint:** `POST /api/datero/auth/login`

**Rate Limit:** 5 solicitudes por minuto

**Request:**
```json
{
    "email": "datero@example.com",
    "password": "password123"
}
```

**Notas de Validación:**
- El email se normaliza automáticamente (convierte a minúsculas y elimina espacios)
- Se registran todos los intentos de login en los logs del sistema
- Los intentos fallidos se registran con información de IP para seguridad

**Response 200 (Success):**
```json
{
    "success": true,
    "message": "Inicio de sesión exitoso",
    "data": {
        "token": "eyJ0eXAiOiJKV1QiLCJhbGc...",
        "token_type": "bearer",
        "expires_in": 3600,
        "user": {
            "id": 1,
            "name": "Juan Pérez",
            "email": "datero@example.com",
            "phone": "+51987654321",
            "role": "datero",
            "is_active": true
        }
    }
}
```

**Response 401 (Error):**
```json
{
    "success": false,
    "message": "Credenciales inválidas"
}
```

#### Obtener Usuario Autenticado

**Endpoint:** `GET /api/datero/auth/me`

**Headers:**
```
Authorization: Bearer {token}
```

**Response 200:**
```json
{
    "success": true,
    "message": "Operación exitosa",
    "data": {
        "id": 1,
        "name": "Juan Pérez",
        "email": "datero@example.com",
        "phone": "+51987654321",
        "role": "datero",
        "is_active": true
    }
}
```

#### Refrescar Token

**Endpoint:** `POST /api/datero/auth/refresh`

**Headers:**
```
Authorization: Bearer {token}
```

**Response 200:**
```json
{
    "success": true,
    "message": "Token renovado exitosamente",
    "data": {
        "token": "nuevo_token_jwt...",
        "token_type": "bearer",
        "expires_in": 3600
    }
}
```

#### Logout

**Endpoint:** `POST /api/datero/auth/logout`

**Headers:**
```
Authorization: Bearer {token}
```

**Response 200:**
```json
{
    "success": true,
    "message": "Sesión cerrada exitosamente",
    "data": null
}
```

### Aplicación Cazador

Los endpoints de autenticación para Cazador son idénticos pero con el prefijo `/api/cazador/auth/`:

- `POST /api/cazador/auth/login`
- `GET /api/cazador/auth/me`
- `POST /api/cazador/auth/refresh`
- `POST /api/cazador/auth/logout`

**Nota:** Solo usuarios con rol "vendedor" pueden autenticarse en la aplicación Cazador.

---

## 📱 Aplicación Datero

### Clientes

#### Listar Clientes

**Endpoint:** `GET /api/datero/clients`

**Headers:**
```
Authorization: Bearer {token}
```

**Query Parameters:**
- `per_page` (opcional): Número de resultados por página (máx. 100, default: 15, mínimo: 1)
- `page` (opcional): Número de página (mínimo: 1)
- `search` (opcional): Búsqueda por nombre, teléfono o documento (se sanitiza automáticamente para prevenir inyección SQL)
- `status` (opcional): Filtrar por estado (`nuevo`, `contacto_inicial`, `en_seguimiento`, `cierre`, `perdido`)
- `type` (opcional): Filtrar por tipo (`inversor`, `comprador`, `empresa`, `constructor`)
- `source` (opcional): Filtrar por origen (`redes_sociales`, `ferias`, `referidos`, `formulario_web`, `publicidad`)

**Notas:**
- Los parámetros de paginación se validan automáticamente
- La búsqueda se sanitiza para prevenir inyección SQL
- Se registran errores en los logs del sistema para debugging

**Response 200:**
```json
{
    "success": true,
    "message": "Clientes obtenidos exitosamente",
    "data": {
        "clients": [
            {
                "id": 1,
                "name": "María González",
                "phone": "+51987654321",
                "document_type": "DNI",
                "document_number": "12345678",
                "address": "Av. Principal 123",
                "birth_date": "1990-05-15",
                "client_type": "comprador",
                "source": "redes_sociales",
                "status": "nuevo",
                "score": 75,
                "notes": "Cliente interesado en lotes",
                "assigned_advisor": {
                    "id": 2,
                    "name": "Carlos Vendedor",
                    "email": "carlos@example.com"
                },
                "created_at": "2025-11-24 10:30:00",
                "updated_at": "2025-11-24 10:30:00"
            }
        ],
        "pagination": {
            "current_page": 1,
            "per_page": 15,
            "total": 50,
            "last_page": 4,
            "from": 1,
            "to": 15
        }
    }
}
```

#### Crear Cliente

**Endpoint:** `POST /api/datero/clients`

**Headers:**
```
Authorization: Bearer {token}
```

**Request:**
```json
{
    "name": "María González",
    "phone": "+51987654321",
    "document_type": "DNI",
    "document_number": "12345678",
    "address": "Av. Principal 123",
    "birth_date": "1990-05-15",
    "client_type": "comprador",
    "source": "redes_sociales",
    "status": "nuevo",
    "score": 75,
    "notes": "Cliente interesado en lotes",
    "assigned_advisor_id": 2
}
```

**Campos Requeridos:**
- `name`: Nombre completo (se eliminan espacios al inicio y final automáticamente)
- `document_type`: Tipo de documento (`DNI`, `RUC`, `CE`, `PASAPORTE`)
- `document_number`: Número de documento (único, solo dígitos, se sanitiza automáticamente)
- `birth_date`: Fecha de nacimiento (formato: `YYYY-MM-DD`) - **OBLIGATORIO**
- `client_type`: Tipo de cliente (`inversor`, `comprador`, `empresa`, `constructor`)
- `source`: Origen (`redes_sociales`, `ferias`, `referidos`, `formulario_web`, `publicidad`)
- `status`: Estado (`nuevo`, `contacto_inicial`, `en_seguimiento`, `cierre`, `perdido`)
- `score`: Puntuación (0-100, se valida y limita automáticamente)

**Sanitización Automática:**
- `name`: Se eliminan espacios al inicio y final
- `phone`: Se sanitiza para permitir solo números, guiones, paréntesis y espacios
- `document_number`: Se eliminan todos los caracteres no numéricos
- `address`: Se eliminan espacios al inicio y final
- `notes`: Se eliminan espacios al inicio y final
- `score`: Se valida que esté entre 0 y 100, se convierte a entero

**Response 201:**
```json
{
    "success": true,
    "message": "Cliente creado exitosamente",
    "data": {
        "client": {
            "id": 1,
            "name": "María González",
            ...
        }
    }
}
```

#### Ver Cliente Específico

**Endpoint:** `GET /api/datero/clients/{id}`

**Response 200:**
```json
{
    "success": true,
    "message": "Cliente obtenido exitosamente",
    "data": {
        "client": {
            "id": 1,
            "name": "María González",
            ...
            "opportunities_count": 2,
            "activities_count": 5,
            "tasks_count": 1
        }
    }
}
```

#### Actualizar Cliente

**Endpoint:** `PUT /api/datero/clients/{id}` o `PATCH /api/datero/clients/{id}`

**Request:** (solo enviar campos a actualizar)
```json
{
    "status": "en_seguimiento",
    "score": 85,
    "notes": "Cliente muy interesado, seguimiento activo"
}
```

**Response 200:**
```json
{
    "success": true,
    "message": "Cliente actualizado exitosamente",
    "data": {
        "client": { ... }
    }
}
```

#### Opciones para Formularios

**Endpoint:** `GET /api/datero/clients/options`

**Response 200:**
```json
{
    "success": true,
    "message": "Opciones obtenidas exitosamente",
    "data": {
        "document_types": {
            "DNI": "DNI",
            "RUC": "RUC",
            "CE": "Carné de Extranjería",
            "PASAPORTE": "Pasaporte"
        },
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

### Comisiones

#### Listar Comisiones

**Endpoint:** `GET /api/datero/commissions`

**Query Parameters:**
- `per_page` (opcional): Número de resultados por página
- `status` (opcional): Filtrar por estado (`pendiente`, `aprobada`, `pagada`, `cancelada`)
- `commission_type` (opcional): Filtrar por tipo (`venta`, `reserva`, `seguimiento`, `bono`)
- `start_date` (opcional): Fecha inicio (formato: YYYY-MM-DD)
- `end_date` (opcional): Fecha fin (formato: YYYY-MM-DD)

**Response 200:**
```json
{
    "success": true,
    "message": "Comisiones obtenidas exitosamente",
    "data": {
        "commissions": [
            {
                "id": 1,
                "project": {
                    "id": 1,
                    "name": "Proyecto Los Olivos"
                },
                "unit": {
                    "id": 5,
                    "unit_number": "Lote-001"
                },
                "opportunity": {
                    "id": 3,
                    "client_name": "María González"
                },
                "commission_type": "seguimiento",
                "base_amount": 50000.00,
                "commission_percentage": 2.50,
                "commission_amount": 1250.00,
                "bonus_amount": 500.00,
                "total_commission": 1750.00,
                "status": "pagada",
                "payment_date": "2025-11-20",
                "payment_method": "transferencia",
                "payment_reference": "COM-DAT-001-123",
                "notes": "Comisión por seguimiento y captación de cliente",
                "approved_at": "2025-11-15 10:00:00",
                "paid_at": "2025-11-20 14:30:00",
                "created_at": "2025-11-10 09:00:00",
                "updated_at": "2025-11-20 14:30:00"
            }
        ],
        "pagination": { ... }
    }
}
```

#### Ver Comisión Específica

**Endpoint:** `GET /api/datero/commissions/{id}`

**Response 200:**
```json
{
    "success": true,
    "message": "Comisión obtenida exitosamente",
    "data": {
        "commission": { ... }
    }
}
```

#### Estadísticas de Comisiones

**Endpoint:** `GET /api/datero/commissions/stats`

**Response 200:**
```json
{
    "success": true,
    "message": "Estadísticas obtenidas exitosamente",
    "data": {
        "stats": {
            "total": 25,
            "pendiente": 5,
            "aprobada": 8,
            "pagada": 10,
            "cancelada": 2,
            "total_pagado": 15000.00,
            "total_pendiente": 5000.00,
            "total_mes_actual": 8000.00,
            "total_anio_actual": 20000.00
        }
    }
}
```

### Perfil

#### Ver Perfil

**Endpoint:** `GET /api/datero/profile`

**Response 200:**
```json
{
    "success": true,
    "message": "Perfil obtenido exitosamente",
    "data": {
        "id": 1,
        "name": "Juan Pérez",
        "email": "datero@example.com",
        "phone": "+51987654321",
        "role": "datero",
        "is_active": true,
        "banco": "Banco de Crédito",
        "cuenta_bancaria": "1234567890",
        "cci_bancaria": "12345678901234567890"
    }
}
```

#### Actualizar Perfil

**Endpoint:** `PUT /api/datero/profile` o `PATCH /api/datero/profile`

**Request:**
```json
{
    "name": "Juan Pérez Actualizado",
    "phone": "+51999999999",
    "banco": "Banco de la Nación",
    "cuenta_bancaria": "9876543210",
    "cci_bancaria": "98765432109876543210"
}
```

**Response 200:**
```json
{
    "success": true,
    "message": "Perfil actualizado exitosamente",
    "data": { ... }
}
```

#### Cambiar Contraseña

**Endpoint:** `POST /api/datero/profile/change-password`

**Request:**
```json
{
    "current_password": "password123",
    "new_password": "nuevapassword456",
    "new_password_confirmation": "nuevapassword456"
}
```

**Response 200:**
```json
{
    "success": true,
    "message": "Contraseña actualizada exitosamente",
    "data": null
}
```

### Búsqueda de Documentos

#### Buscar Datos por DNI/RUC

**Endpoint:** `POST /api/datero/documents/search`

**Rate Limit:** 30 solicitudes por minuto

**Headers:**
```
Authorization: Bearer {token}
```

**Request:**
```json
{
    "document_type": "dni",
    "document_number": "12345678"
}
```

**Parámetros:**
- `document_type` (requerido): Tipo de documento (`dni` o `ruc`)
- `document_number` (requerido): Número de documento
  - DNI: debe tener exactamente 8 dígitos (solo números)
  - RUC: debe tener exactamente 11 dígitos (solo números)
  - **Nota:** El sistema sanitiza automáticamente el número, eliminando cualquier carácter no numérico

**Response 200 (Éxito):**
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

**Response 404 (No encontrado):**
```json
{
    "success": false,
    "message": "No se encontró información para el documento proporcionado"
}
```

**Response 422 (Error de validación):**
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

**Notas:**
- Este servicio consulta datos externos de la API de Facturalahoy
- Los datos retornados incluyen información completa de la persona o empresa
- Si se encuentra información de ubigeo, se incluye en la respuesta
- El servicio valida y sanitiza el formato del documento antes de realizar la búsqueda
- Se eliminan automáticamente todos los caracteres no numéricos del número de documento
- Se registran todas las búsquedas en los logs del sistema para auditoría

---

## 🎯 Aplicación Cazador

### Clientes

Los endpoints de clientes para Cazador son similares a Datero pero con el prefijo `/api/cazador/clients/`:

- `GET /api/cazador/clients` - Listar clientes (asignados o creados por el cazador)
- `POST /api/cazador/clients` - Crear cliente
- `GET /api/cazador/clients/{id}` - Ver cliente
- `PUT/PATCH /api/cazador/clients/{id}` - Actualizar cliente
- `GET /api/cazador/clients/options` - Opciones de formulario

**Diferencia:** Los cazadores pueden ver clientes asignados a ellos (`assigned_advisor_id`) o creados por ellos (`created_by`).

**Nota Importante:** Al crear un cliente desde la aplicación Cazador, el campo `assigned_advisor_id` se asigna automáticamente al usuario autenticado. No es necesario enviarlo en el request y cualquier valor enviado será ignorado.

#### Crear Cliente

**Endpoint:** `POST /api/cazador/clients`

**Headers:**
```
Authorization: Bearer {token}
```

**Request:**
```json
{
    "name": "Cliente Nuevo",
    "phone": "+51987654321",
    "document_type": "DNI",
    "document_number": "87654321",
    "address": "Av. Principal 456",
    "birth_date": "1985-03-20",
    "client_type": "comprador",
    "source": "referidos",
    "status": "nuevo",
    "score": 80,
    "notes": "Cliente interesado en departamentos"
}
```

**Nota:** El campo `assigned_advisor_id` NO debe enviarse. Se asigna automáticamente al cazador autenticado.

**Campos Requeridos:**
- `name`: Nombre completo
- `document_type`: Tipo de documento (`DNI`, `RUC`, `CE`, `PASAPORTE`)
- `document_number`: Número de documento (único)
- `birth_date`: Fecha de nacimiento (formato: `YYYY-MM-DD`)
- `client_type`: Tipo de cliente (`inversor`, `comprador`, `empresa`, `constructor`)
- `source`: Origen (`redes_sociales`, `ferias`, `referidos`, `formulario_web`, `publicidad`)
- `status`: Estado (`nuevo`, `contacto_inicial`, `en_seguimiento`, `cierre`, `perdido`)
- `score`: Puntuación (0-100)

**Response 201:**
```json
{
    "success": true,
    "message": "Cliente creado exitosamente",
    "data": {
        "client": {
            "id": 1,
            "name": "Cliente Nuevo",
            ...
            "assigned_advisor": {
                "id": 2,
                "name": "Carlos Vendedor",
                "email": "cazador@example.com"
            }
        }
    }
}
```

### Proyectos

#### Listar Proyectos Completos

**Endpoint:** `GET /api/cazador/projects`

**Query Parameters:**
- `per_page` (opcional): Número de resultados por página
- `search` (opcional): Búsqueda por nombre, descripción o dirección
- `project_type` (opcional): Tipo de proyecto (`lotes`, `casas`, `departamentos`, `oficinas`, `mixto`)
- `lote_type` (opcional): Tipo de lote (`normal`, `express`)
- `stage` (opcional): Etapa (`preventa`, `lanzamiento`, `venta_activa`, `cierre`)
- `legal_status` (opcional): Estado legal (`con_titulo`, `en_tramite`, `habilitado`)
- `status` (opcional): Estado (`activo`, `inactivo`, `suspendido`, `finalizado`)
- `district`, `province`, `region` (opcional): Filtros de ubicación
- `has_available_units` (opcional): Solo proyectos con unidades disponibles (true/false)

**Response 200:**
```json
{
    "success": true,
    "message": "Proyectos obtenidos exitosamente",
    "data": {
        "projects": [
            {
                "id": 1,
                "name": "Proyecto Los Olivos",
                "description": "Proyecto de lotes residenciales",
                "project_type": "lotes",
                "is_published": true,
                "lote_type": "normal",
                "stage": "venta_activa",
                "legal_status": "con_titulo",
                "estado_legal": "Titulo de propiedad",
                "tipo_proyecto": "propio",
                "tipo_financiamiento": "financiado",
                "banco": "Banco de Crédito",
                "tipo_cuenta": "cuenta corriente",
                "cuenta_bancaria": "1234567890",
                "address": "Av. Los Olivos 123",
                "district": "Los Olivos",
                "province": "Lima",
                "region": "Lima",
                "country": "Perú",
                "ubicacion": "https://maps.google.com/?q=-11.9694,-77.0739",
                "full_address": "Av. Los Olivos 123, Los Olivos, Lima, Lima, Perú",
                "coordinates": {
                    "lat": -11.9694,
                    "lng": -77.0739
                },
                "total_units": 100,
                "available_units": 45,
                "reserved_units": 20,
                "sold_units": 30,
                "blocked_units": 5,
                "progress_percentage": 50.00,
                "start_date": "2025-01-01",
                "end_date": "2025-12-31",
                "delivery_date": "2026-06-30",
                "status": "activo",
                "path_image_portada": "/storage/projects/portadas/1.jpg",
                "path_video_portada": null,
                "path_images": [
                    {
                        "title": "Vista aérea",
                        "path": "/storage/projects/images/1.jpg",
                        "descripcion": "Vista aérea del proyecto"
                    }
                ],
                "path_videos": [],
                "path_documents": [],
                "advisors": [
                    {
                        "id": 2,
                        "name": "Carlos Vendedor",
                        "email": "carlos@example.com",
                        "is_primary": true
                    }
                ],
                "created_at": "2025-01-01 10:00:00",
                "updated_at": "2025-11-24 15:30:00"
            }
        ],
        "pagination": { ... }
    }
}
```

#### Ver Proyecto Completo

**Endpoint:** `GET /api/cazador/projects/{id}`

**Response 200:**
```json
{
    "success": true,
    "message": "Proyecto obtenido exitosamente",
    "data": {
        "project": {
            "id": 1,
            "name": "Proyecto Los Olivos",
            ...
            "units": [
                {
                    "id": 1,
                    "project_id": 1,
                    "unit_manzana": "A",
                    "unit_number": "Lote-001",
                    "unit_type": "lote",
                    "area": 200.00,
                    "status": "disponible",
                    "base_price": 50000.00,
                    "final_price": 50000.00,
                    ...
                }
            ]
        }
    }
}
```

#### Ver Unidades de un Proyecto

**Endpoint:** `GET /api/cazador/projects/{id}/units`

**Query Parameters:**
- `per_page` (opcional): Número de resultados por página
- `status` (opcional): Filtrar por estado (`disponible`, `reservado`, `vendido`, `bloqueado`)
- `unit_type` (opcional): Tipo de unidad
- `min_price`, `max_price` (opcional): Rango de precios
- `min_area`, `max_area` (opcional): Rango de áreas
- `bedrooms` (opcional): Número de dormitorios
- `only_available` (opcional): Solo unidades disponibles (true/false)

**Response 200:**
```json
{
    "success": true,
    "message": "Unidades obtenidas exitosamente",
    "data": {
        "project": {
            "id": 1,
            "name": "Proyecto Los Olivos"
        },
        "units": [
            {
                "id": 1,
                "project_id": 1,
                "unit_manzana": "A",
                "unit_number": "Lote-001",
                "unit_type": "lote",
                "area": 200.00,
                "status": "disponible",
                "base_price": 50000.00,
                "final_price": 50000.00,
                "price_per_square_meter": 250.00,
                "is_available": true,
                ...
            }
        ],
        "pagination": { ... }
    }
}
```

### Búsqueda de Documentos

#### Buscar Datos por DNI/RUC

**Endpoint:** `POST /api/cazador/documents/search`

**Rate Limit:** 30 solicitudes por minuto

**Headers:**
```
Authorization: Bearer {token}
```

**Request:**
```json
{
    "document_type": "dni",
    "document_number": "12345678"
}
```

**Parámetros:**
- `document_type` (requerido): Tipo de documento (`dni` o `ruc`)
- `document_number` (requerido): Número de documento
  - DNI: debe tener exactamente 8 dígitos (solo números)
  - RUC: debe tener exactamente 11 dígitos (solo números)
  - **Nota:** El sistema sanitiza automáticamente el número, eliminando cualquier carácter no numérico

**Response 200 (Éxito):**
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

**Response 404 (No encontrado):**
```json
{
    "success": false,
    "message": "No se encontró información para el documento proporcionado"
}
```

**Response 422 (Error de validación):**
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

**Notas:**
- Este servicio consulta datos externos de la API de Facturalahoy
- Los datos retornados incluyen información completa de la persona o empresa
- Si se encuentra información de ubigeo, se incluye en la respuesta
- El servicio valida y sanitiza el formato del documento antes de realizar la búsqueda
- Se eliminan automáticamente todos los caracteres no numéricos del número de documento
- Se registran todas las búsquedas en los logs del sistema para auditoría

---

## 🌐 Rutas Públicas

### Proyectos Publicados

Estas rutas son públicas y no requieren autenticación:

- `GET /api/projects` - Listar proyectos publicados
- `GET /api/projects/{id}` - Ver proyecto publicado
- `GET /api/projects/{id}/units` - Ver unidades de proyecto publicado

**Nota:** Solo se muestran proyectos con `is_published = true`.

---

## 📊 Modelos de Datos

### Cliente

```json
{
    "id": 1,
    "name": "string",
    "phone": "string",
    "document_type": "DNI|RUC|CE|PASAPORTE",
    "document_number": "string (único)",
    "address": "string (opcional)",
    "birth_date": "YYYY-MM-DD (obligatorio)",
    "client_type": "inversor|comprador|empresa|constructor",
    "source": "redes_sociales|ferias|referidos|formulario_web|publicidad",
    "status": "nuevo|contacto_inicial|en_seguimiento|cierre|perdido",
    "score": "integer (0-100)",
    "notes": "string",
    "assigned_advisor": {
        "id": 1,
        "name": "string",
        "email": "string"
    },
    "created_at": "YYYY-MM-DD HH:mm:ss",
    "updated_at": "YYYY-MM-DD HH:mm:ss"
}
```

### Proyecto

```json
{
    "id": 1,
    "name": "string",
    "description": "string",
    "project_type": "lotes|casas|departamentos|oficinas|mixto",
    "is_published": "boolean",
    "lote_type": "normal|express",
    "stage": "preventa|lanzamiento|venta_activa|cierre",
    "legal_status": "con_titulo|en_tramite|habilitado",
    "estado_legal": "Derecho Posesorio|Compra y Venta|Juez de Paz|Titulo de propiedad",
    "tipo_proyecto": "propio|tercero",
    "tipo_financiamiento": "contado|financiado",
    "banco": "string",
    "tipo_cuenta": "cuenta corriente|cuenta vista|cuenta ahorro",
    "cuenta_bancaria": "string",
    "address": "string",
    "district": "string",
    "province": "string",
    "region": "string",
    "country": "string",
    "ubicacion": "string (URL Google Maps)",
    "total_units": "integer",
    "available_units": "integer",
    "reserved_units": "integer",
    "sold_units": "integer",
    "blocked_units": "integer",
    "progress_percentage": "float",
    "start_date": "YYYY-MM-DD",
    "end_date": "YYYY-MM-DD",
    "delivery_date": "YYYY-MM-DD",
    "status": "activo|inactivo|suspendido|finalizado",
    "path_image_portada": "string (URL)",
    "path_video_portada": "string (URL)",
    "path_images": "array",
    "path_videos": "array",
    "path_documents": "array",
    "advisors": "array",
    "created_at": "YYYY-MM-DD HH:mm:ss",
    "updated_at": "YYYY-MM-DD HH:mm:ss"
}
```

### Comisión

```json
{
    "id": 1,
    "project": {
        "id": 1,
        "name": "string"
    },
    "unit": {
        "id": 1,
        "unit_number": "string"
    },
    "opportunity": {
        "id": 1,
        "client_name": "string"
    },
    "commission_type": "venta|reserva|seguimiento|bono",
    "base_amount": "decimal",
    "commission_percentage": "decimal",
    "commission_amount": "decimal",
    "bonus_amount": "decimal",
    "total_commission": "decimal",
    "status": "pendiente|aprobada|pagada|cancelada",
    "payment_date": "YYYY-MM-DD",
    "payment_method": "string",
    "payment_reference": "string",
    "notes": "string",
    "approved_at": "YYYY-MM-DD HH:mm:ss",
    "paid_at": "YYYY-MM-DD HH:mm:ss",
    "created_at": "YYYY-MM-DD HH:mm:ss",
    "updated_at": "YYYY-MM-DD HH:mm:ss"
}
```

---

## ⚠️ Manejo de Errores

La API implementa un sistema robusto de manejo de errores con logging completo para facilitar el debugging y la auditoría.

### Errores de Validación (422)

```json
{
    "success": false,
    "message": "Error de validación",
    "errors": {
        "name": ["El nombre es obligatorio."],
        "email": ["El email debe ser una dirección válida."]
    }
}
```

### Error de Autenticación (401)

```json
{
    "success": false,
    "message": "Token expirado"
}
```

### Error de Autorización (403)

```json
{
    "success": false,
    "message": "No tienes permiso para acceder a este cliente"
}
```

### Recurso No Encontrado (404)

```json
{
    "success": false,
    "message": "Cliente no encontrado"
}
```

### Error del Servidor (500)

```json
{
    "success": false,
    "message": "Error al crear el cliente",
    "errors": {
        "error": "Error interno del servidor"
    }
}
```

**Nota:** En modo desarrollo (`APP_DEBUG=true`), los errores incluyen detalles adicionales para debugging. En producción, solo se muestra un mensaje genérico por seguridad.

### Logging de Errores

Todos los errores se registran en los logs del sistema con información completa:
- **Contexto:** Usuario autenticado, IP, datos de la solicitud
- **Trazas:** Stack trace completo para debugging
- **Timestamps:** Fecha y hora exacta del error
- **Categorización:** Niveles de log (info, warning, error)

**Ejemplo de log:**
```
[2025-11-24 15:30:00] ERROR: Error al crear cliente (Datero)
User ID: 1
IP: 192.168.1.100
Data: {...}
Error: Database connection failed
Trace: ...
```

---

## 🚦 Rate Limiting

- **Login:** 5 solicitudes por minuto (más restrictivo por seguridad)
- **Búsqueda de documentos:** 30 solicitudes por minuto
- **Endpoints generales:** 60 solicitudes por minuto
- **Opciones de formularios:** 120 solicitudes por minuto

Cuando se excede el límite, se retorna:

```json
{
    "success": false,
    "message": "Too Many Attempts."
}
```

Con código HTTP `429`.

---

## 💻 Ejemplos de Integración

### Flutter/Dart

```dart
// Login
final response = await http.post(
  Uri.parse('https://lotesenremate.pe/api/datero/auth/login'),
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode({
    'email': 'datero@example.com',
    'password': 'password123',
  }),
);

final data = jsonDecode(response.body);
final token = data['data']['token'];

// Obtener clientes
final clientsResponse = await http.get(
  Uri.parse('https://lotesenremate.pe/api/datero/clients'),
  headers: {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  },
);
```

### JavaScript/React Native

```javascript
// Login
const login = async (email, password) => {
  const response = await fetch('https://lotesenremate.pe/api/datero/auth/login', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ email, password }),
  });
  
  const data = await response.json();
  return data.data.token;
};

// Obtener clientes
const getClients = async (token) => {
  const response = await fetch('https://lotesenremate.pe/api/datero/clients', {
    headers: {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json',
    },
  });
  
  return await response.json();
};
```

### cURL

```bash
# Login
curl -X POST https://lotesenremate.pe/api/datero/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "datero@example.com",
    "password": "password123"
  }'

# Obtener clientes
curl -X GET https://lotesenremate.pe/api/datero/clients \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json"
```

---

## 📝 Notas Importantes

1. **Tokens JWT:** Los tokens expiran según la configuración de `config/jwt.php` (por defecto 60 minutos)

2. **Paginación:** Todas las listas están paginadas. El máximo de resultados por página es 100.

3. **Fechas:** Todas las fechas se manejan en formato ISO 8601 (`YYYY-MM-DD` o `YYYY-MM-DD HH:mm:ss`)

4. **Monedas:** Todos los montos están en la moneda base del sistema (sin símbolo de moneda)

5. **Imágenes:** Las URLs de imágenes son relativas o absolutas según la configuración del servidor

6. **Sanitización Automática de Datos:**
   - **Números de documento:** Se eliminan automáticamente todos los caracteres no numéricos
   - **Teléfonos:** Se sanitizan para permitir solo números, guiones, paréntesis y espacios
   - **Nombres y direcciones:** Se eliminan espacios al inicio y final (trim)
   - **Emails:** Se normalizan a minúsculas y se eliminan espacios
   - **Score:** Se valida y limita al rango 0-100 automáticamente
   - **Búsquedas:** Se sanitizan para prevenir inyección SQL

7. **Validaciones Mejoradas:**
   - **Documentos:** Los números de documento solo aceptan dígitos (0-9)
   - **DNI:** Debe tener exactamente 8 dígitos
   - **RUC:** Debe tener exactamente 11 dígitos
   - **Email:** Se valida formato y se normaliza automáticamente
   - **Paginación:** Se valida que `per_page` esté entre 1 y 100

8. **Logging y Auditoría:**
   - Se registran todos los intentos de login (exitosos y fallidos)
   - Se registran accesos con roles incorrectos
   - Se registran accesos con cuentas inactivas
   - Se registran búsquedas de documentos
   - Se registran errores con contexto completo (usuario, IP, datos)
   - Los logs incluyen información de IP para auditoría de seguridad

9. **Seguridad:** 
   - Siempre usar HTTPS en producción
   - Almacenar tokens de forma segura
   - Implementar refresh token automático
   - No exponer tokens en logs
   - Sanitización automática de todas las entradas
   - Validación estricta de formatos
   - Prevención de inyección SQL en búsquedas
   - Logging de eventos de seguridad

---

## 🔄 Versión

**Versión actual:** 1.1  
**Última actualización:** 2025-11-24

### Changelog

#### v1.1 (2025-11-24)
- ✅ Mejoras de seguridad: Sanitización automática de todas las entradas
- ✅ Validaciones mejoradas: Validación estricta de formatos (documentos, emails, etc.)
- ✅ Sistema de logging: Registro completo de eventos y errores
- ✅ Auditoría de seguridad: Logs de intentos de login y accesos
- ✅ Manejo de errores mejorado: Respuestas consistentes y debugging mejorado
- ✅ Validación de paginación: Límites y validación de parámetros
- ✅ Sanitización de búsquedas: Prevención de inyección SQL

#### v1.0 (2025-11-24)
- ✅ Versión inicial de la API
- ✅ Autenticación JWT para Datero y Cazador
- ✅ Gestión de clientes
- ✅ Gestión de proyectos (Cazador)
- ✅ Comisiones (Datero)
- ✅ Búsqueda de documentos por DNI/RUC

---

## 📞 Soporte

Para soporte técnico o consultas sobre la API, contactar al equipo de desarrollo.

---

**Documentación generada automáticamente**  
**CRM Inmobiliario - API REST v1.0**

