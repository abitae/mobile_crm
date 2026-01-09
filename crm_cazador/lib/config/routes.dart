import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/splash_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/projects/projects_list_screen.dart';
import '../../presentation/screens/projects/project_detail_screen.dart';
import '../../presentation/screens/projects/project_units_screen.dart';
import '../../presentation/screens/projects/project_select_screen.dart';
import '../../presentation/screens/clients/clients_list_screen.dart';
import '../../presentation/screens/clients/client_detail_screen.dart';
import '../../presentation/screens/clients/client_form_screen.dart';
import '../../presentation/screens/clients/client_select_screen.dart';
import '../../presentation/screens/reservations/reservations_list_screen.dart';
import '../../presentation/screens/reservations/reservation_detail_screen.dart';
import '../../presentation/screens/reservations/reservation_form_screen.dart';
import '../../presentation/screens/reservations/reservation_confirm_screen.dart';
import '../../presentation/screens/settings/settings_screen.dart';
import '../../presentation/screens/settings/api_config_screen.dart';
import '../../presentation/screens/settings/change_password_screen.dart';
import '../../presentation/screens/dateros/dateros_list_screen.dart';
import '../../presentation/screens/dateros/datero_detail_screen.dart';
import '../../presentation/screens/dateros/datero_form_screen.dart';
import '../../presentation/providers/auth_provider.dart';
import '../../presentation/utils/animation_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Configuración de rutas de la aplicación
final routesProvider = Provider<GoRouter>((ref) {
  // Observar el estado de autenticación sin bloquear
  ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      try {
        final authNotifier = ref.read(authNotifierProvider);
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
      } catch (e) {
        // Si hay un error, permitir navegación a splash o login
        print('Error en redirect: $e');
        final isSplash = state.matchedLocation == '/splash';
        final isLogin = state.matchedLocation == '/login';
        if (isSplash || isLogin) return null;
        return '/splash';
      }
    },
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        pageBuilder: (context, state) => _buildPageWithTransition(
          const SplashScreen(),
          state,
          transitionType: TransitionType.fade,
        ),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        pageBuilder: (context, state) => _buildPageWithTransition(
          const LoginScreen(),
          state,
          transitionType: TransitionType.fade,
        ),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        pageBuilder: (context, state) => _buildPageWithTransition(
          const HomeScreen(),
          state,
          transitionType: TransitionType.fade,
        ),
      ),
      GoRoute(
        path: '/projects',
        name: 'projects',
        pageBuilder: (context, state) => _buildPageWithTransition(
          const ProjectsListScreen(),
          state,
          transitionType: TransitionType.slideRight,
        ),
      ),
      // Rutas estáticas deben ir ANTES de las rutas con parámetros
      GoRoute(
        path: '/projects/select',
        name: 'project-select',
        pageBuilder: (context, state) => _buildPageWithTransition(
          const ProjectSelectScreen(),
          state,
          transitionType: TransitionType.slideUp,
        ),
      ),
      GoRoute(
        path: '/projects/:id/units',
        name: 'project-units',
        pageBuilder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return _buildPageWithTransition(
            ProjectUnitsScreen(projectId: id),
            state,
            transitionType: TransitionType.slideRight,
          );
        },
      ),
      GoRoute(
        path: '/projects/:id',
        name: 'project-detail',
        pageBuilder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return _buildPageWithTransition(
            ProjectDetailScreen(projectId: id),
            state,
            transitionType: TransitionType.fade,
          );
        },
      ),
      GoRoute(
        path: '/clients',
        name: 'clients',
        pageBuilder: (context, state) => _buildPageWithTransition(
          const ClientsListScreen(),
          state,
          transitionType: TransitionType.slideRight,
        ),
      ),
      // Rutas estáticas deben ir ANTES de las rutas con parámetros
      GoRoute(
        path: '/clients/new',
        name: 'client-new',
        pageBuilder: (context, state) => _buildPageWithTransition(
          const ClientFormScreen(),
          state,
          transitionType: TransitionType.slideUp,
        ),
      ),
      GoRoute(
        path: '/clients/select',
        name: 'client-select',
        pageBuilder: (context, state) => _buildPageWithTransition(
          const ClientSelectScreen(),
          state,
          transitionType: TransitionType.slideUp,
        ),
      ),
      GoRoute(
        path: '/clients/:id/edit',
        name: 'client-edit',
        pageBuilder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return _buildPageWithTransition(
            ClientFormScreen(clientId: id),
            state,
            transitionType: TransitionType.slideUp,
          );
        },
      ),
      GoRoute(
        path: '/clients/:id',
        name: 'client-detail',
        pageBuilder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return _buildPageWithTransition(
            ClientDetailScreen(clientId: id),
            state,
            transitionType: TransitionType.fade,
          );
        },
      ),
      GoRoute(
        path: '/reservations',
        name: 'reservations',
        pageBuilder: (context, state) => _buildPageWithTransition(
          const ReservationsListScreen(),
          state,
          transitionType: TransitionType.slideRight,
        ),
      ),
      GoRoute(
        path: '/reservations/new',
        name: 'reservation-new',
        pageBuilder: (context, state) => _buildPageWithTransition(
          const ReservationFormScreen(),
          state,
          transitionType: TransitionType.slideUp,
        ),
      ),
      GoRoute(
        path: '/reservations/:id',
        name: 'reservation-detail',
        pageBuilder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return _buildPageWithTransition(
            ReservationDetailScreen(reservationId: id),
            state,
            transitionType: TransitionType.fade,
          );
        },
      ),
      GoRoute(
        path: '/reservations/:id/edit',
        name: 'reservation-edit',
        pageBuilder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return _buildPageWithTransition(
            ReservationFormScreen(reservationId: id),
            state,
            transitionType: TransitionType.slideUp,
          );
        },
      ),
      GoRoute(
        path: '/reservations/:id/confirm',
        name: 'reservation-confirm',
        pageBuilder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return _buildPageWithTransition(
            ReservationConfirmScreen(reservationId: id),
            state,
            transitionType: TransitionType.scale,
          );
        },
      ),
      GoRoute(
        path: '/dateros',
        name: 'dateros',
        pageBuilder: (context, state) => _buildPageWithTransition(
          const DaterosListScreen(),
          state,
          transitionType: TransitionType.slideRight,
        ),
      ),
      GoRoute(
        path: '/dateros/new',
        name: 'datero-new',
        pageBuilder: (context, state) => _buildPageWithTransition(
          const DateroFormScreen(),
          state,
          transitionType: TransitionType.slideUp,
        ),
      ),
      GoRoute(
        path: '/dateros/:id/edit',
        name: 'datero-edit',
        pageBuilder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return _buildPageWithTransition(
            DateroFormScreen(dateroId: id),
            state,
            transitionType: TransitionType.slideUp,
          );
        },
      ),
      GoRoute(
        path: '/dateros/:id',
        name: 'datero-detail',
        pageBuilder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return _buildPageWithTransition(
            DateroDetailScreen(dateroId: id),
            state,
            transitionType: TransitionType.fade,
          );
        },
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        pageBuilder: (context, state) => _buildPageWithTransition(
          const SettingsScreen(),
          state,
          transitionType: TransitionType.slideRight,
        ),
      ),
      GoRoute(
        path: '/settings/api',
        name: 'api-config',
        pageBuilder: (context, state) => _buildPageWithTransition(
          const ApiConfigScreen(),
          state,
          transitionType: TransitionType.slideRight,
        ),
      ),
      GoRoute(
        path: '/settings/change-password',
        name: 'change-password',
        pageBuilder: (context, state) => _buildPageWithTransition(
          const ChangePasswordScreen(),
          state,
          transitionType: TransitionType.slideRight,
        ),
      ),
    ],
  );
});

enum TransitionType {
  fade,
  slideRight,
  slideUp,
  scale,
}

/// Construir página con transición personalizada
CustomTransitionPage _buildPageWithTransition(
  Widget child,
  GoRouterState state, {
  TransitionType transitionType = TransitionType.fade,
}) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionType: transitionType,
  );
}

/// Página personalizada con transiciones
class CustomTransitionPage extends Page<void> {
  final Widget child;
  final TransitionType transitionType;

  CustomTransitionPage({
    required this.child,
    super.key,
    required this.transitionType,
  });

  @override
  Route<void> createRoute(BuildContext context) {
    return PageRouteBuilder(
      settings: this,
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionDuration: AnimationUtils.defaultDuration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        switch (transitionType) {
          case TransitionType.fade:
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          case TransitionType.slideRight:
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            final tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: Curves.easeInOut),
            );
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          case TransitionType.slideUp:
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            final tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: Curves.easeOut),
            );
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          case TransitionType.scale:
            return ScaleTransition(
              scale: Tween<double>(
                begin: 0.0,
                end: 1.0,
              ).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: Curves.fastOutSlowIn,
                ),
              ),
              child: child,
            );
        }
      },
    );
  }
}
