import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:state_notifier/state_notifier.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/models/user_model.dart';
import '../../../core/exceptions/api_exception.dart';


/// Estado de autenticación
class AuthState {
  final UserModel? user;
  final bool isLoading;
  final bool isAuthenticated;
  final String? error;

  AuthState({
    this.user,
    this.isLoading = false,
    this.isAuthenticated = false,
    this.error,
  });

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    bool? isAuthenticated,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      error: error,
    );
  }
}

/// Provider de autenticación
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState()) {
    _checkAuth();
  }

  /// Getter público para acceder al estado (compatibilidad)
  AuthState get currentState => state;

  /// Verificar si hay sesión activa
  Future<void> _checkAuth() async {
    state = state.copyWith(isLoading: true);
    try {
      final isAuth = await AuthService.isAuthenticated();
      if (isAuth) {
        final user = await AuthService.getCurrentUser();
        if (user != null) {
          state = state.copyWith(
            user: user,
            isAuthenticated: true,
            isLoading: false,
          );
        } else {
          state = state.copyWith(
            isAuthenticated: false,
            isLoading: false,
          );
        }
      } else {
        state = state.copyWith(
          isAuthenticated: false,
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isAuthenticated: false,
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Login
  Future<bool> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await AuthService.login(
        email: email,
        password: password,
        rememberMe: rememberMe,
      );

      state = state.copyWith(
        user: result['user'] as UserModel,
        isAuthenticated: true,
        isLoading: false,
        error: null,
      );
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error inesperado: ${e.toString()}',
      );
      return false;
    }
  }

  /// Logout
  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    try {
      await AuthService.logout();
      state = AuthState();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Limpiar error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provider global del notifier de autenticación
final authNotifierProvider = Provider<AuthNotifier>((ref) {
  final notifier = AuthNotifier();
  ref.onDispose(() => notifier.dispose());
  return notifier;
});

/// Provider global de autenticación (estado)
/// El router escucha este provider para hacer redirects
/// 
/// Nota: En Riverpod 3.0, cuando usas StateNotifier del paquete state_notifier,
/// el provider no se actualiza automáticamente cuando el estado interno cambia.
/// Para solucionarlo, los widgets deben observar directamente el notifier
/// usando ref.watch(authNotifierProvider).currentState
/// 
/// Sin embargo, para mantener compatibilidad con el router que observa este provider,
/// este provider retorna el estado actual del notifier.
/// Los cambios se detectarán cuando los widgets que observan este provider se reconstruyan.
final authProvider = Provider<AuthState>((ref) {
  final notifier = ref.watch(authNotifierProvider);
  return notifier.currentState;
});

