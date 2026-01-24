import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:state_notifier/state_notifier.dart';
import '../../data/services/dashboard_service.dart';
import '../../core/exceptions/api_exception.dart';

/// Estado del dashboard
class DashboardState {
  final DashboardStats? stats;
  final bool isLoading;
  final String? error;
  final DateTime? lastUpdated;

  DashboardState({
    this.stats,
    this.isLoading = false,
    this.error,
    this.lastUpdated,
  });

  DashboardState copyWith({
    DashboardStats? stats,
    bool? isLoading,
    String? error,
    DateTime? lastUpdated,
    bool clearError = false,
  }) {
    return DashboardState(
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

/// Provider de dashboard
class DashboardNotifier extends StateNotifier<DashboardState> {
  DashboardNotifier() : super(DashboardState()) {
    loadStats();
  }

  /// Getter público para acceder al estado
  DashboardState get currentState => state;

  /// Cargar estadísticas del dashboard
  Future<void> loadStats({bool refresh = false}) async {
    if (state.isLoading && !refresh) return;

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final stats = await DashboardService.getStats();
      
      state = state.copyWith(
        stats: stats,
        isLoading: false,
        lastUpdated: DateTime.now(),
        clearError: true,
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

  /// Refrescar estadísticas
  Future<void> refresh() => loadStats(refresh: true);
}

/// Provider global del notifier de dashboard
final dashboardNotifierProvider = Provider<DashboardNotifier>((ref) {
  final notifier = DashboardNotifier();
  ref.onDispose(() => notifier.dispose());
  return notifier;
});

/// Provider global del estado del dashboard (reactivo)
final dashboardProvider = Provider<DashboardState>((ref) {
  return ref.watch(dashboardNotifierProvider).currentState;
});
