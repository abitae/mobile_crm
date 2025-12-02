import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:state_notifier/state_notifier.dart';
import '../../../data/services/commission_service.dart';
import '../../../data/models/commission_model.dart';
import '../../../data/models/commission_stats_model.dart';
import '../../../core/exceptions/api_exception.dart';

/// Estado de comisiones
class CommissionState {
  final List<CommissionModel> commissions;
  final CommissionStatsModel? stats;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final int currentPage;
  final int totalPages;
  final bool hasMore;

  CommissionState({
    this.commissions = const [],
    this.stats,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.currentPage = 1,
    this.totalPages = 1,
    this.hasMore = false,
  });

  CommissionState copyWith({
    List<CommissionModel>? commissions,
    CommissionStatsModel? stats,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    int? currentPage,
    int? totalPages,
    bool? hasMore,
  }) {
    return CommissionState(
      commissions: commissions ?? this.commissions,
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

/// Provider de comisiones
class CommissionNotifier extends StateNotifier<CommissionState> {
  CommissionNotifier() : super(CommissionState()) {
    loadCommissions();
    loadStats();
  }

  CommissionState get currentState => state;

  String? _currentStatus;
  String? _currentCommissionType;
  String? _currentStartDate;
  String? _currentEndDate;

  /// Cargar comisiones
  Future<void> loadCommissions({
    bool refresh = false,
    String? status,
    String? commissionType,
    String? startDate,
    String? endDate,
  }) async {
    if (refresh) {
      _currentStatus = status;
      _currentCommissionType = commissionType;
      _currentStartDate = startDate;
      _currentEndDate = endDate;
      state = state.copyWith(
        isLoading: true,
        error: null,
        currentPage: 1,
      );
    } else {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      final page = refresh ? 1 : state.currentPage;
      final response = await CommissionService.getCommissions(
        page: page,
        perPage: 15,
        status: status ?? _currentStatus,
        commissionType: commissionType ?? _currentCommissionType,
        startDate: startDate ?? _currentStartDate,
        endDate: endDate ?? _currentEndDate,
      );

      state = state.copyWith(
        commissions: refresh ? response.data : [...state.commissions, ...response.data],
        isLoading: false,
        error: null,
        currentPage: response.currentPage,
        totalPages: response.totalPages,
        hasMore: response.currentPage < response.totalPages,
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

  /// Cargar más comisiones (paginación)
  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);
    try {
      final response = await CommissionService.getCommissions(
        page: state.currentPage + 1,
        perPage: 15,
        status: _currentStatus,
        commissionType: _currentCommissionType,
        startDate: _currentStartDate,
        endDate: _currentEndDate,
      );

      state = state.copyWith(
        commissions: [...state.commissions, ...response.data],
        isLoadingMore: false,
        currentPage: response.currentPage,
        totalPages: response.totalPages,
        hasMore: response.currentPage < response.totalPages,
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

  /// Cargar estadísticas
  Future<void> loadStats() async {
    try {
      final stats = await CommissionService.getStats();
      state = state.copyWith(stats: stats);
    } catch (e) {
      // No mostrar error en stats, solo no actualizar
    }
  }

  /// Limpiar error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provider global del notifier de comisiones
final commissionNotifierProvider = Provider<CommissionNotifier>((ref) {
  final notifier = CommissionNotifier();
  ref.onDispose(() => notifier.dispose());
  return notifier;
});

/// Provider global de comisiones (estado)
final commissionProvider = Provider<CommissionState>((ref) {
  final notifier = ref.watch(commissionNotifierProvider);
  return notifier.currentState;
});

