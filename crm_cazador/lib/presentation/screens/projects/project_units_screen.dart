import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/project_provider.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/projects/unit_card.dart';

/// Pantalla de unidades de un proyecto
class ProjectUnitsScreen extends ConsumerStatefulWidget {
  final int projectId;

  const ProjectUnitsScreen({
    super.key,
    required this.projectId,
  });

  @override
  ConsumerState<ProjectUnitsScreen> createState() => _ProjectUnitsScreenState();
}

class _ProjectUnitsScreenState extends ConsumerState<ProjectUnitsScreen> {
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
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      ref.read(projectUnitsNotifierProvider(widget.projectId)).loadMoreUnits();
    }
  }

  @override
  Widget build(BuildContext context) {
    final unitsState = ref.watch(projectUnitsProvider(widget.projectId));
    final projectAsync = ref.watch(projectProvider(widget.projectId));

    return Scaffold(
      appBar: AppBar(
        title: projectAsync.when(
          data: (project) => Text('Unidades - ${project.name}'),
          loading: () => const Text('Unidades'),
          error: (_, __) => const Text('Unidades'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_outlined),
            onPressed: () {
              _showFilterBottomSheet(context);
            },
            tooltip: 'Filtros',
          ),
        ],
      ),
      body: Column(
        children: [
          // Active filters chips
          if (_hasActiveFilters(unitsState))
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: Wrap(
                spacing: 8,
                children: [
                  if (unitsState.statusFilter != null)
                    FilterChip(
                      label: Text(_getStatusLabel(unitsState.statusFilter!)),
                      onSelected: (_) {
                        ref.read(projectUnitsNotifierProvider(widget.projectId)).setFilters(
                              status: null,
                            );
                      },
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () {
                        ref.read(projectUnitsNotifierProvider(widget.projectId)).setFilters(
                              status: null,
                            );
                      },
                    ),
                  if (unitsState.onlyAvailableFilter == true)
                    FilterChip(
                      label: const Text('Solo disponibles'),
                      onSelected: (_) {
                        ref.read(projectUnitsNotifierProvider(widget.projectId)).setFilters(
                              onlyAvailable: null,
                            );
                      },
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () {
                        ref.read(projectUnitsNotifierProvider(widget.projectId)).setFilters(
                              onlyAvailable: null,
                            );
                      },
                    ),
                ],
              ),
            ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await ref.read(projectUnitsNotifierProvider(widget.projectId)).loadUnits(
                      refresh: true,
                    );
              },
              child: _buildBody(unitsState),
            ),
          ),
        ],
      ),
    );
  }

  bool _hasActiveFilters(ProjectUnitsState state) {
    return state.statusFilter != null ||
        state.unitTypeFilter != null ||
        state.minPriceFilter != null ||
        state.maxPriceFilter != null ||
        state.minAreaFilter != null ||
        state.maxAreaFilter != null ||
        state.bedroomsFilter != null ||
        state.onlyAvailableFilter == true;
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filtros',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            // TODO: Implementar filtros con SegmentedButton o Dropdown
            const Text('Filtros próximamente disponibles'),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () {
                ref.read(projectUnitsNotifierProvider(widget.projectId)).clearFilters();
                Navigator.pop(context);
              },
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text('Limpiar filtros'),
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusLabel(String status) {
    final labels = {
      'disponible': 'Disponible',
      'reservado': 'Reservado',
      'vendido': 'Vendido',
      'bloqueado': 'Bloqueado',
    };
    return labels[status.toLowerCase()] ?? status;
  }

  Widget _buildBody(ProjectUnitsState state) {
    if (state.isLoading && state.units.isEmpty) {
      return const LoadingIndicator();
    }

    if (state.error != null && state.units.isEmpty) {
      return AppErrorWidget(
        message: state.error!,
        onRetry: () {
          ref.read(projectUnitsNotifierProvider(widget.projectId)).loadUnits(refresh: true);
        },
      );
    }

    if (state.units.isEmpty) {
      return EmptyState(
        icon: Icons.home_outlined,
        title: 'No hay unidades',
        message: 'No se encontraron unidades con los filtros aplicados',
        action: () {
          ref.read(projectUnitsNotifierProvider(widget.projectId)).clearFilters();
        },
        actionLabel: 'Limpiar filtros',
      );
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: state.units.length + (state.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= state.units.length) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final unit = state.units[index];
        return UnitCard(
          unit: unit,
          onTap: () {
            // TODO: Navegar a detalle de unidad si se implementa
          },
        );
      },
    );
  }
}

