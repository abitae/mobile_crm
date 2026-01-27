import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:state_notifier/state_notifier.dart';
import 'package:flutter/foundation.dart';
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
    // Cargar datos después de la inicialización
    Future.microtask(() => loadStats());
  }

  /// Getter público para acceder al estado
  DashboardState get currentState => state;

  /// Cargar estadísticas del dashboard
  Future<void> loadStats({bool refresh = false}) async {
    if (state.isLoading && !refresh) return;

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final stats = await DashboardService.getStats();
      
      debugPrint('📊 [DashboardNotifier] Estadísticas recibidas:');
      debugPrint('   - Clientes: ${stats.clients.total}');
      debugPrint('   - Dateros: ${stats.dateros.total}');
      debugPrint('   - Reservas: ${stats.reservations.total}');
      
      state = state.copyWith(
        stats: stats,
        isLoading: false,
        lastUpdated: DateTime.now(),
        clearError: true,
      );
      
      debugPrint('✅ [DashboardNotifier] Estado actualizado');
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
/// Usa un StateNotifierProvider implícito para reactividad completa
final dashboardProvider = Provider<DashboardState>((ref) {
  final notifier = ref.watch(dashboardNotifierProvider);
  
  // Escuchar cambios del estado del notifier
  ref.listen<DashboardNotifier>(
    dashboardNotifierProvider,
    (previous, next) {
      // Forzar actualización cuando el notifier cambia
      // Esto se hace automáticamente cuando el estado del notifier cambia
    },
  );
  
  // Retornar el estado actual
  return notifier.currentState;
});
