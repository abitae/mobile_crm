import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../clients/clients_list_screen.dart';
import '../commissions/commissions_list_screen.dart';
import '../profile/profile_screen.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/common/ler_logo.dart';

/// Pantalla principal (Home) con Material 3 y NavigationBar
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outlined),
            selectedIcon: Icon(Icons.people),
            label: 'Clientes',
          ),
          NavigationDestination(
            icon: Icon(Icons.payments_outlined),
            selectedIcon: Icon(Icons.payments),
            label: 'Comisiones',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outlined),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return const ClientsListScreen();
      case 2:
        return const CommissionsListScreen();
      case 3:
        return const ProfileScreen();
      default:
        return _buildHomeContent();
    }
  }

  Widget _buildHomeContent() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SafeArea(
      child: Column(
        children: [
          // Header superior con logo y botón de configuración
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                LerLogo(
                  height: 40,
                  showTagline: false,
                  appName: 'LER Datero',
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.settings_outlined),
                  onPressed: () {
                    context.push('/settings');
                  },
                  tooltip: 'Configuración',
                ),
              ],
            ),
          ),
          // Contenido desplazable
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Tarjeta resumen / bienvenida
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            colorScheme.primaryContainer,
                            colorScheme.secondaryContainer,
                          ],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tu panel de datero',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Accede rápidamente a tus clientes, comisiones y comparte tu QR de registro.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onPrimaryContainer
                                  .withOpacity(0.9),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor:
                                        colorScheme.onPrimaryContainer,
                                    side: BorderSide(
                                      color: colorScheme.onPrimaryContainer
                                          .withOpacity(0.3),
                                    ),
                                  ),
                                  onPressed: () {
                                    context.push('/clients');
                                  },
                                  icon: const Icon(Icons.people),
                                  label: const Text('Ver clientes'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor:
                                        colorScheme.onPrimaryContainer,
                                    side: BorderSide(
                                      color: colorScheme.onPrimaryContainer
                                          .withOpacity(0.3),
                                    ),
                                  ),
                                  onPressed: () {
                                    context.push('/commissions');
                                  },
                                  icon: const Icon(Icons.payments),
                                  label: const Text('Ver comisiones'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Bloque QR
                  Consumer(
              builder: (context, ref, _) {
                final notifier = ref.watch(profileNotifierProvider);
                final profileState = notifier.currentState;
                if (profileState.isLoading && profileState.profile == null) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final profile = profileState.profile;
                if (profile == null) {
                  return const SizedBox.shrink();
                }

                final url =
                    'https://crm.lotesenremate.pe/clients/registro-datero/${profile.id}';

                return Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'QR de registro de clientes',
                              style: theme.textTheme.titleMedium,
                            ),
                            Icon(
                              Icons.qr_code_2,
                              color: colorScheme.primary,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          color: Colors.white,
                          padding: const EdgeInsets.all(12),
                          child: QrImageView(
                            data: url,
                            size: 180,
                            version: QrVersions.auto,
                            gapless: true,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          url,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
