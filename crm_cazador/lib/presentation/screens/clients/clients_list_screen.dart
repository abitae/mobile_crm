import 'package:flutter/material.dart';
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
    final clientsState = ref.watch(clientsNotifierProvider).currentState;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes'),
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
          // Search bar with Material 3 styling
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Buscar clientes',
                      hintText: 'Nombre, documento, teléfono...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                // Actualizar búsqueda para mostrar todos los clientes
                                ref.read(clientsNotifierProvider).setSearch(null);
                                // Ocultar teclado
                                FocusScope.of(context).unfocus();
                              },
                            )
                          : null,
                      filled: true,
                    ),
                    onChanged: (value) {
                      // Actualizar inmediatamente si está vacío para mostrar todos los clientes
                      if (value.isEmpty || value.trim().isEmpty) {
                        ref.read(clientsNotifierProvider).setSearch(null);
                      }
                    },
                    onSubmitted: (value) {
                      final searchText = value.trim();
                      ref.read(clientsNotifierProvider).setSearch(
                            searchText.isEmpty ? null : searchText,
                          );
                      // Ocultar teclado después de buscar
                      FocusScope.of(context).unfocus();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: () {
                    // Obtener el texto y limpiar espacios
                    final searchText = _searchController.text.trim();
                    
                    // Aplicar búsqueda
                    ref.read(clientsNotifierProvider).setSearch(
                          searchText.isEmpty ? null : searchText,
                        );
                    
                    // Ocultar teclado después de buscar
                    FocusScope.of(context).unfocus();
                  },
                  icon: const Icon(Icons.search, size: 20),
                  label: const Text('Buscar'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    minimumSize: const Size(0, 56), // Altura mínima para coincidir con el TextField
                  ),
                ),
              ],
            ),
          ),
          // Active filters chips
          if (clientsState.statusFilter != null ||
              clientsState.typeFilter != null ||
              clientsState.sourceFilter != null ||
              clientsState.createTypeFilter != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Wrap(
                spacing: 8,
                children: [
                  if (clientsState.statusFilter != null)
                    FilterChip(
                      label: Text(_getStatusLabel(clientsState.statusFilter!)),
                      onSelected: (_) {
                        ref.read(clientsNotifierProvider).setFilters(
                              status: null,
                            );
                      },
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () {
                        ref.read(clientsNotifierProvider).setFilters(
                              status: null,
                            );
                      },
                    ),
                  if (clientsState.typeFilter != null)
                    FilterChip(
                      label: Text(_getTypeLabel(clientsState.typeFilter!)),
                      onSelected: (_) {
                        ref.read(clientsNotifierProvider).setFilters(
                              type: null,
                            );
                      },
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () {
                        ref.read(clientsNotifierProvider).setFilters(
                              type: null,
                            );
                      },
                    ),
                  if (clientsState.sourceFilter != null)
                    FilterChip(
                      label: Text(_getSourceLabel(clientsState.sourceFilter!)),
                      onSelected: (_) {
                        ref.read(clientsNotifierProvider).setFilters(
                              source: null,
                            );
                      },
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () {
                        ref.read(clientsNotifierProvider).setFilters(
                              source: null,
                            );
                      },
                    ),
                  if (clientsState.createTypeFilter != null)
                    FilterChip(
                      label: Text(_getCreateTypeLabel(clientsState.createTypeFilter!)),
                      onSelected: (_) {
                        ref.read(clientsNotifierProvider).setFilters(
                              createType: null,
                            );
                      },
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () {
                        ref.read(clientsNotifierProvider).setFilters(
                              createType: null,
                            );
                      },
                    ),
                ],
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

  void _showFilterBottomSheet(BuildContext context) {
    final clientsState = ref.read(clientsNotifierProvider).currentState;
    final optionsAsync = ref.watch(clientOptionsProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _FilterBottomSheet(
        clientsState: clientsState,
        optionsAsync: optionsAsync,
        onApply: (status, type, source, createType) {
          ref.read(clientsNotifierProvider).setFilters(
                status: status,
                type: type,
                source: source,
                createType: createType,
              );
        },
        onClear: () {
          ref.read(clientsNotifierProvider).clearFilters();
        },
      ),
    );
  }

  String _getStatusLabel(String status) {
    final labels = {
      'nuevo': 'Nuevo',
      'contacto_inicial': 'Contacto Inicial',
      'en_seguimiento': 'En Seguimiento',
      'cierre': 'Cierre',
      'perdido': 'Perdido',
    };
    return labels[status] ?? status;
  }

  String _getTypeLabel(String type) {
    final labels = {
      'inversor': 'Inversor',
      'comprador': 'Comprador',
      'empresa': 'Empresa',
      'constructor': 'Constructor',
    };
    return labels[type] ?? type;
  }

  String _getSourceLabel(String source) {
    final labels = {
      'redes_sociales': 'Redes Sociales',
      'ferias': 'Ferias',
      'referidos': 'Referidos',
      'formulario_web': 'Formulario Web',
      'publicidad': 'Publicidad',
    };
    return labels[source] ?? source;
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

    return ListView.builder(
      controller: _scrollController,
      itemCount: state.clients.length + (state.isLoadingMore ? 1 : 0),
      cacheExtent: 500, // Optimizar caché de scroll
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
            key: ValueKey('client_${client.id}'), // Key única para evitar duplicados en renderizado
            client: client,
            onTap: () {
              context.push('/clients/${client.id}');
            },
          ),
        );
      },
    );
  }
}

