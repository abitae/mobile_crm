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
      // Verificar si hay token almacenado
      final isAuth = await AuthService.isAuthenticated();
      if (isAuth) {
        try {
          // Intentar obtener el usuario actual
          final user = await AuthService.getCurrentUser();
          if (user != null) {
            state = state.copyWith(
              user: user,
              isAuthenticated: true,
              isLoading: false,
            );
          } else {
            // Si no se puede obtener el usuario, limpiar tokens y marcar como no autenticado
            await AuthService.logout();
            state = state.copyWith(
              isAuthenticated: false,
              isLoading: false,
            );
          }
        } catch (e) {
          // Si falla al obtener el usuario (API no disponible, token inválido, etc.)
          // Limpiar tokens y marcar como no autenticado
          print('Error al obtener usuario: $e');
          try {
            await AuthService.logout();
          } catch (_) {
            // Ignorar errores al hacer logout
          }
          state = state.copyWith(
            isAuthenticated: false,
            isLoading: false,
            error: null, // No mostrar error al usuario en splash
          );
        }
      } else {
        state = state.copyWith(
          isAuthenticated: false,
          isLoading: false,
        );
      }
    } catch (e) {
      // Error general, marcar como no autenticado
      print('Error en _checkAuth: $e');
      state = state.copyWith(
        isAuthenticated: false,
        isLoading: false,
        error: null, // No mostrar error al usuario en splash
      );
    }
  }

  /// Login con DNI y PIN
  Future<bool> login({
    required String dni,
    required String pin,
    bool rememberMe = false,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await AuthService.login(
        dni: dni,
        pin: pin,
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
  try {
    final notifier = AuthNotifier();
    ref.onDispose(() {
      try {
        notifier.dispose();
      } catch (e) {
        print('Error al hacer dispose de AuthNotifier: $e');
      }
    });
    return notifier;
  } catch (e) {
    print('Error al crear AuthNotifier: $e');
    // Retornar un notifier básico en caso de error
    return AuthNotifier();
  }
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

