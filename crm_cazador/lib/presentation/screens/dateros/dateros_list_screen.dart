import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/datero_provider.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/skeletons/datero_list_skeleton.dart';
import '../../widgets/animations/stagger_animation.dart';
import '../../theme/app_icons.dart';
import '../../../data/models/datero_model.dart';

/// Pantalla de listado de dateros
class DaterosListScreen extends ConsumerStatefulWidget {
  const DaterosListScreen({super.key});

  @override
  ConsumerState<DaterosListScreen> createState() => _DaterosListScreenState();
}

class _DaterosListScreenState extends ConsumerState<DaterosListScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _searchTimer;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    if (currentScroll >= maxScroll * 0.8 && maxScroll > 0) {
      ref.read(daterosNotifierProvider).loadMoreDateros();
    }
  }

  void _handleSearch(String query) {
    // Cancelar timer anterior si existe
    _searchTimer?.cancel();

    // Si la búsqueda está vacía, buscar inmediatamente
    if (query.isEmpty) {
      ref.read(daterosNotifierProvider).setSearch(null);
      return;
    }

    // Crear nuevo timer con debounce de 300ms
    _searchTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted && _searchController.text == query) {
        ref.read(daterosNotifierProvider).setSearch(query);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final daterosState = ref.watch(daterosNotifierProvider).currentState;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dateros'),
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar dateros',
                hintText: 'Nombre, email, teléfono, DNI...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(daterosNotifierProvider).setSearch(null);
                        },
                      )
                    : null,
                filled: true,
              ),
              onChanged: _handleSearch,
            ),
          ),
          // Active filters chips
          if (daterosState.isActiveFilter != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Wrap(
                spacing: 8,
                children: [
                  FilterChip(
                    label: Text(
                      daterosState.isActiveFilter == true ? 'Activos' : 'Inactivos',
                    ),
                    onSelected: (_) {
                      ref.read(daterosNotifierProvider).setIsActiveFilter(null);
                    },
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: () {
                      ref.read(daterosNotifierProvider).setIsActiveFilter(null);
                    },
                  ),
                ],
              ),
            ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await ref.read(daterosNotifierProvider).loadDateros(
                      refresh: true,
                    );
              },
              child: _buildBody(daterosState),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/dateros/new');
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(DaterosState state) {
    if (state.isLoading && state.dateros.isEmpty) {
      return const DateroListSkeleton();
    }

    if (state.error != null && state.dateros.isEmpty) {
      return AppErrorWidget(
        message: state.error!,
        onRetry: () {
          ref.read(daterosNotifierProvider).loadDateros(refresh: true);
        },
      );
    }

    if (state.dateros.isEmpty) {
      return EmptyState(
        icon: AppIcons.clients,
        title: 'No hay dateros',
        message: 'Comienza agregando tu primer datero',
        action: () {
          context.push('/dateros/new');
        },
        actionLabel: 'Agregar Datero',
      );
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: state.dateros.length + (state.isLoadingMore ? 1 : 0),
      cacheExtent: 500,
      itemBuilder: (context, index) {
        if (index >= state.dateros.length) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final datero = state.dateros[index];
        return StaggerAnimation(
          index: index,
          child: _DateroCard(
            key: ValueKey('datero_${datero.id}'),
            datero: datero,
            onTap: () {
              if (datero.id != null) {
                context.push('/dateros/${datero.id}');
              }
            },
          ),
        );
      },
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    final daterosState = ref.read(daterosNotifierProvider).currentState;

    showModalBottomSheet(
      context: context,
      builder: (context) => _FilterBottomSheet(
        daterosState: daterosState,
        onApply: (isActive) {
          ref.read(daterosNotifierProvider).setIsActiveFilter(isActive);
        },
        onClear: () {
          ref.read(daterosNotifierProvider).setIsActiveFilter(null);
        },
      ),
    );
  }
}

/// Widget para el bottom sheet de filtros de dateros
class _FilterBottomSheet extends StatefulWidget {
  final DaterosState daterosState;
  final void Function(bool?) onApply;
  final VoidCallback onClear;

  const _FilterBottomSheet({
    required this.daterosState,
    required this.onApply,
    required this.onClear,
  });

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  late bool? _selectedIsActive;

  @override
  void initState() {
    super.initState();
    _selectedIsActive = widget.daterosState.isActiveFilter;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filtros',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Filtro de Estado con chips
          Text(
            'Estado',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoiceChip(
                label: const Text('Todos'),
                selected: _selectedIsActive == null,
                onSelected: (_) {
                  setState(() {
                    _selectedIsActive = null;
                  });
                },
              ),
              ChoiceChip(
                label: const Text('Activos'),
                selected: _selectedIsActive == true,
                onSelected: (_) {
                  setState(() {
                    _selectedIsActive = _selectedIsActive == true ? null : true;
                  });
                },
              ),
              ChoiceChip(
                label: const Text('Inactivos'),
                selected: _selectedIsActive == false,
                onSelected: (_) {
                  setState(() {
                    _selectedIsActive = _selectedIsActive == false ? null : false;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    widget.onClear();
                    Navigator.pop(context);
                  },
                  child: const Text('Limpiar'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    widget.onApply(_selectedIsActive);
                    Navigator.pop(context);
                  },
                  child: const Text('Aplicar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DateroCard extends StatelessWidget {
  final DateroModel datero;
  final VoidCallback? onTap;

  const _DateroCard({
    super.key,
    required this.datero,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: colorScheme.primaryContainer,
          child: Text(
            datero.name.isNotEmpty ? datero.name[0].toUpperCase() : '?',
            style: TextStyle(
              color: colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          datero.name,
          style: theme.textTheme.titleMedium,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (datero.email.isNotEmpty)
              Text(
                datero.email,
                style: theme.textTheme.bodySmall,
              ),
            Text(
              'DNI: ${datero.dni}',
              style: theme.textTheme.bodySmall,
            ),
            if (datero.phone.isNotEmpty)
              Text(
                'Tel: ${datero.phone}',
                style: theme.textTheme.bodySmall,
              ),
          ],
        ),
        trailing: Icon(
          datero.isActive ? Icons.check_circle : Icons.cancel,
          color: datero.isActive ? Colors.green : Colors.red,
        ),
      ),
    );
  }
}


