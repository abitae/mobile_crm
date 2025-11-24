import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/client_provider.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/empty_state.dart';
import '../../theme/app_icons.dart';
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
      ref.read(clientsNotifierProvider).loadMoreClients();
    }
  }

  void _handleSearch(String query) {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_searchController.text == query) {
        ref.read(clientsNotifierProvider).setSearch(
              query.isEmpty ? null : query,
            );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final clientsState = ref.watch(clientsProvider);

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
                          ref.read(clientsNotifierProvider).setSearch(null);
                        },
                      )
                    : null,
                filled: true,
              ),
              onChanged: _handleSearch,
            ),
          ),
          // Active filters chips
          if (clientsState.statusFilter != null ||
              clientsState.typeFilter != null ||
              clientsState.sourceFilter != null)
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
    showModalBottomSheet(
      context: context,
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
                ref.read(clientsNotifierProvider).clearFilters();
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

  Widget _buildBody(ClientsState state) {
    if (state.isLoading && state.clients.isEmpty) {
      return const LoadingIndicator();
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
      itemBuilder: (context, index) {
        if (index >= state.clients.length) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final client = state.clients[index];
        return ClientCard(
          client: client,
          onTap: () {
            context.push('/clients/${client.id}');
          },
        );
      },
    );
  }
}

