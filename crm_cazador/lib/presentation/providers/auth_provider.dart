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
    // Inicializar de forma asíncrona sin bloquear el constructor
    _checkAuth();
  }

  AuthState get currentState => state;

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

  void clearError() {
    state = state.copyWith(error: null);
  }
}

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

final authProvider = Provider<AuthState>((ref) {
  final notifier = ref.watch(authNotifierProvider);
  return notifier.currentState;
});

