import 'package:go_router/go_router.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/splash_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/projects/projects_list_screen.dart';
import '../../presentation/screens/projects/project_detail_screen.dart';
import '../../presentation/screens/projects/project_units_screen.dart';
import '../../presentation/screens/clients/clients_list_screen.dart';
import '../../presentation/screens/clients/client_detail_screen.dart';
import '../../presentation/screens/clients/client_form_screen.dart';
import '../../presentation/screens/settings/settings_screen.dart';
import '../../presentation/screens/settings/api_config_screen.dart';
import '../../presentation/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Configuración de rutas de la aplicación
final routesProvider = Provider<GoRouter>((ref) {
  final authNotifier = ref.watch(authNotifierProvider);
  ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final isAuthenticated = authNotifier.currentState.isAuthenticated;
      final isLogin = state.matchedLocation == '/login';
      final isSplash = state.matchedLocation == '/splash';

      if (isSplash) return null;

      if (!isAuthenticated && !isLogin) {
        return '/login';
      }

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
        path: '/projects',
        name: 'projects',
        builder: (context, state) => const ProjectsListScreen(),
      ),
      GoRoute(
        path: '/projects/:id',
        name: 'project-detail',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return ProjectDetailScreen(projectId: id);
        },
      ),
      GoRoute(
        path: '/projects/:id/units',
        name: 'project-units',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return ProjectUnitsScreen(projectId: id);
        },
      ),
      GoRoute(
        path: '/clients',
        name: 'clients',
        builder: (context, state) => const ClientsListScreen(),
      ),
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
    ],
  );
});

