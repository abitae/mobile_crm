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
    try {
      // Esperar a que el AuthNotifier termine de verificar la autenticación
      final authNotifier = ref.read(authNotifierProvider);
      
      // Esperar hasta que termine de cargar o máximo 5 segundos (50 intentos * 100ms)
      int attempts = 0;
      const maxAttempts = 50;
      
      while (authNotifier.currentState.isLoading && attempts < maxAttempts) {
        await Future.delayed(const Duration(milliseconds: 100));
        attempts++;
        if (!mounted) return;
      }
      
      // Si aún está cargando después del timeout, continuar de todas formas
      if (authNotifier.currentState.isLoading) {
        print('Timeout esperando autenticación, continuando...');
      }
      
      // Esperar un poco más para asegurar que el estado se propague
      await Future.delayed(const Duration(milliseconds: 300));
      
      if (!mounted) return;

      final authState = ref.read(authProvider);
      if (authState.isAuthenticated) {
        if (mounted) {
          context.go('/home');
        }
      } else {
        if (mounted) {
          context.go('/login');
        }
      }
    } catch (e) {
      // Si hay un error, ir a login de todas formas
      print('Error en _checkAuth: $e');
      if (mounted) {
        context.go('/login');
      }
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

