import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/datero_provider.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/empty_state.dart';
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

  void _handleSearch(String query) {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_searchController.text == query) {
        ref.read(daterosNotifierProvider).setSearch(
              query.isEmpty ? null : query,
            );
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
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list_outlined),
            onSelected: (value) {
              if (value == 'all') {
                ref.read(daterosNotifierProvider).setIsActiveFilter(null);
              } else if (value == 'active') {
                ref.read(daterosNotifierProvider).setIsActiveFilter(true);
              } else if (value == 'inactive') {
                ref.read(daterosNotifierProvider).setIsActiveFilter(false);
              }
            },
            itemBuilder: (context) => [
              CheckedPopupMenuItem(
                value: 'all',
                checked: daterosState.isActiveFilter == null,
                child: const Text('Todos'),
              ),
              CheckedPopupMenuItem(
                value: 'active',
                checked: daterosState.isActiveFilter == true,
                child: const Text('Activos'),
              ),
              CheckedPopupMenuItem(
                value: 'inactive',
                checked: daterosState.isActiveFilter == false,
                child: const Text('Inactivos'),
              ),
            ],
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
      return const LoadingIndicator();
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
        return _DateroCard(
          key: ValueKey('datero_${datero.id}'),
          datero: datero,
          onTap: () {
            if (datero.id != null) {
              context.push('/dateros/${datero.id}');
            }
          },
        );
      },
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