/// Widget para el bottom sheet de filtros
class _FilterBottomSheet extends ConsumerStatefulWidget {
  final ClientsState clientsState;
  final AsyncValue<ClientOptions> optionsAsync;
  final void Function(String? status, String? type, String? source, String? createType) onApply;
  final VoidCallback onClear;

  const _FilterBottomSheet({
    required this.clientsState,
    required this.optionsAsync,
    required this.onApply,
    required this.onClear,
  });

  @override
  ConsumerState<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends ConsumerState<_FilterBottomSheet> {
  late String? _selectedStatus;
  late String? _selectedType;
  late String? _selectedSource;
  late String? _selectedCreateType;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.clientsState.statusFilter;
    _selectedType = widget.clientsState.typeFilter;
    _selectedSource = widget.clientsState.sourceFilter;
    _selectedCreateType = widget.clientsState.createTypeFilter;
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
      child: widget.optionsAsync.when(
        data: (options) => Column(
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
            const SizedBox(height: 16),
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
                  selected: _selectedStatus == null,
                  onSelected: (_) {
                    setState(() {
                      _selectedStatus = null;
                    });
                  },
                ),
                ...options.statusesList.map((status) => ChoiceChip(
                      label: Text(options.getStatusLabel(status)),
                      selected: _selectedStatus == status,
                      onSelected: (_) {
                        setState(() {
                          _selectedStatus = _selectedStatus == status ? null : status;
                        });
                      },
                    )),
              ],
            ),
            const SizedBox(height: 20),
            // Filtro de Tipo con chips
            Text(
              'Tipo de Cliente',
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
                  selected: _selectedType == null,
                  onSelected: (_) {
                    setState(() {
                      _selectedType = null;
                    });
                  },
                ),
                ...options.clientTypesList.map((type) => ChoiceChip(
                      label: Text(options.getClientTypeLabel(type)),
                      selected: _selectedType == type,
                      onSelected: (_) {
                        setState(() {
                          _selectedType = _selectedType == type ? null : type;
                        });
                      },
                    )),
              ],
            ),
            const SizedBox(height: 20),
            // Filtro de Origen con chips
            Text(
              'Origen',
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
                  selected: _selectedSource == null,
                  onSelected: (_) {
                    setState(() {
                      _selectedSource = null;
                    });
                  },
                ),
                ...options.sourcesList.map((source) => ChoiceChip(
                      label: Text(options.getSourceLabel(source)),
                      selected: _selectedSource == source,
                      onSelected: (_) {
                        setState(() {
                          _selectedSource = _selectedSource == source ? null : source;
                        });
                      },
                    )),
              ],
            ),
            const SizedBox(height: 20),
            // Filtro de Tipo de Creación con chips
            Text(
              'Tipo de Creación',
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
                  selected: _selectedCreateType == null,
                  onSelected: (_) {
                    setState(() {
                      _selectedCreateType = null;
                    });
                  },
                ),
                ChoiceChip(
                  label: const Text('Propio'),
                  selected: _selectedCreateType == 'propio',
                  onSelected: (_) {
                    setState(() {
                      _selectedCreateType = _selectedCreateType == 'propio' ? null : 'propio';
                    });
                  },
                ),
                ChoiceChip(
                  label: const Text('Dateado'),
                  selected: _selectedCreateType == 'datero',
                  onSelected: (_) {
                    setState(() {
                      _selectedCreateType = _selectedCreateType == 'datero' ? null : 'datero';
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
                      widget.onApply(_selectedStatus, _selectedType, _selectedSource, _selectedCreateType);
                      Navigator.pop(context);
                    },
                    child: const Text('Aplicar'),
                  ),
                ),
              ],
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Error al cargar opciones: $error'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ],
        ),
      ),
    );
  }
}

