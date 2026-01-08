import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/project_provider.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/skeletons/project_list_skeleton.dart';
import '../../widgets/animations/stagger_animation.dart';
import '../../widgets/projects/project_card.dart';

/// Pantalla de listado de proyectos
class ProjectsListScreen extends ConsumerStatefulWidget {
  const ProjectsListScreen({super.key});

  @override
  ConsumerState<ProjectsListScreen> createState() => _ProjectsListScreenState();
}

class _ProjectsListScreenState extends ConsumerState<ProjectsListScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      ref.read(projectsNotifierProvider).loadMoreProjects();
    }
  }

  void _handleSearch(String query) {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_searchController.text == query) {
        ref.read(projectsNotifierProvider).setSearch(
              query.isEmpty ? null : query,
            );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final projectsState = ref.watch(projectsNotifierProvider).currentState;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Proyectos'),
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
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar proyectos',
                hintText: 'Nombre, dirección, distrito...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(projectsNotifierProvider).setSearch(null);
                        },
                      )
                    : null,
                filled: true,
              ),
              onChanged: _handleSearch,
            ),
          ),
          // Active filters chips
          if (_hasActiveFilters(projectsState))
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Wrap(
                spacing: 8,
                children: [
                  if (projectsState.projectTypeFilter != null)
                    FilterChip(
                      label: Text(_getProjectTypeLabel(projectsState.projectTypeFilter!)),
                      onSelected: (_) {
                        ref.read(projectsNotifierProvider).setFilters(
                              projectType: null,
                            );
                      },
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () {
                        ref.read(projectsNotifierProvider).setFilters(
                              projectType: null,
                            );
                      },
                    ),
                  if (projectsState.statusFilter != null)
                    FilterChip(
                      label: Text(_getStatusLabel(projectsState.statusFilter!)),
                      onSelected: (_) {
                        ref.read(projectsNotifierProvider).setFilters(
                              status: null,
                            );
                      },
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () {
                        ref.read(projectsNotifierProvider).setFilters(
                              status: null,
                            );
                      },
                    ),
                  if (projectsState.hasAvailableUnitsFilter == true)
                    FilterChip(
                      label: const Text('Solo con unidades disponibles'),
                      onSelected: (_) {
                        ref.read(projectsNotifierProvider).setFilters(
                              hasAvailableUnits: null,
                            );
                      },
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () {
                        ref.read(projectsNotifierProvider).setFilters(
                              hasAvailableUnits: null,
                            );
                      },
                    ),
                ],
              ),
            ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await ref.read(projectsNotifierProvider).loadProjects(
                      refresh: true,
                    );
              },
              child: _buildBody(projectsState),
            ),
          ),
        ],
      ),
    );
  }

  bool _hasActiveFilters(ProjectsState state) {
    return state.projectTypeFilter != null ||
        state.loteTypeFilter != null ||
        state.stageFilter != null ||
        state.legalStatusFilter != null ||
        state.statusFilter != null ||
        state.districtFilter != null ||
        state.provinceFilter != null ||
        state.regionFilter != null ||
        state.hasAvailableUnitsFilter == true;
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
                ref.read(projectsNotifierProvider).clearFilters();
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

  String _getProjectTypeLabel(String type) {
    final labels = {
      'lotes': 'Lotes',
      'casas': 'Casas',
      'departamentos': 'Departamentos',
      'oficinas': 'Oficinas',
      'mixto': 'Mixto',
    };
    return labels[type.toLowerCase()] ?? type;
  }

  String _getStatusLabel(String status) {
    final labels = {
      'activo': 'Activo',
      'inactivo': 'Inactivo',
      'suspendido': 'Suspendido',
      'finalizado': 'Finalizado',
    };
    return labels[status.toLowerCase()] ?? status;
  }

  Widget _buildBody(ProjectsState state) {
    if (state.isLoading && state.projects.isEmpty) {
      return const ProjectListSkeleton();
    }

    if (state.error != null && state.projects.isEmpty) {
      return AppErrorWidget(
        message: state.error!,
        onRetry: () {
          ref.read(projectsNotifierProvider).loadProjects(refresh: true);
        },
      );
    }

    if (state.projects.isEmpty) {
      return EmptyState(
        icon: Icons.business_outlined,
        title: 'No hay proyectos',
        message: 'No se encontraron proyectos con los filtros aplicados',
        action: () {
          ref.read(projectsNotifierProvider).clearFilters();
        },
        actionLabel: 'Limpiar filtros',
      );
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: state.projects.length + (state.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= state.projects.length) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final project = state.projects[index];
        return StaggerAnimation(
          index: index,
          child: ProjectCard(
            project: project,
            onTap: () {
              context.push('/projects/${project.id}');
            },
          ),
        );
      },
    );
  }
}

