import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../providers/client_provider.dart';
import '../../providers/city_provider.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/skeletons/client_list_skeleton.dart';
import '../../widgets/animations/stagger_animation.dart';
import '../../theme/app_icons.dart';
import '../../../data/services/client_service.dart';
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
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(clientsNotifierProvider);
      notifier.addListener((state) {
        if (mounted) setState(() {});
      });
      // Por defecto mostrar "Propios"; nunca mostrar "Todos" en esta pantalla
      if (notifier.currentState.createTypeFilter == null) {
        notifier.setFilters(createType: 'propio');
      }
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

  static String _csvEscape(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  Future<void> _exportClients(BuildContext context, ClientsState clientsState) async {
    if (_isExporting) return;
    setState(() => _isExporting = true);
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Exportando clientes...'), duration: Duration(seconds: 2)),
    );
    try {
      final clients = await ClientService.getAllClientsForExport(
        createType: clientsState.createTypeFilter,
        cityId: clientsState.cityIdFilter,
      );
      final citiesAsync = ref.read(citiesProvider);
      final cities = citiesAsync.value ?? [];
      final cityNames = {for (var c in cities) c.id: c.name};
      final buffer = StringBuffer();
      buffer.writeln('Nombre,Telefono,Ciudad,Tipo');
      for (final c in clients) {
        final city = c.cityId != null ? (cityNames[c.cityId] ?? '') : '';
        buffer.writeln([
          _csvEscape(c.name),
          _csvEscape(c.phone ?? ''),
          _csvEscape(city),
          _csvEscape(c.type),
        ].join(','));
      }
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/clientes_export.csv');
      await file.writeAsString(buffer.toString());
      if (!mounted) return;
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Clientes exportados',
        text: 'Exportación de clientes (${clients.length} registros)',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Exportados ${clients.length} clientes')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al exportar: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isExporting = false);
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
            icon: _isExporting
                ? SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  )
                : const Icon(Icons.file_download_outlined),
            onPressed: _isExporting
                ? null
                : () => _exportClients(context, clientsState),
            tooltip: 'Exportar clientes',
          ),
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
          // Contenedor de filtros (tema unificado)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Container(
              padding: const EdgeInsets.all(14.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerLow.withOpacity(0.4),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.12),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Tipo: Propios | Dateados
                  Builder(
                    builder: (context) {
                      final currentFilter = clientsState.createTypeFilter ?? 'propio';
                      final colorScheme = Theme.of(context).colorScheme;
                      return SegmentedButton<String>(
                        segments: const [
                          ButtonSegment<String>(
                            value: 'propio',
                            label: Text('Propios'),
                            icon: Icon(Icons.person_outline, size: 18),
                          ),
                          ButtonSegment<String>(
                            value: 'datero',
                            label: Text('Dateados'),
                            icon: Icon(Icons.people_outline, size: 18),
                          ),
                        ],
                        selected: {currentFilter},
                        onSelectionChanged: (Set<String> selected) {
                          final value = selected.first;
                          HapticFeedback.selectionClick();
                          ref.read(clientsNotifierProvider).setFilters(createType: value);
                        },
                        style: ButtonStyle(
                          padding: WidgetStateProperty.all(
                            const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                          ),
                          visualDensity: VisualDensity.compact,
                          backgroundColor: WidgetStateProperty.resolveWith((states) {
                            if (states.contains(WidgetState.selected)) {
                              return colorScheme.primaryContainer;
                            }
                            return colorScheme.surface;
                          }),
                          foregroundColor: WidgetStateProperty.resolveWith((states) {
                            if (states.contains(WidgetState.selected)) {
                              return colorScheme.onPrimaryContainer;
                            }
                            return colorScheme.onSurfaceVariant;
                          }),
                          side: WidgetStateProperty.resolveWith((states) {
                            if (states.contains(WidgetState.selected)) {
                              return BorderSide(
                                color: colorScheme.primary.withOpacity(0.5),
                                width: 1.5,
                              );
                            }
                            return BorderSide(
                              color: colorScheme.outline.withOpacity(0.25),
                              width: 1,
                            );
                          }),
                          shape: WidgetStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  // Ciudad
                  _CityFilterDropdown(
                    selectedCityId: clientsState.cityIdFilter,
                    onCityChanged: (id) {
                      ref.read(clientsNotifierProvider).setFilters(cityId: id);
                    },
                  ),
                ],
              ),
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

/// Dropdown para filtrar clientes por ciudad (estilo unificado con filtros)
class _CityFilterDropdown extends ConsumerWidget {
  final int? selectedCityId;
  final ValueChanged<int?> onCityChanged;

  const _CityFilterDropdown({
    required this.selectedCityId,
    required this.onCityChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final citiesAsync = ref.watch(citiesProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: citiesAsync.when(
        data: (cities) {
          return DropdownButtonHideUnderline(
            child: DropdownButton<int?>(
              value: selectedCityId,
              isExpanded: true,
              isDense: false,
              hint: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_city_outlined,
                      size: 20,
                      color: colorScheme.onSurfaceVariant.withOpacity(0.8),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Todas las ciudades',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              borderRadius: BorderRadius.circular(12),
              dropdownColor: colorScheme.surfaceContainerHighest,
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: colorScheme.primary,
              ),
              items: [
                DropdownMenuItem<int?>(
                  value: null,
                  child: Row(
                    children: [
                      Icon(Icons.location_off_outlined, size: 20, color: colorScheme.onSurfaceVariant),
                      const SizedBox(width: 10),
                      const Text('Todas las ciudades'),
                    ],
                  ),
                ),
                ...cities.map(
                  (c) => DropdownMenuItem<int?>(
                    value: c.id,
                    child: Row(
                      children: [
                        Icon(Icons.location_city_outlined, size: 20, color: colorScheme.primary.withOpacity(0.8)),
                        const SizedBox(width: 10),
                        Text(c.name),
                      ],
                    ),
                  ),
                ),
              ],
              onChanged: (value) {
                HapticFeedback.selectionClick();
                onCityChanged(value);
              },
            ),
          );
        },
        loading: () => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme.primary),
              ),
              const SizedBox(width: 10),
              Text(
                'Cargando ciudades...',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        error: (e, _) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Icon(Icons.error_outline, size: 20, color: colorScheme.error),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'No se pudieron cargar ciudades',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.error,
                  ),
                ),
              ),
            ],
          ),
        ),
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


