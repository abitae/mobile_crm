import 'package:go_router/go_router.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/splash_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/clients/clients_list_screen.dart';
import '../../presentation/screens/clients/client_detail_screen.dart';
import '../../presentation/screens/clients/client_form_screen.dart';
import '../../presentation/screens/settings/settings_screen.dart';
import '../../presentation/screens/settings/api_config_screen.dart';
import '../../presentation/screens/settings/change_pin_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';
import '../../presentation/screens/profile/datero_qr_screen.dart';
import '../../presentation/screens/commissions/commissions_list_screen.dart';
import '../../presentation/screens/commissions/commission_detail_screen.dart';
import '../../presentation/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Configuración de rutas de la aplicación
final routesProvider = Provider<GoRouter>((ref) {
  // Observar el notifier para asegurar que el router se actualice cuando el estado cambie
  final authNotifier = ref.watch(authNotifierProvider);
  // Observar también el provider para mantener compatibilidad
  ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      // Usar el estado del notifier directamente para obtener siempre el estado más reciente
      final isAuthenticated = authNotifier.currentState.isAuthenticated;
      final isLogin = state.matchedLocation == '/login';
      final isSplash = state.matchedLocation == '/splash';

      // Si está en splash, no redirigir
      if (isSplash) return null;

      // Si no está autenticado y no está en login, redirigir a login
      if (!isAuthenticated && !isLogin) {
        return '/login';
      }

      // Si está autenticado y está en login, redirigir a home
      if (isAuthenticated && isLogin) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/clients',
        name: 'clients',
        builder: (context, state) => const ClientsListScreen(),
      ),
      // Las rutas estáticas específicas deben ir ANTES de las rutas con parámetros
      GoRoute(
        path: '/clients/new',
        name: 'client-new',
        builder: (context, state) => const ClientFormScreen(),
      ),
      GoRoute(
        path: '/clients/:id/edit',
        name: 'client-edit',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return ClientFormScreen(clientId: id);
        },
      ),
      // La ruta genérica con parámetro debe ir al final
      GoRoute(
        path: '/clients/:id',
        name: 'client-detail',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return ClientDetailScreen(clientId: id);
        },
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/settings/api',
        name: 'api-config',
        builder: (context, state) => const ApiConfigScreen(),
      ),
      GoRoute(
        path: '/settings/change-pin',
        name: 'change-pin',
        builder: (context, state) => const ChangePinScreen(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/profile/qr',
        name: 'profile-qr',
        builder: (context, state) => const DateroQrScreen(),
      ),
      GoRoute(
        path: '/commissions',
        name: 'commissions',
        builder: (context, state) => const CommissionsListScreen(),
      ),
      GoRoute(
        path: '/commissions/:id',
        name: 'commission-detail',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return CommissionDetailScreen(commissionId: id);
        },
      ),
    ],
  );
});

