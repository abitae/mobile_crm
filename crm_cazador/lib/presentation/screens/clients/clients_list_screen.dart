import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/client_provider.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/skeletons/client_list_skeleton.dart';
import '../../widgets/animations/stagger_animation.dart';
import '../../theme/app_icons.dart';
import '../../../data/models/client_options.dart';
import 'widgets/client_card.dart';

/// Pantalla de listado de clientes
class ClientsListScreen extends ConsumerStatefulWidget {
  const ClientsListScreen({super.key});

  @override
  ConsumerState<ClientsListScreen> createState() => _ClientsListScreenState();
}

class _ClientsListScreenState extends ConsumerState<ClientsListScreen> {
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
      final notifier = ref.read(clientsNotifierProvider);
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
      ref.read(clientsNotifierProvider).loadMoreClients();
    }
  }


  @override
  Widget build(BuildContext context) {
    // Observar el notifier directamente para reactividad completa
    final notifier = ref.watch(clientsNotifierProvider);
    final clientsState = notifier.currentState;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes'),
      ),
      body: Column(
        children: [
          // Search bar mejorado con animaciones
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        labelText: 'Buscar clientes',
                        hintText: 'Nombre, documento, teléfono...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: _searchController.text.isNotEmpty
                              ? IconButton(
                                  key: const ValueKey('clear'),
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    HapticFeedback.lightImpact();
                                    _searchController.clear();
                                    ref.read(clientsNotifierProvider).setSearch(null);
                                    FocusScope.of(context).unfocus();
                                  },
                                )
                              : const SizedBox.shrink(key: ValueKey('empty')),
                        ),
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (value) {
                        if (value.isEmpty || value.trim().isEmpty) {
                          ref.read(clientsNotifierProvider).setSearch(null);
                        }
                      },
                      onSubmitted: (value) {
                        HapticFeedback.selectionClick();
                        final searchText = value.trim();
                        ref.read(clientsNotifierProvider).setSearch(
                              searchText.isEmpty ? null : searchText,
                            );
                        FocusScope.of(context).unfocus();
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedScale(
                  scale: _searchController.text.isNotEmpty ? 1.0 : 0.9,
                  duration: const Duration(milliseconds: 200),
                  child: FilledButton.icon(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      final searchText = _searchController.text.trim();
                      ref.read(clientsNotifierProvider).setSearch(
                            searchText.isEmpty ? null : searchText,
                          );
                      FocusScope.of(context).unfocus();
                    },
                    icon: const Icon(Icons.search, size: 20),
                    label: const Text('Buscar'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      minimumSize: const Size(0, 56),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Indicador de resultados y filtros activos
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: (clientsState.createTypeFilter != null || clientsState.search != null)
                ? Container(
                    key: const ValueKey('filters'),
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      children: [
                        // Contador de resultados
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.people_outline,
                                size: 16,
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${clientsState.clients.length} ${clientsState.clients.length == 1 ? 'cliente' : 'clientes'}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Chips de filtros activos
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                if (clientsState.search != null)
                                  _FilterChip(
                                    label: 'Búsqueda: "${clientsState.search}"',
                                    onDelete: () {
                                      debugPrint('🗑️ [ClientsList] Eliminando filtro de búsqueda');
                                      HapticFeedback.lightImpact();
                                      _searchController.clear();
                                      final notifier = ref.read(clientsNotifierProvider);
                                      notifier.setSearch(null);
                                    },
                                  ),
                                if (clientsState.createTypeFilter != null)
                                  _FilterChip(
                                    label: _getCreateTypeLabel(clientsState.createTypeFilter!),
                                    onDelete: () {
                                      debugPrint('🗑️ [ClientsList] Eliminando filtro createType');
                                      HapticFeedback.lightImpact();
                                      final notifier = ref.read(clientsNotifierProvider);
                                      notifier.setFilters(createType: null);
                                    },
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(key: ValueKey('no-filters')),
          ),
          // Filtro de tipo de creación mejorado con animaciones
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Builder(
              builder: (context) {
                final currentFilter = clientsState.createTypeFilter;
                final theme = Theme.of(context);
                
                return Row(
                  children: [
                    Expanded(
                      child: _AnimatedFilterButton(
                        label: 'Todos',
                        isSelected: currentFilter == null,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          final notifier = ref.read(clientsNotifierProvider);
                          debugPrint('🔘 [ClientsList] Filtro seleccionado: null (Todos)');
                          notifier.setFilters(createType: null);
                        },
                        theme: theme,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _AnimatedFilterButton(
                        label: 'Propio',
                        isSelected: currentFilter == 'propio',
                        onTap: () {
                          HapticFeedback.selectionClick();
                          final notifier = ref.read(clientsNotifierProvider);
                          debugPrint('🔘 [ClientsList] Filtro seleccionado: propio');
                          notifier.setFilters(createType: 'propio');
                        },
                        theme: theme,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _AnimatedFilterButton(
                        label: 'Dateado',
                        isSelected: currentFilter == 'datero',
                        onTap: () {
                          HapticFeedback.selectionClick();
                          final notifier = ref.read(clientsNotifierProvider);
                          debugPrint('🔘 [ClientsList] Filtro seleccionado: datero');
                          notifier.setFilters(createType: 'datero');
                        },
                        theme: theme,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await ref.read(clientsNotifierProvider).loadClients(
                      refresh: true,
                    );
              },
              child: _buildBody(clientsState),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/clients/new');
        },
        child: const Icon(Icons.add),
      ),
    );
  }


  String _getCreateTypeLabel(String createType) {
    final labels = {
      'propio': 'Propio',
      'datero': 'Dateado',
    };
    return labels[createType] ?? createType;
  }

  Widget _buildBody(ClientsState state) {
    if (state.isLoading && state.clients.isEmpty) {
      return const ClientListSkeleton();
    }

    if (state.error != null && state.clients.isEmpty) {
      return AppErrorWidget(
        message: state.error!,
        onRetry: () {
          ref.read(clientsNotifierProvider).loadClients(refresh: true);
        },
      );
    }

    if (state.clients.isEmpty) {
      return EmptyState(
        icon: AppIcons.clients,
        title: 'No hay clientes',
        message: 'Comienza agregando tu primer cliente',
        action: () {
          context.push('/clients/new');
        },
        actionLabel: 'Agregar Cliente',
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
        key: ValueKey('clients_list_${state.createTypeFilter}_${state.search}'),
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: state.clients.length + (state.isLoadingMore ? 1 : 0),
        cacheExtent: 500,
        itemBuilder: (context, index) {
          if (index >= state.clients.length) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final client = state.clients[index];
          return StaggerAnimation(
            index: index,
            child: ClientCard(
              key: ValueKey('client_${client.id}'),
              client: client,
              onTap: () {
                HapticFeedback.lightImpact();
                context.push('/clients/${client.id}');
              },
            ),
          );
        },
      ),
    );
  }
}

/// Botón de filtro animado con feedback visual mejorado
class _AnimatedFilterButton extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final ThemeData theme;

  const _AnimatedFilterButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.theme,
  });

  @override
  State<_AnimatedFilterButton> createState() => _AnimatedFilterButtonState();
}

class _AnimatedFilterButtonState extends State<_AnimatedFilterButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
    widget.onTap();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: widget.isSelected
                    ? widget.theme.colorScheme.primary
                    : widget.theme.colorScheme.surface,
                border: Border.all(
                  color: widget.isSelected
                      ? widget.theme.colorScheme.primary
                      : widget.theme.colorScheme.outline.withOpacity(0.3),
                  width: widget.isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: widget.isSelected
                    ? [
                        BoxShadow(
                          color: widget.theme.colorScheme.primary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: widget.isSelected
                        ? Icon(
                            Icons.check_circle,
                            key: const ValueKey('selected'),
                            size: 18,
                            color: widget.theme.colorScheme.onPrimary,
                          )
                        : Icon(
                            Icons.radio_button_unchecked,
                            key: const ValueKey('unselected'),
                            size: 18,
                            color: widget.theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                  ),
                  const SizedBox(width: 6),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      fontSize: 13,
                      color: widget.isSelected
                          ? widget.theme.colorScheme.onPrimary
                          : widget.theme.colorScheme.onSurface,
                      fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                    child: Text(widget.label),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Chip para mostrar filtros activos con eliminación rápida
class _FilterChip extends StatefulWidget {
  final String label;
  final VoidCallback onDelete;

  const _FilterChip({
    required this.label,
    required this.onDelete,
  });

  @override
  State<_FilterChip> createState() => _FilterChipState();
}

class _FilterChipState extends State<_FilterChip> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    HapticFeedback.lightImpact();
    widget.onDelete();
    _controller.forward().then((_) {
      _controller.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        _handleTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              child: Chip(
                label: Text(
                  widget.label,
                  style: const TextStyle(fontSize: 12),
                ),
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () {
                  HapticFeedback.lightImpact();
                  widget.onDelete();
                },
                backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                labelStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
                side: BorderSide(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          );
        },
      ),
    );
  }
}

