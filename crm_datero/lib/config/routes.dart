import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
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
import '../../presentation/utils/animation_utils.dart';

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
        path: '/clients',
        name: 'clients',
        pageBuilder: (context, state) => _buildPageWithTransition(
          const ClientsListScreen(),
          state,
          transitionType: TransitionType.slideRight,
        ),
      ),
      // Las rutas estáticas específicas deben ir ANTES de las rutas con parámetros
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
      // La ruta genérica con parámetro debe ir al final
      GoRoute(
        path: '/clients/:id',
        name: 'client-detail',
        pageBuilder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return _buildPageWithTransition(
            ClientDetailScreen(clientId: id),
            state,
            transitionType: TransitionType.slideRight,
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
        path: '/settings/change-pin',
        name: 'change-pin',
        pageBuilder: (context, state) => _buildPageWithTransition(
          const ChangePinScreen(),
          state,
          transitionType: TransitionType.slideRight,
        ),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        pageBuilder: (context, state) => _buildPageWithTransition(
          const ProfileScreen(),
          state,
          transitionType: TransitionType.slideRight,
        ),
      ),
      GoRoute(
        path: '/profile/qr',
        name: 'profile-qr',
        pageBuilder: (context, state) => _buildPageWithTransition(
          const DateroQrScreen(),
          state,
          transitionType: TransitionType.scale,
        ),
      ),
      GoRoute(
        path: '/commissions',
        name: 'commissions',
        pageBuilder: (context, state) => _buildPageWithTransition(
          const CommissionsListScreen(),
          state,
          transitionType: TransitionType.slideRight,
        ),
      ),
      GoRoute(
        path: '/commissions/:id',
        name: 'commission-detail',
        pageBuilder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return _buildPageWithTransition(
            CommissionDetailScreen(commissionId: id),
            state,
            transitionType: TransitionType.slideRight,
          );
        },
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
