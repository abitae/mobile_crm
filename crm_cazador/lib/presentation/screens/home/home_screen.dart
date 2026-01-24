import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../projects/projects_list_screen.dart';
import '../clients/clients_list_screen.dart';
import '../reservations/reservations_list_screen.dart';
import '../dateros/dateros_list_screen.dart';
import '../../utils/animation_utils.dart';
import '../../providers/client_provider.dart';
import '../../providers/datero_provider.dart';
import '../../providers/project_provider.dart';
import '../../providers/reservation_provider.dart';
import '../../providers/dashboard_provider.dart';

/// Pantalla principal (Home) con Material 3 y NavigationBar
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
    _animationController = AnimationController(
      vsync: this,
      duration: AnimationUtils.defaultDuration,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    // Iniciar la animación inmediatamente para que el contenido sea visible
    _animationController.forward();
    // Cargar datos iniciales del dashboard
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshDataForIndex(0);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LER Cazador'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              context.push('/settings');
            },
            tooltip: 'Configuración',
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
          _animationController.forward(from: 0.0);
          _refreshDataForIndex(index);
        },
        children: [
          FadeTransition(
            opacity: _animation,
            child: _buildHomeContent(),
          ),
          const ClientsListScreen(),
          const DaterosListScreen(),
          const ProjectsListScreen(),
          const ReservationsListScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
          _pageController.animateToPage(
            index,
            duration: AnimationUtils.defaultDuration,
            curve: Curves.easeOut,
          );
          _animationController.forward(from: 0.0);
          _refreshDataForIndex(index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outlined),
            selectedIcon: Icon(Icons.people),
            label: 'Clientes',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_search_outlined),
            selectedIcon: Icon(Icons.person_search),
            label: 'Dateros',
          ),
          NavigationDestination(
            icon: Icon(Icons.business_outlined),
            selectedIcon: Icon(Icons.business),
            label: 'Proyectos',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Reservas',
          ),
        ],
      ),
    );
  }

  /// Refresca los datos según el índice de la pantalla seleccionada
  void _refreshDataForIndex(int index) {
    switch (index) {
      case 0:
        // Home - Usar endpoint unificado de dashboard
        ref.read(dashboardNotifierProvider).refresh();
        break;
      case 1:
        // Clientes
        ref.read(clientsNotifierProvider).loadClients(refresh: true);
        break;
      case 2:
        // Dateros
        ref.read(daterosNotifierProvider).loadDateros(refresh: true);
        break;
      case 3:
        // Proyectos
        ref.read(projectsNotifierProvider).loadProjects(refresh: true);
        break;
      case 4:
        // Reservas
        ref.read(reservationsNotifierProvider).loadReservations(refresh: true);
        break;
    }
  }

  Widget _buildHomeContent() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Dashboard de estadísticas
            _DashboardWidget(),
          ],
        ),
      ),
    );
  }
}

class _DashboardWidget extends ConsumerWidget {
  const _DashboardWidget();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final dashboardState = ref.watch(dashboardProvider);

    // Si hay error, mostrar mensaje
    if (dashboardState.error != null && dashboardState.stats == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumen',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Error al cargar estadísticas: ${dashboardState.error}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.error,
                ),
              ),
            ),
          ),
        ],
      );
    }

    final stats = dashboardState.stats;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Resumen',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (dashboardState.isLoading)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Column(
          children: [
            _DashboardCard(
              title: 'Clientes',
              value: stats?.clients.total.toString() ?? '0',
              iconPath: 'assets/images/icon_clients.svg',
              color: colorScheme.primary,
              isLoading: dashboardState.isLoading && stats == null,
            ),
            const SizedBox(height: 12),
            _DashboardCard(
              title: 'Dateros',
              value: stats?.dateros.total.toString() ?? '0',
              iconPath: 'assets/images/icon_dateros.svg',
              color: colorScheme.secondary,
              isLoading: dashboardState.isLoading && stats == null,
            ),
            const SizedBox(height: 12),
            _DashboardCard(
              title: 'Proyectos',
              value: stats?.projects.total.toString() ?? '0',
              iconPath: 'assets/images/icon_projects.svg',
              color: colorScheme.tertiary,
              isLoading: dashboardState.isLoading && stats == null,
            ),
            const SizedBox(height: 12),
            _DashboardCard(
              title: 'Reservas',
              value: stats?.reservations.total.toString() ?? '0',
              iconPath: 'assets/images/icon_reservations.svg',
              color: colorScheme.error,
              isLoading: dashboardState.isLoading && stats == null,
            ),
          ],
        ),
      ],
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final String iconPath;
  final Color color;
  final bool isLoading;

  const _DashboardCard({
    required this.title,
    required this.value,
    required this.iconPath,
    required this.color,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.1),
              color.withOpacity(0.05),
            ],
          ),
        ),
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: SvgPicture.asset(
                iconPath,
                width: 32,
                height: 32,
                colorFilter: ColorFilter.mode(
                  color,
                  BlendMode.srcIn,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    value,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (isLoading)
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
          ],
        ),
      ),
    );
  }

}
