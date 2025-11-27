import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/project_provider.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/projects/project_card.dart';

/// Pantalla de selección de proyecto (para usar en formularios)
class ProjectSelectScreen extends ConsumerStatefulWidget {
  const ProjectSelectScreen({super.key});

  @override
  ConsumerState<ProjectSelectScreen> createState() => _ProjectSelectScreenState();
}

class _ProjectSelectScreenState extends ConsumerState<ProjectSelectScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Cargar proyectos al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(projectsNotifierProvider).loadProjects();
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
        title: const Text('Seleccionar Proyecto'),
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
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await ref.read(projectsNotifierProvider).loadProjects(refresh: true);
              },
              child: _buildBody(projectsState),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(ProjectsState projectsState) {
    if (projectsState.isLoading && projectsState.projects.isEmpty) {
      return const LoadingIndicator();
    }

    if (projectsState.error != null && projectsState.projects.isEmpty) {
      return AppErrorWidget(
        message: projectsState.error!,
        onRetry: () {
          ref.read(projectsNotifierProvider).loadProjects(refresh: true);
        },
      );
    }

    if (projectsState.projects.isEmpty) {
      return EmptyState(
        icon: Icons.business_outlined,
        title: 'No hay proyectos',
        message: 'No se encontraron proyectos disponibles',
      );
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: projectsState.projects.length + (projectsState.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= projectsState.projects.length) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final project = projectsState.projects[index];
        return ProjectCard(
          project: project,
          onTap: () {
            // Retornar el proyecto seleccionado
            context.pop(project);
          },
        );
      },
    );
  }
}

