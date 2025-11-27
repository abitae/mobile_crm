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
    if (_scrollController.hasClients &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.8) {
      final notifier = ref.read(projectUnitsNotifierProvider(widget.projectId));
      notifier.loadMoreUnits();
    }
  }

  @override
  Widget build(BuildContext context) {
    final projectAsync = ref.watch(projectProvider(widget.projectId));

    return Scaffold(
      appBar: AppBar(
        title: projectAsync.when(
          data: (project) => Text('Unidades - ${project.name}'),
          loading: () => const Text('Unidades'),
          error: (_, __) => const Text('Unidades'),
        ),
      ),
      body: _UnitsListWidget(
        projectId: widget.projectId,
      ),
    );
  }


}

/// Widget separado para la lista de unidades que se actualiza automáticamente
class _UnitsListWidget extends ConsumerStatefulWidget {
  final int projectId;

  const _UnitsListWidget({
    required this.projectId,
  });

  @override
  ConsumerState<_UnitsListWidget> createState() => _UnitsListWidgetState();
}

class _UnitsListWidgetState extends ConsumerState<_UnitsListWidget> {
  final _scrollController = ScrollController();
  ProjectUnitsState? _lastState;

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
    if (_scrollController.hasClients &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.8) {
      final notifier = ref.read(projectUnitsNotifierProvider(widget.projectId));
      notifier.loadMoreUnits();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Observar el notifier para que el widget se reconstruya cuando cambie
    final unitsNotifier = ref.watch(projectUnitsNotifierProvider(widget.projectId));
    // Acceder al estado actual
    final state = unitsNotifier.currentState;
    
    // Debug: verificar el estado
    print('🔄 [ProjectUnitsScreen] Building with ${state.units.length} units, isLoading=${state.isLoading}, error=${state.error}');
    
    // Forzar rebuild si el estado cambió usando un enfoque más directo
    if (_lastState != state) {
      _lastState = state;
      // Usar un post-frame callback para forzar rebuild
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {});
        }
      });
    }

    // Mostrar loading solo si no hay unidades y está cargando
    if (state.isLoading && state.units.isEmpty) {
      return const LoadingIndicator();
    }

    // Mostrar error solo si no hay unidades
    if (state.error != null && state.units.isEmpty) {
      return AppErrorWidget(
        message: state.error!,
        onRetry: () {
          unitsNotifier.loadUnits(refresh: true);
        },
      );
    }

    // Si no hay unidades y no está cargando ni hay error, mostrar estado vacío
    if (state.units.isEmpty && !state.isLoading && state.error == null) {
      return RefreshIndicator(
        onRefresh: () async {
          await unitsNotifier.loadUnits(refresh: true);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: EmptyState(
              icon: Icons.home_outlined,
              title: 'No hay unidades disponibles',
              message: 'Este proyecto no tiene unidades disponibles en este momento',
              action: () {
                unitsNotifier.loadUnits(refresh: true);
              },
              actionLabel: 'Recargar',
            ),
          ),
        ),
      );
    }

    // Si hay unidades, mostrar la lista
    if (state.units.isNotEmpty) {
      return RefreshIndicator(
        onRefresh: () async {
          await unitsNotifier.loadUnits(refresh: true);
        },
        child: ListView.builder(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: state.units.length + (state.isLoadingMore ? 1 : 0),
          cacheExtent: 500,
          itemBuilder: (context, index) {
            if (index >= state.units.length) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final unit = state.units[index];
            return UnitCard(
              key: ValueKey('unit-${unit.id}'),
              unit: unit,
              onTap: () {
                // TODO: Navegar a detalle de unidad si se implementa
              },
            );
          },
        ),
      );
    }

    // Fallback: mostrar loading
    return const LoadingIndicator();
  }
}

