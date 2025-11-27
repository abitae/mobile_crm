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
    Future.microtask(() => loadReservations());
  }

  /// Getter público para acceder al estado
  ReservationsState get currentState => state;

  /// Cargar reservas
  Future<void> loadReservations({bool refresh = false}) async {
    if (refresh) {
      state = state.copyWith(isLoading: true, error: null, currentPage: 1);
    } else {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      final response = await ReservationService.getReservations(
        page: refresh ? 1 : state.currentPage,
        perPage: 15,
        search: state.search,
        status: state.statusFilter,
        paymentStatus: state.paymentStatusFilter,
        projectId: state.projectIdFilter,
        clientId: state.clientIdFilter,
        advisorId: state.advisorIdFilter,
      );

      state = state.copyWith(
        reservations:
            refresh ? response.data : [...state.reservations, ...response.data],
        currentPage: response.currentPage,
        totalPages: response.totalPages,
        hasMore: response.currentPage < response.totalPages,
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

  /// Cargar más reservas (paginación)
  Future<void> loadMoreReservations() async {
    if (state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);
    try {
      final nextPage = state.currentPage + 1;
      final response = await ReservationService.getReservations(
        page: nextPage,
        perPage: 15,
        search: state.search,
        status: state.statusFilter,
        paymentStatus: state.paymentStatusFilter,
        projectId: state.projectIdFilter,
        clientId: state.clientIdFilter,
        advisorId: state.advisorIdFilter,
      );

      state = state.copyWith(
        reservations: [...state.reservations, ...response.data],
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

  /// Aplicar búsqueda
  void setSearch(String? search) {
    state = state.copyWith(search: search, currentPage: 1);
    loadReservations(refresh: true);
  }

  /// Aplicar filtros
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
      currentPage: 1,
    );
    loadReservations(refresh: true);
  }

  /// Limpiar filtros
  void clearFilters() {
    state = state.copyWith(
      search: null,
      statusFilter: null,
      paymentStatusFilter: null,
      projectIdFilter: null,
      clientIdFilter: null,
      advisorIdFilter: null,
      currentPage: 1,
    );
    loadReservations(refresh: true);
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
final reservationsProvider = Provider<ReservationsState>((ref) {
  // Observar el notifier para que el provider se actualice cuando cambie
  ref.watch(reservationsNotifierProvider);
  // Retornar el estado actual
  return ref.read(reservationsNotifierProvider).currentState;
});

/// Provider para una reserva específica
final reservationProvider =
    FutureProvider.family<ReservationModel, int>((ref, id) async {
  return await ReservationService.getReservation(id);
});

