import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:state_notifier/state_notifier.dart';
import '../../../data/services/profile_service.dart';
import '../../../data/models/user_model.dart';
import '../../../core/exceptions/api_exception.dart';

/// Estado del perfil
class ProfileState {
  final UserModel? profile;
  final bool isLoading;
  final String? error;

  ProfileState({
    this.profile,
    this.isLoading = false,
    this.error,
  });

  ProfileState copyWith({
    UserModel? profile,
    bool? isLoading,
    String? error,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Provider de perfil
class ProfileNotifier extends StateNotifier<ProfileState> {
  ProfileNotifier() : super(ProfileState()) {
    loadProfile();
  }

  ProfileState get currentState => state;

  /// Cargar perfil
  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final profile = await ProfileService.getProfile();
      state = state.copyWith(
        profile: profile,
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

  /// Actualizar perfil
  Future<bool> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? banco,
    String? cuentaBancaria,
    String? cciBancaria,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final updatedProfile = await ProfileService.updateProfile(
        name: name,
        email: email,
        phone: phone,
        banco: banco,
        cuentaBancaria: cuentaBancaria,
        cciBancaria: cciBancaria,
      );
      state = state.copyWith(
        profile: updatedProfile,
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

  /// Limpiar error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provider global del notifier de perfil
final profileNotifierProvider = Provider<ProfileNotifier>((ref) {
  final notifier = ProfileNotifier();
  ref.onDispose(() => notifier.dispose());
  return notifier;
});

/// Provider global de perfil (estado)
final profileProvider = Provider<ProfileState>((ref) {
  final notifier = ref.watch(profileNotifierProvider);
  return notifier.currentState;
});

