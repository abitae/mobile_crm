# API Datero - Documentación

## 📋 Introducción

La API Datero está diseñada para usuarios con rol **Datero** (captadores de leads). Esta API permite gestionar clientes, consultar comisiones y realizar operaciones de autenticación con DNI y PIN.

## 🔐 Autenticación

La API utiliza **JWT (JSON Web Tokens)** para autenticación. Todas las rutas protegidas requieren un token válido en el header de la petición.

### Header de Autenticación

```
Authorization: Bearer {token}
```

### Base URL

```
https://tu-dominio.com/api/datero
```

## 📚 Índice de Documentación

- **[AUTH.md](./AUTH.md)** - Autenticación y gestión de sesión (Registro, Login con DNI/PIN, Cambio de PIN)
- **[CLIENTS.md](./CLIENTS.md)** - Gestión de clientes (Crear, Editar, Listar, Buscar por DNI)
- **[COMMISSIONS.md](./COMMISSIONS.md)** - Consulta de comisiones
- **[PROFILE.md](./PROFILE.md)** - Gestión de perfil

## 🎯 Rol Permitido

- **Datero** (Captador de datos)

> ⚠️ **Nota**: Solo usuarios con rol **Datero** pueden acceder a esta API. Los usuarios con otros roles (Administrador, Líder, Cazador) no pueden usar esta API.

## 🔑 Autenticación con DNI y PIN

Los dateros utilizan un sistema de autenticación especial:
- **DNI**: Documento Nacional de Identidad (único por usuario)
- **PIN**: Código de 6 dígitos numéricos

> 💡 **Nota**: El PIN se almacena hasheado en la base de datos por seguridad.

## 📊 Formato de Respuesta

Todas las respuestas siguen un formato estándar:

### Respuesta Exitosa

```json
{
  "success": true,
  "message": "Operación exitosa",
  "data": {
    // Datos de la respuesta
  }
}
```

### Respuesta de Error

```json
{
  "success": false,
  "message": "Mensaje de error",
  "errors": {
    // Detalles del error (opcional)
  }
}
```

## 📄 Códigos de Estado HTTP

- `200` - Éxito
- `201` - Creado exitosamente
- `400` - Solicitud incorrecta
- `401` - No autenticado
- `403` - Acceso denegado
- `404` - Recurso no encontrado
- `409` - Conflicto (recurso ya existe)
- `422` - Error de validación
- `500` - Error del servidor

## 🔒 Rate Limiting

- **Registro**: 3 requests por minuto
- **Login**: 5 requests por minuto
- **Endpoints generales**: 60 requests por minuto
- **Opciones de formularios**: 120 requests por minuto

## 🚀 Inicio Rápido

### 1. Registro de Datero

```bash
POST /api/datero/auth/register
```

```json
{
  "name": "Juan Pérez",
  "email": "juan.perez@example.com",
  "phone": "987654321",
  "dni": "12345678",
  "pin": "123456",
  "lider_id": 5
}
```

### 2. Iniciar Sesión

```bash
POST /api/datero/auth/login
```

```json
{
  "dni": "12345678",
  "pin": "123456"
}
```

### 3. Usar el Token

Todas las peticiones protegidas requieren el token en el header:

```bash
Authorization: Bearer {token}
```

## 📝 Funcionalidades Principales

### Clientes
- ✅ Crear nuevos clientes
- ✅ Editar clientes propios
- ✅ Listar clientes creados por el datero
- ✅ Buscar clientes por DNI
- ✅ Ver detalles de un cliente

### Comisiones
- ✅ Ver comisiones asignadas
- ✅ Ver estadísticas de comisiones
- ✅ Filtrar comisiones por estado, tipo y fecha

### Perfil
- ✅ Ver información del perfil
- ✅ Actualizar datos del perfil

## 🔗 Enlaces Útiles

- [Documentación de Autenticación](./AUTH.md)
- [Documentación de Clientes](./CLIENTS.md)
- [Documentación de Comisiones](./COMMISSIONS.md)
- [Documentación de Perfil](./PROFILE.md)

