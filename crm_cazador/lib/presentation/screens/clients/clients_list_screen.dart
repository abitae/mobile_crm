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
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              HapticFeedback.lightImpact();
              context.push('/clients/new');
            },
            tooltip: 'Agregar Cliente',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar mejorado con mejor diseño visual
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar clientes...',
                hintStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  size: 22,
                  color: Theme.of(context).colorScheme.primary,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          size: 20,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(clientsNotifierProvider).setSearch(null);
                          FocusScope.of(context).unfocus();
                        },
                      )
                    : null,
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                ),
              ),
              onChanged: (value) {
                setState(() {}); // Actualizar UI para mostrar/ocultar clear button
                if (value.isEmpty || value.trim().isEmpty) {
                  ref.read(clientsNotifierProvider).setSearch(null);
                }
              },
              onSubmitted: (value) {
                final searchText = value.trim();
                ref.read(clientsNotifierProvider).setSearch(
                      searchText.isEmpty ? null : searchText,
                    );
                FocusScope.of(context).unfocus();
              },
            ),
          ),
          // Filtro de tipo de creación mejorado
          Padding(
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
                          notifier.setFilters(createType: null);
                        },
                        theme: theme,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _AnimatedFilterButton(
                        label: 'Propio',
                        isSelected: currentFilter == 'propio',
                        onTap: () {
                          HapticFeedback.selectionClick();
                          final notifier = ref.read(clientsNotifierProvider);
                          notifier.setFilters(createType: 'propio');
                        },
                        theme: theme,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _AnimatedFilterButton(
                        label: 'Dateado',
                        isSelected: currentFilter == 'datero',
                        onTap: () {
                          HapticFeedback.selectionClick();
                          final notifier = ref.read(clientsNotifierProvider);
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          HapticFeedback.mediumImpact();
          context.push('/clients/new');
        },
        tooltip: 'Agregar Cliente',
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Cliente'),
        elevation: 6,
      ),
    );
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
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: widget.isSelected
                    ? widget.theme.colorScheme.primary
                    : widget.theme.colorScheme.surface,
                border: Border.all(
                  color: widget.isSelected
                      ? widget.theme.colorScheme.primary
                      : widget.theme.colorScheme.outline.withOpacity(0.2),
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
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
              ),
              child: Center(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 250),
                  style: TextStyle(
                    fontSize: 13,
                    color: widget.isSelected
                        ? widget.theme.colorScheme.onPrimary
                        : widget.theme.colorScheme.onSurface,
                    fontWeight: widget.isSelected ? FontWeight.w700 : FontWeight.w500,
                    letterSpacing: 0.2,
                  ),
                  child: Text(widget.label),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}


