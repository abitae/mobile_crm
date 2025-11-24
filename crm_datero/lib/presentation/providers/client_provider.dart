import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:state_notifier/state_notifier.dart';
import '../../../data/services/client_service.dart';
import '../../../data/models/client_model.dart';
import '../../../data/models/client_options.dart';
import '../../../core/exceptions/api_exception.dart';

/// Estado del listado de clientes
class ClientsState {
  final List<ClientModel> clients;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final int currentPage;
  final int totalPages;
  final bool hasMore;
  final String? search;
  final String? statusFilter;
  final String? typeFilter;
  final String? sourceFilter;

  ClientsState({
    List<ClientModel>? clients,
    bool? isLoading,
    bool? isLoadingMore,
    this.error,
    int? currentPage,
    int? totalPages,
    bool? hasMore,
    this.search,
    this.statusFilter,
    this.typeFilter,
    this.sourceFilter,
  })  : clients = clients ?? const [],
        isLoading = isLoading ?? false,
        isLoadingMore = isLoadingMore ?? false,
        currentPage = currentPage ?? 1,
        totalPages = totalPages ?? 1,
        hasMore = hasMore ?? false;

  ClientsState copyWith({
    List<ClientModel>? clients,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    int? currentPage,
    int? totalPages,
    bool? hasMore,
    String? search,
    String? statusFilter,
    String? typeFilter,
    String? sourceFilter,
  }) {
    return ClientsState(
      clients: clients ?? this.clients,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      hasMore: hasMore ?? this.hasMore,
      search: search ?? this.search,
      statusFilter: statusFilter ?? this.statusFilter,
      typeFilter: typeFilter ?? this.typeFilter,
      sourceFilter: sourceFilter ?? this.sourceFilter,
    );
  }
}

/// Provider de clientes
class ClientsNotifier extends StateNotifier<ClientsState> {
  ClientsNotifier() : super(ClientsState()) {
    loadClients();
  }

  /// Getter público para acceder al estado
  ClientsState get currentState => state;

  /// Cargar clientes
  Future<void> loadClients({bool refresh = false}) async {
    if (refresh) {
      state = state.copyWith(isLoading: true, error: null, currentPage: 1);
    } else {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      final response = await ClientService.getClients(
        page: refresh ? 1 : state.currentPage,
        perPage: 15,
        search: state.search,
        status: state.statusFilter,
        type: state.typeFilter,
        source: state.sourceFilter,
      );

      state = state.copyWith(
        clients: refresh ? response.data : [...state.clients, ...response.data],
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

  /// Cargar más clientes (paginación)
  Future<void> loadMoreClients() async {
    if (state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);
    try {
      final nextPage = state.currentPage + 1;
      final response = await ClientService.getClients(
        page: nextPage,
        perPage: 15,
        search: state.search,
        status: state.statusFilter,
        type: state.typeFilter,
        source: state.sourceFilter,
      );

      state = state.copyWith(
        clients: [...state.clients, ...response.data],
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
    loadClients(refresh: true);
  }

  /// Aplicar filtros
  void setFilters({
    String? status,
    String? type,
    String? source,
  }) {
    state = state.copyWith(
      statusFilter: status,
      typeFilter: type,
      sourceFilter: source,
      currentPage: 1,
    );
    loadClients(refresh: true);
  }

  /// Limpiar filtros
  void clearFilters() {
    state = state.copyWith(
      search: null,
      statusFilter: null,
      typeFilter: null,
      sourceFilter: null,
      currentPage: 1,
    );
    loadClients(refresh: true);
  }

  /// Limpiar error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provider global del notifier de clientes
final clientsNotifierProvider = Provider<ClientsNotifier>((ref) {
  final notifier = ClientsNotifier();
  ref.onDispose(() => notifier.dispose());
  return notifier;
});

/// Provider global de clientes (estado)
/// Nota: Este provider no es completamente reactivo.
/// Para actualizaciones reactivas, considera usar ref.watch(clientsNotifierProvider)
/// y acceder al estado directamente desde el notifier cuando sea necesario.
final clientsProvider = Provider<ClientsState>((ref) {
  final notifier = ref.watch(clientsNotifierProvider);
  return notifier.currentState;
});

/// Provider para opciones de formularios
final clientOptionsProvider =
    FutureProvider<ClientOptions>((ref) async {
  return await ClientService.getOptions();
});

/// Provider para un cliente específico
final clientProvider =
    FutureProvider.family<ClientModel, int>((ref, id) async {
  return await ClientService.getClient(id);
});

