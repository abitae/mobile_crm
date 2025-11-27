import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:state_notifier/state_notifier.dart';
import '../../../data/services/reservation_service.dart';
import '../../../data/models/reservation_model.dart';
import '../../../core/exceptions/api_exception.dart';

/// Estado del listado de reservas
class ReservationsState {
  final List<ReservationModel> reservations;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final int currentPage;
  final int totalPages;
  final bool hasMore;
  final String? search;
  final String? statusFilter;
  final String? paymentStatusFilter;
  final int? projectIdFilter;
  final int? clientIdFilter;
  final int? advisorIdFilter;

  ReservationsState({
    List<ReservationModel>? reservations,
    bool? isLoading,
    bool? isLoadingMore,
    this.error,
    int? currentPage,
    int? totalPages,
    bool? hasMore,
    this.search,
    this.statusFilter,
    this.paymentStatusFilter,
    this.projectIdFilter,
    this.clientIdFilter,
    this.advisorIdFilter,
  })  : reservations = reservations ?? const [],
        isLoading = isLoading ?? false,
        isLoadingMore = isLoadingMore ?? false,
        currentPage = currentPage ?? 1,
        totalPages = totalPages ?? 1,
        hasMore = hasMore ?? false;

  ReservationsState copyWith({
    List<ReservationModel>? reservations,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    int? currentPage,
    int? totalPages,
    bool? hasMore,
    String? search,
    String? statusFilter,
    String? paymentStatusFilter,
    int? projectIdFilter,
    int? clientIdFilter,
    int? advisorIdFilter,
  }) {
    return ReservationsState(
      reservations: reservations ?? this.reservations,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      hasMore: hasMore ?? this.hasMore,
      search: search ?? this.search,
      statusFilter: statusFilter ?? this.statusFilter,
      paymentStatusFilter: paymentStatusFilter ?? this.paymentStatusFilter,
      projectIdFilter: projectIdFilter ?? this.projectIdFilter,
      clientIdFilter: clientIdFilter ?? this.clientIdFilter,
      advisorIdFilter: advisorIdFilter ?? this.advisorIdFilter,
    );
  }
}

/// Provider de reservas
class ReservationsNotifier extends StateNotifier<ReservationsState> {
  ReservationsNotifier() : super(ReservationsState()) {
    // Cargar reservas al inicializar (similar a clients y projects)
    loadReservations();
  }

  /// Getter público para acceder al estado
  ReservationsState get currentState => state;

  /// Lista completa de reservas (sin filtros aplicados)
  List<ReservationModel> _allReservations = [];

  /// Aplicar filtros locales a las reservas
  List<ReservationModel> _applyFilters(List<ReservationModel> reservations) {
    var filtered = reservations;

    // Filtro por estado
    if (state.statusFilter != null && state.statusFilter!.isNotEmpty) {
      filtered = filtered
          .where((r) => r.status == state.statusFilter)
          .toList();
    }

    // Filtro por estado de pago
    if (state.paymentStatusFilter != null &&
        state.paymentStatusFilter!.isNotEmpty) {
      filtered = filtered
          .where((r) => r.paymentStatus == state.paymentStatusFilter)
          .toList();
    }

    // Filtro por proyecto
    if (state.projectIdFilter != null) {
      filtered = filtered
          .where((r) => r.projectId == state.projectIdFilter)
          .toList();
    }

    // Filtro por cliente
    if (state.clientIdFilter != null) {
      filtered = filtered
          .where((r) => r.clientId == state.clientIdFilter)
          .toList();
    }

    // Filtro por búsqueda (número de reserva, nombre de cliente o proyecto)
    if (state.search != null && state.search!.isNotEmpty) {
      final searchLower = state.search!.toLowerCase();
      filtered = filtered.where((r) {
        final reservationNumber = r.reservationNumber.toLowerCase();
        final clientName = r.client?.name.toLowerCase() ?? '';
        final projectName = r.project?.name.toLowerCase() ?? '';
        return reservationNumber.contains(searchLower) ||
            clientName.contains(searchLower) ||
            projectName.contains(searchLower);
      }).toList();
    }

    return filtered;
  }

