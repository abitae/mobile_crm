import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_icons.dart';
import '../../widgets/common/ler_logo.dart';
import '../../widgets/common/numeric_keypad.dart';

/// Pantalla de login
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dniController = TextEditingController();
  String _pin = '';
  bool _rememberMe = false;
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    // Verificar el estado inicial después del primer frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateLoadingState();
    });
  }
  
  void _updateLoadingState() {
    if (!mounted) return;
    final notifier = ref.read(authNotifierProvider);
    final newLoadingState = notifier.currentState.isLoading;
    if (_isLoading != newLoadingState) {
      setState(() {
        _isLoading = newLoadingState;
      });
    }
  }
  
  @override
  void dispose() {
    _dniController.dispose();
    super.dispose();
  }

  void _onNumberPressed(String number) {
    if (_pin.length < 6) {
      setState(() {
        _pin += number;
      });
    }
  }

  void _onDeletePressed() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
      });
    }
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Validar PIN
    if (_pin.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('El PIN debe tener 6 dígitos'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final success = await ref.read(authNotifierProvider).login(
          dni: _dniController.text.trim(),
          pin: _pin,
          rememberMe: _rememberMe,
        );

    _updateLoadingState();

    if (!mounted) return;

    if (success) {
      // Mostrar mensaje de éxito
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Inicio de sesión exitoso'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 1),
          ),
        );
      }
      
      // Redirigir a home después de un breve delay
      // Esto permite que el mensaje se muestre y el estado se propague
      await Future.delayed(const Duration(milliseconds: 300));
      
      if (mounted) {
        // Verificar el estado una vez más antes de redirigir
        final notifier = ref.read(authNotifierProvider);
        final currentState = notifier.currentState;
        
        // Redirigir si está autenticado o forzar redirección si el login fue exitoso
        if (currentState.isAuthenticated || success) {
          context.go('/home');
        }
      }
    } else {
      final authState = ref.read(authProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authState.error ?? 'Error al iniciar sesión'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Actualizar el estado de carga cuando el widget se reconstruye
    final notifier = ref.watch(authNotifierProvider);
    final currentLoading = notifier.currentState.isLoading;
    if (_isLoading != currentLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _isLoading = currentLoading;
          });
        }
      });
    }

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const LerLogo(
                    height: 90,
                    showTagline: false,
                    appName: 'LER Datero',
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _dniController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(8),
                    ],
                    decoration: InputDecoration(
                      labelText: 'DNI',
                      hintText: '12345678',
                      prefixIcon: Icon(AppIcons.login),
                      helperText: 'Ingresa tu DNI de 8 dígitos',
                    ),
                    onChanged: (value) {
                      // Cerrar el teclado automáticamente cuando se ingresen 8 dígitos
                      if (value.length == 8) {
                        FocusScope.of(context).unfocus();
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa tu DNI';
                      }
                      if (value.length != 8) {
                        return 'El DNI debe tener 8 dígitos';
                      }
                      if (!RegExp(r'^\d+$').hasMatch(value)) {
                        return 'El DNI solo debe contener números';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Campo PIN con indicadores visuales
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PIN',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(6, (index) {
                            return Container(
                              width: 40,
                              height: 40,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.outline,
                                  width: 2,
                                ),
                                color: index < _pin.length
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.transparent,
                              ),
                              child: index < _pin.length
                                  ? Icon(
                                      Icons.circle,
                                      size: 16,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                    )
                                  : null,
                            );
                          }),
                        ),
                      ),
                      if (_pin.length < 6)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            'Ingresa tu PIN de 6 dígitos',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Panel numérico
                  NumericKeypad(
                    onNumberPressed: _onNumberPressed,
                    onDeletePressed: _onDeletePressed,
                  ),
                  const SizedBox(height: 16),
                  // Validación del PIN
                  if (_pin.isNotEmpty && _pin.length != 6)
                    Text(
                      'El PIN debe tener 6 dígitos',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.error,
                          ),
                    ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        onChanged: (value) {
                          setState(() {
                            _rememberMe = value ?? false;
                          });
                        },
                      ),
                      const Text('Recordarme'),
                      const Spacer(),
                    ],
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Iniciar Sesión'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

