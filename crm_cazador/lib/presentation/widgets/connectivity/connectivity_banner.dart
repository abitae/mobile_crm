import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/connectivity/connectivity_service.dart';

/// Provider para el estado de conectividad
final connectivityStatusProvider = StreamProvider<ConnectivityStatus>((ref) {
  final service = ConnectivityService();
  service.initialize();
  ref.onDispose(() => service.dispose());
  return service.onStatusChanged;
});

/// Banner que se muestra cuando no hay conexión
class ConnectivityBanner extends ConsumerWidget {
  const ConnectivityBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivityAsync = ref.watch(connectivityStatusProvider);

    return connectivityAsync.when(
      data: (status) {
        if (status == ConnectivityStatus.disconnected) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.red.shade700,
            child: Row(
              children: [
                const Icon(
                  Icons.wifi_off,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Sin conexión a internet',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
