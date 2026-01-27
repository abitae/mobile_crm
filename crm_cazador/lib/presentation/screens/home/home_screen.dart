import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
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

class _DashboardWidget extends ConsumerStatefulWidget {
  const _DashboardWidget();

  @override
  ConsumerState<_DashboardWidget> createState() => _DashboardWidgetState();
}

class _DashboardWidgetState extends ConsumerState<_DashboardWidget> {
  @override
  void initState() {
    super.initState();
    // Escuchar cambios del estado del notifier
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(dashboardNotifierProvider);
      notifier.addListener((state) {
        if (mounted) {
          setState(() {});
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Observar el notifier directamente para reactividad completa
    final notifier = ref.watch(dashboardNotifierProvider);
    final dashboardState = notifier.currentState;
    
    // Debug: verificar estado
    if (dashboardState.stats != null) {
      debugPrint('📊 [DashboardWidget] Mostrando estadísticas:');
      debugPrint('   - Clientes: ${dashboardState.stats!.clients.total}');
      debugPrint('   - Dateros: ${dashboardState.stats!.dateros.total}');
      debugPrint('   - Reservas: ${dashboardState.stats!.reservations.total}');
    } else {
      debugPrint('⚠️ [DashboardWidget] Stats es null, isLoading: ${dashboardState.isLoading}');
    }

    // Si hay error, mostrar mensaje
    if (dashboardState.error != null && dashboardState.stats == null) {
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
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => ref.read(dashboardNotifierProvider).refresh(),
                tooltip: 'Actualizar',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'Error al cargar estadísticas',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    dashboardState.error ?? 'Error desconocido',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => ref.read(dashboardNotifierProvider).refresh(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    final stats = dashboardState.stats;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.surface,
              colorScheme.surfaceContainerHighest.withOpacity(0.5),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
              spreadRadius: 0,
            ),
          ],
        ),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con título y botón de actualizar mejorado
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.dashboard,
                        color: colorScheme.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Resumen',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    if (dashboardState.isLoading)
                      Container(
                        width: 24,
                        height: 24,
                        padding: const EdgeInsets.all(2),
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                        ),
                      ),
                    if (dashboardState.isLoading) const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.refresh,
                          color: colorScheme.primary,
                        ),
                        onPressed: () => ref.read(dashboardNotifierProvider).refresh(),
                        tooltip: 'Actualizar',
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Estadísticas en grid
            Row(
              children: [
                Expanded(
                  child: _StatItem(
                    title: 'Clientes',
                    value: stats?.clients.total.toString() ?? '0',
                    icon: Icons.people,
                    color: colorScheme.primary,
                    isLoading: dashboardState.isLoading && stats == null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatItem(
                    title: 'Dateros',
                    value: stats?.dateros.total.toString() ?? '0',
                    icon: Icons.person_search,
                    color: colorScheme.secondary,
                    isLoading: dashboardState.isLoading && stats == null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatItem(
                    title: 'Reservas',
                    value: stats?.reservations.total.toString() ?? '0',
                    icon: Icons.receipt_long,
                    color: colorScheme.tertiary,
                    isLoading: dashboardState.isLoading && stats == null,
                  ),
                ),
              ],
            ),
            // Gráfico de estados de reserva
            if (stats?.reservations.byStatus.isNotEmpty == true) ...[
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              _ReservationsStatusChart(
                byStatus: stats!.reservations.byStatus,
                total: stats.reservations.total,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Item de estadística compacto para el card
class _StatItem extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isLoading;

  const _StatItem({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.12),
            color.withOpacity(0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.25),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withOpacity(0.2),
                  color.withOpacity(0.15),
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 28,
              color: color,
            ),
          ),
          const SizedBox(height: 14),
          if (isLoading)
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            )
          else
            Text(
              value,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 28,
                letterSpacing: -0.5,
              ),
            ),
          const SizedBox(height: 6),
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Widget para mostrar gráfico de estados de reserva
class _ReservationsStatusChart extends StatelessWidget {
  final Map<String, int> byStatus;
  final int total;

  const _ReservationsStatusChart({
    required this.byStatus,
    required this.total,
  });

  String _formatStatus(String status) {
    // Formatear nombres de estado para mostrar
    switch (status.toLowerCase()) {
      case 'activa':
      case 'active':
        return 'Activas';
      case 'confirmada':
      case 'confirmed':
        return 'Confirmadas';
      case 'cancelada':
      case 'cancelled':
        return 'Canceladas';
      case 'expirada':
      case 'expired':
        return 'Expiradas';
      case 'convertida':
      case 'converted':
        return 'Convertidas';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (status.toLowerCase()) {
      case 'activa':
      case 'active':
        return colorScheme.primary;
      case 'confirmada':
      case 'confirmed':
        return Colors.green;
      case 'cancelada':
      case 'cancelled':
        return colorScheme.error;
      case 'expirada':
      case 'expired':
        return Colors.orange;
      case 'convertida':
      case 'converted':
        return Colors.blue;
      default:
        return colorScheme.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (byStatus.isEmpty || total == 0) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'No hay datos de reservas disponibles',
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final entries = byStatus.entries.toList();
    final colors = entries.map((e) => _getStatusColor(e.key, context)).toList();
    final labels = entries.map((e) => _formatStatus(e.key)).toList();
    final values = entries.map((e) => e.value.toDouble()).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.pie_chart,
                size: 18,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Reservas por Estado',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 220,
          child: PieChart(
            PieChartData(
              sectionsSpace: 3,
              centerSpaceRadius: 50,
              sections: List.generate(
                entries.length,
                (index) {
                  final percentage = (values[index] / total) * 100;
                  return PieChartSectionData(
                    value: values[index],
                    title: percentage > 5 ? '${percentage.toStringAsFixed(0)}%' : '',
                    color: colors[index],
                    radius: 85,
                    titleStyle: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    badgeWidget: percentage <= 5
                        ? Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: colors[index],
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${percentage.toStringAsFixed(0)}%',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          )
                        : null,
                    badgePositionPercentageOffset: 1.3,
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        // Leyenda mejorada
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: List.generate(
            entries.length,
            (index) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colors[index].withOpacity(0.15),
                    colors[index].withOpacity(0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: colors[index].withOpacity(0.4),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colors[index].withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: colors[index],
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: colors[index].withOpacity(0.5),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${labels[index]}: ${values[index].toInt()}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
