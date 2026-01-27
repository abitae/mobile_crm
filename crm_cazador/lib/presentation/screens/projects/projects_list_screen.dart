import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    // Listener para actualizar el UI cuando cambia el texto
    _searchController.addListener(() {
      setState(() {}); // Reconstruir para actualizar el suffixIcon
    });
    
    // Escuchar cambios en el estado del notifier
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(projectsNotifierProvider);
      notifier.addListener((state) {
        if (mounted) {
          setState(() {});
        }
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    
    if (currentScroll >= maxScroll * 0.8 && maxScroll > 0) {
      ref.read(projectsNotifierProvider).loadMoreProjects();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Observar el notifier directamente para reactividad completa
    final notifier = ref.watch(projectsNotifierProvider);
    final projectsState = notifier.currentState;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Proyectos'),
      ),
      body: Column(
        children: [
          // Search bar compacto
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar proyectos...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(projectsNotifierProvider).setSearch(null);
                          FocusScope.of(context).unfocus();
                        },
                      )
                    : null,
                filled: true,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) {
                if (value.isEmpty || value.trim().isEmpty) {
                  ref.read(projectsNotifierProvider).setSearch(null);
                }
              },
              onSubmitted: (value) {
                final searchText = value.trim();
                ref.read(projectsNotifierProvider).setSearch(
                      searchText.isEmpty ? null : searchText,
                    );
                FocusScope.of(context).unfocus();
              },
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

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 0.1),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
            )),
            child: child,
          ),
        );
      },
      child: ListView.builder(
        key: ValueKey('projects_list_${state.search}'),
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: state.projects.length + (state.isLoadingMore ? 1 : 0),
        cacheExtent: 500,
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
              key: ValueKey('project_${project.id}'),
              project: project,
              onTap: () {
                HapticFeedback.lightImpact();
                context.push('/projects/${project.id}');
              },
            ),
          );
        },
      ),
    );
  }
}

