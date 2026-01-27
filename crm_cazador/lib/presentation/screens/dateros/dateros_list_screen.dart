import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      final notifier = ref.read(daterosNotifierProvider);
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
      ref.read(daterosNotifierProvider).loadMoreDateros();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Observar el notifier directamente para reactividad completa
    final notifier = ref.watch(daterosNotifierProvider);
    final daterosState = notifier.currentState;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dateros'),
      ),
      body: Column(
        children: [
          // Search bar compacto
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar dateros...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(daterosNotifierProvider).setSearch(null);
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
                  ref.read(daterosNotifierProvider).setSearch(null);
                }
              },
              onSubmitted: (value) {
                final searchText = value.trim();
                ref.read(daterosNotifierProvider).setSearch(
                      searchText.isEmpty ? null : searchText,
                    );
                FocusScope.of(context).unfocus();
              },
            ),
          ),
          // Filtro de estado compacto
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
            child: Builder(
              builder: (context) {
                final currentFilter = daterosState.isActiveFilter;
                final theme = Theme.of(context);
                
                return Row(
                  children: [
                    Expanded(
                      child: _AnimatedFilterButton(
                        label: 'Todos',
                        isSelected: currentFilter == null,
                        onTap: () {
                          final notifier = ref.read(daterosNotifierProvider);
                          notifier.setIsActiveFilter(null);
                        },
                        theme: theme,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _AnimatedFilterButton(
                        label: 'Activos',
                        isSelected: currentFilter == true,
                        onTap: () {
                          final notifier = ref.read(daterosNotifierProvider);
                          notifier.setIsActiveFilter(true);
                        },
                        theme: theme,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _AnimatedFilterButton(
                        label: 'Inactivos',
                        isSelected: currentFilter == false,
                        onTap: () {
                          final notifier = ref.read(daterosNotifierProvider);
                          notifier.setIsActiveFilter(false);
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
        key: ValueKey('dateros_list_${state.isActiveFilter}_${state.search}'),
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
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
                HapticFeedback.lightImpact();
                if (datero.id != null) {
                  context.push('/dateros/${datero.id}');
                }
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
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: widget.isSelected
                    ? widget.theme.colorScheme.primary
                    : widget.theme.colorScheme.surface,
                border: Border.all(
                  color: widget.isSelected
                      ? widget.theme.colorScheme.primary
                      : widget.theme.colorScheme.outline.withOpacity(0.3),
                  width: widget.isSelected ? 1.5 : 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    fontSize: 12,
                    color: widget.isSelected
                        ? widget.theme.colorScheme.onPrimary
                        : widget.theme.colorScheme.onSurface,
                    fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w500,
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


