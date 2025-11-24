import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/ler_logo.dart';

/// Pantalla de splash (inicial)
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // Esperar a que el AuthNotifier termine de verificar la autenticación
    final authNotifier = ref.read(authNotifierProvider);
    
    // Esperar hasta que termine de cargar o máximo 3 segundos
    int attempts = 0;
    while (authNotifier.currentState.isLoading && attempts < 30) {
      await Future.delayed(const Duration(milliseconds: 100));
      attempts++;
      if (!mounted) return;
    }
    
    // Esperar un poco más para asegurar que el estado se propague
    await Future.delayed(const Duration(milliseconds: 300));
    
    if (!mounted) return;

    final authState = ref.read(authProvider);
    if (authState.isAuthenticated) {
      context.go('/home');
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const LerLogo(
              height: 140,
              showTagline: true,
              appName: 'LER Datero',
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

