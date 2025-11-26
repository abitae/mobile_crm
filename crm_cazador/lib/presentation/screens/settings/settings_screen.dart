import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_icons.dart';

/// Pantalla de configuración
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
      ),
      body: ListView(
        children: [
          if (authState.user != null)
            _buildUserSection(context, authState.user!),
          const Divider(),
          ListTile(
            leading: Icon(AppIcons.settings),
            title: const Text('Configuración de API'),
            subtitle: const Text('Configurar URL del servidor'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              context.push('/settings/api');
            },
          ),
          ListTile(
            leading: Icon(AppIcons.lock),
            title: const Text('Cambiar Contraseña'),
            subtitle: const Text('Actualizar tu contraseña de acceso'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              context.push('/settings/change-password');
            },
          ),
          const Divider(),
          ListTile(
            leading: Icon(AppIcons.logout),
            title: const Text('Cerrar Sesión'),
            onTap: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Cerrar Sesión'),
                  content: const Text('¿Estás seguro de cerrar sesión?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancelar'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Cerrar Sesión'),
                    ),
                  ],
                ),
              );

              if (confirmed == true && context.mounted) {
                await ref.read(authNotifierProvider).logout();
                context.go('/login');
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUserSection(BuildContext context, user) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Text(
                  user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 24,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      user.email,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

