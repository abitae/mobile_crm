# Patrón Estándar de Providers

Este documento describe el patrón estándar que deben seguir todos los providers de la aplicación para mantener consistencia y facilitar el mantenimiento.

## Estructura del Estado

Todos los estados de listado deben incluir los siguientes campos base:

```dart
class XxxState {
  // Datos
  final List<XxxModel> items;
  
  // Estados de carga
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  
  // Paginación
  final int currentPage;
  final int totalPages;
  final bool hasMore;
  
  // Filtros y búsqueda
  final String? search;
  // ... otros filtros específicos
  
  // Constructor con valores por defecto
  XxxState({
    List<XxxModel>? items,
    bool? isLoading,
    bool? isLoadingMore,
    this.error,
    int? currentPage,
    int? totalPages,
    bool? hasMore,
    this.search,
    // ... otros filtros
  }) : items = items ?? const [],
       isLoading = isLoading ?? false,
       isLoadingMore = isLoadingMore ?? false,
       currentPage = currentPage ?? 1,
       totalPages = totalPages ?? 1,
       hasMore = hasMore ?? false;
  
  // Método copyWith
  XxxState copyWith({...}) {
    return XxxState(
      items: items ?? this.items,
      // ... otros campos
    );
  }
}
```

## Estructura del Notifier

Todos los notifiers deben seguir este patrón:

```dart
class XxxNotifier extends StateNotifier<XxxState> {
  XxxNotifier() : super(XxxState()) {
    loadXxx(); // Cargar datos iniciales
  }

  /// Getter público para acceder al estado
  XxxState get currentState => state;

  /// Cargar datos (primera carga o refresh)
  Future<void> loadXxx({bool refresh = false}) async {
    if (refresh) {
      state = state.copyWith(isLoading: true, error: null, currentPage: 1);
    } else {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      final response = await XxxService.getXxx(
        page: refresh ? 1 : state.currentPage,
        perPage: 15,
        search: state.search,
        // ... otros filtros
      );

      state = state.copyWith(
        items: refresh ? response.data : [...state.items, ...response.data],
        currentPage: response.currentPage,
        totalPages: response.totalPages,
        hasMore: response.hasMore, // Usar hasMore del response
        isLoading: false,
        error: null,
      );
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error inesperado: ${e.toString()}',
      );
    }
  }

  /// Cargar más datos (paginación)
  Future<void> loadMoreXxx() async {
    if (state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);
    try {
      final nextPage = state.currentPage + 1;
      final response = await XxxService.getXxx(
        page: nextPage,
        perPage: 15,
        search: state.search,
        // ... otros filtros
      );

      state = state.copyWith(
        items: [...state.items, ...response.data],
        currentPage: response.currentPage,
        totalPages: response.totalPages,
        hasMore: response.hasMore, // Usar hasMore del response
        isLoadingMore: false,
      );
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        error: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        error: 'Error inesperado: ${e.toString()}',
      );
    }
  }

  /// Aplicar búsqueda
  Future<void> setSearch(String? search) async {
    state = state.copyWith(search: search, currentPage: 1, hasMore: true);
    await loadXxx(refresh: true);
  }

  /// Aplicar filtros
  Future<void> setFilters({...}) async {
    state = state.copyWith(
      // ... actualizar filtros
      currentPage: 1,
      hasMore: true,
    );
    await loadXxx(refresh: true);
  }

  /// Limpiar filtros
  Future<void> clearFilters() async {
    state = state.copyWith(
      search: null,
      // ... limpiar todos los filtros
      currentPage: 1,
      hasMore: true,
    );
    await loadXxx(refresh: true);
  }

  /// Limpiar error
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Refrescar lista
  Future<void> refreshXxx() async {
    await loadXxx(refresh: true);
  }
}
```

## Estructura de Providers

Todos los providers deben seguir este patrón:

```dart
/// Provider global del notifier
final xxxNotifierProvider = StateNotifierProvider<XxxNotifier, XxxState>((ref) {
  final notifier = XxxNotifier();
  ref.onDispose(() => notifier.dispose());
  return notifier;
});

/// Provider global del estado (reactivo)
final xxxProvider = Provider<XxxState>((ref) {
  return ref.watch(xxxNotifierProvider).currentState;
});

/// Provider para un item específico (si aplica)
final xxxItemProvider = FutureProvider.family<XxxModel, int>((ref, id) async {
  return await XxxService.getXxx(id);
});
```

## Convenciones

1. **Nombres**: 
   - Estado: `XxxState`
   - Notifier: `XxxNotifier`
   - Provider del notifier: `xxxNotifierProvider`
   - Provider del estado: `xxxProvider`
   - Provider de item: `xxxItemProvider`

2. **Paginación**: 
   - Usar `response.hasMore` en lugar de calcular `currentPage < totalPages`
   - Siempre verificar `!state.hasMore` antes de cargar más

3. **Manejo de errores**: 
   - Usar `ExceptionHelper.fromDioException()` para convertir errores
   - Siempre limpiar el error al iniciar una nueva operación

4. **Prevención de duplicados**: 
   - Filtrar items existentes al cargar más datos
   - Usar `Set` de IDs para verificación eficiente

5. **Refresh**: 
   - Siempre resetear `currentPage` a 1 en refresh
   - Reemplazar datos en lugar de agregar en refresh

## Providers Existentes

- ✅ `ClientProvider` - Sigue el patrón
- ✅ `DateroProvider` - Sigue el patrón
- ✅ `ProjectProvider` - Sigue el patrón
- ✅ `ReservationProvider` - Sigue el patrón
- ✅ `DashboardProvider` - Patrón simplificado (sin paginación)
- ✅ `AuthProvider` - Patrón específico para autenticación
