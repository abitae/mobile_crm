import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/services/storage_service.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/ler_logo.dart';
import '../../widgets/common/custom_snackbar.dart';
import '../../widgets/auth/numeric_pin_pad.dart';

const String _keyLastUsername = 'last_username';

/// Pantalla de login con Material 3.
/// Si hay usuario guardado (SharedPreferences), solo se pide PIN con teclado numérico virtual.
/// Al completar 6 dígitos del PIN el teclado se oculta.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _pinFocusNode = FocusNode();

  bool _rememberMe = false;
  bool _isLoading = false;
  /// Usuario guardado en SharedPreferences; si no es null, se muestra solo PIN.
  String? _savedUsername;
  /// En modo solo PIN: true para mostrar el keypad; se pone false al completar 6 dígitos.
  bool _showPinPad = true;

  @override
  void initState() {
    super.initState();
    _savedUsername = StorageService.getString(_keyLastUsername);
    if (_savedUsername != null && _savedUsername!.isEmpty) {
      _savedUsername = null;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateLoadingState();
    });
    _passwordController.addListener(_onPinChanged);
  }

  void _onPinChanged() {
    if (_passwordController.text.length == 6 && _showPinPad) {
      setState(() => _showPinPad = false);
      FocusScope.of(context).unfocus();
    }
  }

  @override
  void dispose() {
    _passwordController.removeListener(_onPinChanged);
    _emailController.dispose();
    _passwordController.dispose();
    _pinFocusNode.dispose();
    super.dispose();
  }

  void _updateLoadingState() {
    if (!mounted) return;
    final notifier = ref.read(authNotifierProvider);
    final newLoadingState = notifier.currentState.isLoading;
    if (_isLoading != newLoadingState) {
      setState(() => _isLoading = newLoadingState);
    }
  }

  void _clearSavedUser() {
    StorageService.remove(_keyLastUsername);
    setState(() {
      _savedUsername = null;
      _emailController.clear();
      _passwordController.clear();
      _showPinPad = true;
    });
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final username = _savedUsername ?? _emailController.text.trim();
    final email = '$username@lotesenremate.pe';
    final pin = _passwordController.text;

    final success = await ref.read(authNotifierProvider).login(
          email: email,
          password: pin,
          rememberMe: _rememberMe,
        );

    _updateLoadingState();

    if (!mounted) return;

    if (success) {
      if (_rememberMe) {
        await StorageService.saveString(_keyLastUsername, username);
      }
      CustomSnackbar.show(
        context,
        'Inicio de sesión exitoso',
        type: SnackbarType.success,
        duration: const Duration(seconds: 1),
      );
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) {
        final notifier = ref.read(authNotifierProvider);
        final currentState = notifier.currentState;
        if (currentState.isAuthenticated || success) {
          context.go('/home');
        }
      }
    } else {
      final authState = ref.read(authProvider);
      CustomSnackbar.show(
        context,
        authState.error ?? 'Error al iniciar sesión',
        type: SnackbarType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.watch(authNotifierProvider);
    final currentLoading = notifier.currentState.isLoading;
    if (_isLoading != currentLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _isLoading = currentLoading);
      });
    }

    final onlyPinMode = _savedUsername != null && _savedUsername!.isNotEmpty;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const LerLogo(
                    height: 100,
                    showTagline: false,
                    appName: 'LER Cazador',
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Bienvenido',
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    onlyPinMode
                        ? 'Ingresa tu PIN de 6 dígitos'
                        : 'Inicia sesión para continuar',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  if (onlyPinMode) ...[
                    // Usuario guardado (solo lectura) + Cambiar usuario
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest
                            .withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .outline
                              .withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.person,
                            size: 22,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '$_savedUsername@lotesenremate.pe',
                              style:
                                  Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        fontWeight: FontWeight.w500,
                                      ),
                            ),
                          ),
                          TextButton(
                            onPressed: _isLoading ? null : _clearSavedUser,
                            child: const Text('Cambiar usuario'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Campo PIN (solo keypad, no teclado del sistema)
                    TextFormField(
                      controller: _passwordController,
                      focusNode: _pinFocusNode,
                      readOnly: true,
                      maxLength: 6,
                      keyboardType: TextInputType.none,
                      obscureText: true,
                      enabled: !_isLoading,
                      decoration: InputDecoration(
                        labelText: 'PIN',
                        hintText: '••••••',
                        counterText: '',
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(6),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingresa tu PIN de 6 dígitos';
                        }
                        if (value.length != 6) {
                          return 'El PIN debe tener 6 dígitos';
                        }
                        return null;
                      },
                      onTap: () {
                        setState(() => _showPinPad = true);
                      },
                    ),
                    const SizedBox(height: 24),
                    if (_showPinPad) ...[
                      NumericPinPad(
                        controller: _passwordController,
                        maxLength: 6,
                        onPinComplete: () {
                          setState(() => _showPinPad = false);
                          FocusScope.of(context).unfocus();
                        },
                      ),
                      const SizedBox(height: 24),
                    ],
                  ] else ...[
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      enabled: !_isLoading,
                      decoration: InputDecoration(
                        labelText: 'Usuario',
                        hintText: 'usuario',
                        helperText:
                            'Se agregará automáticamente @lotesenremate.pe',
                        prefixIcon: const Icon(Icons.person),
                        suffixText: '@lotesenremate.pe',
                        suffixStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa tu usuario';
                        }
                        if (value.contains('@') || value.contains(' ')) {
                          return 'Solo ingresa tu nombre de usuario (sin @ ni espacios)';
                        }
                        final userRegex = RegExp(r'^[a-zA-Z0-9._-]+$');
                        if (!userRegex.hasMatch(value.trim())) {
                          return 'Usuario inválido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      readOnly: true,
                      maxLength: 6,
                      keyboardType: TextInputType.none,
                      obscureText: true,
                      enabled: !_isLoading,
                      decoration: InputDecoration(
                        labelText: 'PIN (6 dígitos)',
                        hintText: '••••••',
                        counterText: '',
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(6),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa tu PIN de 6 dígitos';
                        }
                        if (value.length != 6) {
                          return 'El PIN debe tener 6 dígitos';
                        }
                        return null;
                      },
                      onTap: () {
                        setState(() => _showPinPad = true);
                      },
                    ),
                    const SizedBox(height: 16),
                    if (_showPinPad) ...[
                      NumericPinPad(
                        controller: _passwordController,
                        maxLength: 6,
                        onPinComplete: () {
                          setState(() => _showPinPad = false);
                          FocusScope.of(context).unfocus();
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                    Row(
                      children: [
                        Checkbox(
                          value: _rememberMe,
                          onChanged: (value) {
                            setState(() => _rememberMe = value ?? false);
                          },
                        ),
                        const Text('Recordarme'),
                      ],
                    ),
                  ],

                  if (!onlyPinMode) const SizedBox(height: 8),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
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