  /// Cargar reservas
  /// Nota: Según la documentación, el API solo acepta `page` y `per_page`.
  /// Los filtros se aplican localmente después de cargar los datos.
  Future<void> loadReservations({bool refresh = false}) async {
    if (refresh) {
      state = state.copyWith(isLoading: true, error: null, currentPage: 1);
      _allReservations = [];
    } else {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      print('🔄 [ReservationsNotifier] Cargando reservas (refresh: $refresh, page: ${refresh ? 1 : state.currentPage})');
      
      final response = await ReservationService.getReservations(
        page: refresh ? 1 : state.currentPage,
        perPage: 15,
      );

      print('✅ [ReservationsNotifier] Reservas cargadas: ${response.data.length}');
      print('📄 [ReservationsNotifier] Página actual: ${response.currentPage}, Total páginas: ${response.totalPages}');

      // Actualizar lista completa de reservas
      if (refresh) {
        _allReservations = response.data;
      } else {
        _allReservations = [..._allReservations, ...response.data];
      }

      // Aplicar filtros locales
      final filteredReservations = _applyFilters(_allReservations);

      state = state.copyWith(
        reservations: filteredReservations,
        currentPage: response.currentPage,
        totalPages: response.totalPages,
        hasMore: response.currentPage < response.totalPages,
        isLoading: false,
        error: null,
      );
      
      print('✅ [ReservationsNotifier] Estado actualizado. Total reservas: ${_allReservations.length}, Filtradas: ${filteredReservations.length}');
    } on ApiException catch (e) {
      print('❌ [ReservationsNotifier] ApiException: ${e.message}');
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
    } catch (e, stackTrace) {
      print('❌ [ReservationsNotifier] Error inesperado: $e');
      print('❌ [ReservationsNotifier] StackTrace: $stackTrace');
      state = state.copyWith(
        isLoading: false,
        error: 'Error inesperado: ${e.toString()}',
      );
    }
  }

  /// Cargar más reservas (paginación)
  Future<void> loadMoreReservations() async {
    if (state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);
    try {
      final nextPage = state.currentPage + 1;
      final response = await ReservationService.getReservations(
        page: nextPage,
        perPage: 15,
      );

      // Agregar a la lista completa
      _allReservations = [..._allReservations, ...response.data];

      // Aplicar filtros locales
      final filteredReservations = _applyFilters(_allReservations);

      state = state.copyWith(
        reservations: filteredReservations,
        currentPage: response.currentPage,
        totalPages: response.totalPages,
        hasMore: response.currentPage < response.totalPages,
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

  /// Aplicar búsqueda (filtrado local)
  void setSearch(String? search) {
    state = state.copyWith(search: search);
    // Aplicar filtros localmente sin recargar del API
    final filteredReservations = _applyFilters(_allReservations);
    state = state.copyWith(reservations: filteredReservations);
  }

  /// Aplicar filtros (filtrado local)
  void setFilters({
    String? status,
    String? paymentStatus,
    int? projectId,
    int? clientId,
    int? advisorId,
  }) {
    state = state.copyWith(
      statusFilter: status,
      paymentStatusFilter: paymentStatus,
      projectIdFilter: projectId,
      clientIdFilter: clientId,
      advisorIdFilter: advisorId,
    );
    // Aplicar filtros localmente sin recargar del API
    final filteredReservations = _applyFilters(_allReservations);
    state = state.copyWith(reservations: filteredReservations);
  }

  /// Limpiar filtros (filtrado local)
  void clearFilters() {
    state = state.copyWith(
      search: null,
      statusFilter: null,
      paymentStatusFilter: null,
      projectIdFilter: null,
      clientIdFilter: null,
      advisorIdFilter: null,
    );
    // Mostrar todas las reservas sin filtros
    state = state.copyWith(reservations: _allReservations);
  }

  /// Limpiar error
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Refrescar lista
  Future<void> refreshReservations() async {
    await loadReservations(refresh: true);
  }
}

/// Provider global del notifier de reservas
final reservationsNotifierProvider =
    Provider<ReservationsNotifier>((ref) {
  final notifier = ReservationsNotifier();
  ref.onDispose(() => notifier.dispose());
  return notifier;
});

/// Provider global de reservas (estado) - reactivo
/// Observa el notifier y accede al estado actual
/// Nota: Para que sea completamente reactivo, los widgets deben observar
/// directamente reservationsNotifierProvider y acceder a currentState
final reservationsProvider = Provider<ReservationsState>((ref) {
  // Observar el notifier para que el provider se actualice cuando cambie
  final notifier = ref.watch(reservationsNotifierProvider);
  // Retornar el estado actual del notifier
  return notifier.currentState;
});

/// Provider para una reserva específica
final reservationProvider =
    FutureProvider.family<ReservationModel, int>((ref, id) async {
  return await ReservationService.getReservation(id);
});

