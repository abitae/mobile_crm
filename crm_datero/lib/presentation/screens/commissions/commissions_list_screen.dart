import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/commission_provider.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/skeleton_loader.dart';
import '../../widgets/animations/stagger_animation.dart';
import '../../../data/models/commission_model.dart';
import 'package:intl/intl.dart';

/// Pantalla de listado de comisiones
class CommissionsListScreen extends ConsumerStatefulWidget {
  const CommissionsListScreen({super.key});

  @override
  ConsumerState<CommissionsListScreen> createState() => _CommissionsListScreenState();
}

class _CommissionsListScreenState extends ConsumerState<CommissionsListScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    
    if (currentScroll >= maxScroll * 0.8 && maxScroll > 0) {
      ref.read(commissionNotifierProvider).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final commissionState = ref.watch(commissionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Comisiones'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_outlined),
            onPressed: () {
              _showFilterBottomSheet(context);
            },
            tooltip: 'Filtros',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(commissionNotifierProvider).loadCommissions(refresh: true);
            },
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(commissionNotifierProvider).loadCommissions(refresh: true);
          await ref.read(commissionNotifierProvider).loadStats();
        },
        child: Column(
          children: [
            // Estadísticas
            if (commissionState.stats != null)
              _buildStatsCard(commissionState.stats!),
            // Lista de comisiones
            Expanded(
              child: commissionState.isLoading && commissionState.commissions.isEmpty
                  ? const LoadingIndicator(
                      useSkeleton: true,
                      skeletonType: SkeletonType.commissionCard,
                      itemCount: 5,
                    )
                  : commissionState.error != null && commissionState.commissions.isEmpty
                      ? AppErrorWidget(
                          message: commissionState.error!,
                          onRetry: () {
                            ref.read(commissionNotifierProvider).loadCommissions(refresh: true);
                          },
                        )
                      : commissionState.commissions.isEmpty
                          ? const EmptyState(
                              title: 'Sin comisiones',
                              message: 'No tienes comisiones registradas',
                              icon: Icons.payments_outlined,
                            )
                          : ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.all(16.0),
                              itemCount: commissionState.commissions.length +
                                  (commissionState.isLoadingMore ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index >= commissionState.commissions.length) {
                                  return const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                }
                                final commission = commissionState.commissions[index];
                                return StaggerAnimation(
                                  index: index,
                                  child: _buildCommissionCard(commission),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(stats) {
    final formatter = NumberFormat.currency(symbol: 'S/ ', decimalDigits: 2);
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumen',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Total Pagado',
                    formatter.format(stats.totalPagado),
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Pendiente',
                    formatter.format(stats.totalPendiente),
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Este Mes',
                    formatter.format(stats.totalMesActual),
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Este Año',
                    formatter.format(stats.totalAnioActual),
                    Colors.purple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommissionCard(CommissionModel commission) {
    final formatter = NumberFormat.currency(symbol: 'S/ ', decimalDigits: 2);
    final dateFormatter = DateFormat('dd/MM/yyyy');
    final theme = Theme.of(context);

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            context.push('/commissions/${commission.id}');
          },
          borderRadius: BorderRadius.circular(16),
          splashColor: theme.colorScheme.primary.withOpacity(0.1),
          highlightColor: theme.colorScheme.primary.withOpacity(0.05),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (commission.project != null)
                          Text(
                            commission.project!.name,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        if (commission.unit != null)
                          Text(
                            'Unidad: ${commission.unit!.unitNumber}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                      ],
                    ),
                  ),
                  _buildStatusChip(commission.status),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Comisión',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        formatter.format(commission.totalCommission),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Fecha',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        dateFormatter.format(commission.createdAt),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;

    switch (status.toLowerCase()) {
      case 'pendiente':
        color = Colors.orange;
        label = 'Pendiente';
        break;
      case 'aprobada':
        color = Colors.blue;
        label = 'Aprobada';
        break;
      case 'pagada':
        color = Colors.green;
        label = 'Pagada';
        break;
      case 'cancelada':
        color = Colors.red;
        label = 'Cancelada';
        break;
      default:
        color = Colors.grey;
        label = status;
    }

    return Chip(
      label: Text(label),
      backgroundColor: color.withOpacity(0.1),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.bold),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _FilterBottomSheet(),
    );
  }
}

class _FilterBottomSheet extends ConsumerStatefulWidget {
  @override
  ConsumerState<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends ConsumerState<_FilterBottomSheet> {
  String? _selectedStatus;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filtrar por Estado',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: [
              _buildFilterChip('pendiente', 'Pendiente'),
              _buildFilterChip('aprobada', 'Aprobada'),
              _buildFilterChip('pagada', 'Pagada'),
              _buildFilterChip('cancelada', 'Cancelada'),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedStatus = null;
                  });
                  ref.read(commissionNotifierProvider).loadCommissions(
                        refresh: true,
                        status: null,
                      );
                  Navigator.pop(context);
                },
                child: const Text('Limpiar'),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () {
                  ref.read(commissionNotifierProvider).loadCommissions(
                        refresh: true,
                        status: _selectedStatus,
                      );
                  Navigator.pop(context);
                },
                child: const Text('Aplicar'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _selectedStatus == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedStatus = selected ? value : null;
        });
      },
    );
  }
}

