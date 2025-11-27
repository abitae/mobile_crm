import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/client_provider.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/empty_state.dart';
import 'widgets/client_card.dart';

/// Pantalla de selección de cliente (para usar en formularios)
class ClientSelectScreen extends ConsumerStatefulWidget {
  const ClientSelectScreen({super.key});

  @override
  ConsumerState<ClientSelectScreen> createState() => _ClientSelectScreenState();
}

class _ClientSelectScreenState extends ConsumerState<ClientSelectScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Cargar clientes al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(clientsNotifierProvider).loadClients();
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
    final clientsState = ref.watch(clientsNotifierProvider).currentState;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar Cliente'),
      ),
      body: Column(
        children: [
          // Search bar
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
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await ref.read(clientsNotifierProvider).loadClients(refresh: true);
              },
              child: _buildBody(clientsState),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(ClientsState clientsState) {
    if (clientsState.isLoading && clientsState.clients.isEmpty) {
      return const LoadingIndicator();
    }

    if (clientsState.error != null && clientsState.clients.isEmpty) {
      return AppErrorWidget(
        message: clientsState.error!,
        onRetry: () {
          ref.read(clientsNotifierProvider).loadClients(refresh: true);
        },
      );
    }

    if (clientsState.clients.isEmpty) {
      return EmptyState(
        icon: Icons.people_outlined,
        title: 'No hay clientes',
        message: 'No se encontraron clientes disponibles',
      );
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: clientsState.clients.length + (clientsState.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= clientsState.clients.length) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final client = clientsState.clients[index];
        return ClientCard(
          client: client,
          onTap: () {
            // Retornar el cliente seleccionado
            context.pop(client);
          },
        );
      },
    );
  }
}

