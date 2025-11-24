# crm_cazador

Aplicación móvil Flutter para sistema CRM inmobiliario - Cazador (Vendedores)

## Descripción

Aplicación móvil diseñada para usuarios con rol "vendedor" (cazadores) que gestionan clientes y proyectos completos en el sistema CRM inmobiliario.

## Características

- ✅ Autenticación JWT segura
- ✅ Gestión de clientes
- ✅ Gestión de proyectos inmobiliarios
- ✅ Visualización de unidades disponibles
- ✅ Material Design 3
- ✅ Arquitectura limpia con Riverpod

## Estructura del Proyecto

```
lib/
├── config/          # Configuración (rutas, API, app)
├── core/            # Excepciones y lógica central
├── data/            # Capa de datos
│   ├── models/      # Modelos de datos
│   └── services/    # Servicios de API y almacenamiento
└── presentation/    # Capa de presentación
    ├── providers/   # State management (Riverpod)
    ├── screens/     # Pantallas de la app
    ├── theme/        # Temas y estilos
    └── widgets/     # Widgets reutilizables
```

## Endpoints de API

Todos los endpoints usan el prefijo `/cazador/`:
- `/cazador/auth/login`
- `/cazador/auth/me`
- `/cazador/clients`
- `/cazador/projects`

## Getting Started

1. Instalar dependencias:
```bash
flutter pub get
```

2. Configurar la URL de la API en `lib/config/app_config.dart`

3. Ejecutar la aplicación:
```bash
flutter run
```

## Tecnologías

- Flutter 3.2.0+
- Riverpod 3.0.3
- Dio 5.4.0
- GoRouter 16.3.0
- Material Design 3

