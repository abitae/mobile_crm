import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:state_notifier/state_notifier.dart';
import '../../../data/services/datero_service.dart';
import '../../../data/models/datero_model.dart';
import '../../../core/exceptions/api_exception.dart';

/// Estado del listado de dateros
class DaterosState {
  final List<DateroModel> dateros;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final int currentPage;
  final int totalPages;
  final bool hasMore;
  final String? search;
  final bool? isActiveFilter;

  DaterosState({
    List<DateroModel>? dateros,
    bool? isLoading,
    bool? isLoadingMore,
    this.error,
    int? currentPage,
    int? totalPages,
    bool? hasMore,
    this.search,
    this.isActiveFilter,
  })  : dateros = dateros ?? const [],
        isLoading = isLoading ?? false,
        isLoadingMore = isLoadingMore ?? false,
        currentPage = currentPage ?? 1,
        totalPages = totalPages ?? 1,
        hasMore = hasMore ?? false;

  DaterosState copyWith({
    List<DateroModel>? dateros,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    int? currentPage,
    int? totalPages,
    bool? hasMore,
    String? search,
    bool? isActiveFilter,
  }) {
    return DaterosState(
      dateros: dateros ?? this.dateros,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      hasMore: hasMore ?? this.hasMore,
      search: search ?? this.search,
      isActiveFilter: isActiveFilter ?? this.isActiveFilter,
    );
  }
}

/// Provider de dateros
class DaterosNotifier extends StateNotifier<DaterosState> {
  DaterosNotifier() : super(DaterosState()) {
    loadDateros();
  }

  /// Getter público para acceder al estado
  DaterosState get currentState => state;

  /// Cargar dateros
  Future<void> loadDateros({bool refresh = false}) async {
    if (refresh) {
      state = state.copyWith(isLoading: true, error: null, currentPage: 1);
    } else {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      final response = await DateroService.getDateros(
        page: refresh ? 1 : state.currentPage,
        perPage: 15,
        search: state.search,
        isActive: state.isActiveFilter,
      );

      // Prevenir duplicados
      List<DateroModel> newDateros;
      if (refresh) {
        newDateros = response.data;
      } else {
        final existingIds = state.dateros.map((c) => c.id).toSet();
        newDateros =
            response.data.where((c) => !existingIds.contains(c.id)).toList();
        newDateros = [...state.dateros, ...newDateros];
      }

      state = state.copyWith(
        dateros: newDateros,
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

  /// Cargar más dateros (paginación)
  Future<void> loadMoreDateros() async {
    if (state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);
    try {
      final nextPage = state.currentPage + 1;
      final response = await DateroService.getDateros(
        page: nextPage,
        perPage: 15,
        search: state.search,
        isActive: state.isActiveFilter,
      );

      // Prevenir duplicados
      final existingIds = state.dateros.map((c) => c.id).toSet();
      final newDateros =
          response.data.where((c) => !existingIds.contains(c.id)).toList();

      state = state.copyWith(
        dateros: [...state.dateros, ...newDateros],
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
    loadDateros(refresh: true);
  }

  /// Aplicar filtro de activo/inactivo
  void setIsActiveFilter(bool? isActive) {
    state = state.copyWith(isActiveFilter: isActive, currentPage: 1);
    loadDateros(refresh: true);
  }

  /// Limpiar filtros
  void clearFilters() {
    state = state.copyWith(
      search: null,
      isActiveFilter: null,
      currentPage: 1,
    );
    loadDateros(refresh: true);
  }

  /// Limpiar error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provider global del notifier de dateros
final daterosNotifierProvider = Provider<DaterosNotifier>((ref) {
  final notifier = DaterosNotifier();
  ref.onDispose(() => notifier.dispose());
  return notifier;
});

/// Provider global de dateros (estado) - reactivo
final daterosProvider = Provider<DaterosState>((ref) {
  ref.watch(daterosNotifierProvider);
  return ref.read(daterosNotifierProvider).currentState;
});

/// Provider para un datero específico
final dateroProvider =
    FutureProvider.family<DateroModel, int>((ref, id) async {
  return await DateroService.getDatero(id);
});


