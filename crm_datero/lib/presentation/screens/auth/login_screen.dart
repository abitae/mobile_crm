import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/services/storage_service.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_icons.dart';
import '../../widgets/common/ler_logo.dart';
import '../../widgets/common/custom_snackbar.dart';
import '../../widgets/auth/numeric_pin_pad.dart';

const String _keyLastDni = 'last_dni';

/// Pantalla de login.
/// Si hay DNI guardado (Recordarme), solo se pide PIN con teclado numérico virtual.
/// Al completar 6 dígitos del PIN el teclado se oculta.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dniController = TextEditingController();
  final _pinController = TextEditingController();
  final _pinFocusNode = FocusNode();

  bool _rememberMe = false;
  bool _isLoading = false;
  /// DNI guardado; si no es null, se muestra solo PIN.
  String? _savedDni;
  /// En modo solo PIN: true para mostrar el keypad; false al completar 6 dígitos.
  bool _showPinPad = true;

  @override
  void initState() {
    super.initState();
    final saved = StorageService.getString(_keyLastDni);
    if (saved != null && saved.isNotEmpty) _savedDni = saved;
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateLoadingState());
    _pinController.addListener(_onPinChanged);
  }

  void _onPinChanged() {
    if (_pinController.text.length == 6 && _showPinPad) {
      setState(() => _showPinPad = false);
      FocusScope.of(context).unfocus();
    }
  }

  @override
  void dispose() {
    _pinController.removeListener(_onPinChanged);
    _dniController.dispose();
    _pinController.dispose();
    _pinFocusNode.dispose();
    super.dispose();
  }

  void _updateLoadingState() {
    if (!mounted) return;
    final notifier = ref.read(authNotifierProvider);
    final newLoading = notifier.currentState.isLoading;
    if (_isLoading != newLoading) setState(() => _isLoading = newLoading);
  }

  Future<void> _clearSavedUser() async {
    await StorageService.remove(_keyLastDni);
    if (!mounted) return;
    setState(() {
      _savedDni = null;
      _dniController.clear();
      _pinController.clear();
      _showPinPad = true;
    });
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final pin = _pinController.text;
    if (pin.length != 6) {
      CustomSnackbar.show(context, message: 'El PIN debe tener 6 dígitos', type: SnackbarType.error);
      return;
    }

    setState(() => _isLoading = true);

    final dni = _savedDni ?? _dniController.text.trim();
    final success = await ref.read(authNotifierProvider).login(
          dni: dni,
          pin: pin,
          rememberMe: _rememberMe,
        );

    _updateLoadingState();
    if (!mounted) return;

    if (success) {
      if (_rememberMe) await StorageService.saveString(_keyLastDni, dni);
      CustomSnackbar.show(context, message: 'Inicio de sesión exitoso', type: SnackbarType.success, duration: const Duration(seconds: 1));
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) {
        final notifier = ref.read(authNotifierProvider);
        if (notifier.currentState.isAuthenticated || success) context.go('/home');
      }
    } else {
      final authState = ref.read(authProvider);
      CustomSnackbar.show(context, message: authState.error ?? 'Error al iniciar sesión', type: SnackbarType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.watch(authNotifierProvider);
    if (_isLoading != notifier.currentState.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _isLoading = notifier.currentState.isLoading);
      });
    }

    final onlyPinMode = _savedDni != null && _savedDni!.isNotEmpty;

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
                  const LerLogo(height: 90, showTagline: false, appName: 'LER Datero'),
                  const SizedBox(height: 24),
                  Text(
                    'Bienvenido',
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    onlyPinMode ? 'Ingresa tu PIN de 6 dígitos' : 'Inicia sesión para continuar',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  if (onlyPinMode) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.badge_outlined, size: 22, color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'DNI $_savedDni',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
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
                    TextFormField(
                      controller: _pinController,
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
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(6),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Ingresa tu PIN de 6 dígitos';
                        if (value.length != 6) return 'El PIN debe tener 6 dígitos';
                        return null;
                      },
                      onTap: () => setState(() => _showPinPad = true),
                    ),
                    const SizedBox(height: 24),
                    if (_showPinPad) ...[
                      NumericPinPad(
                        controller: _pinController,
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
                      controller: _dniController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      enabled: !_isLoading,
                      decoration: InputDecoration(
                        labelText: 'DNI',
                        hintText: '12345678',
                        prefixIcon: Icon(AppIcons.login),
                        helperText: 'Ingresa tu DNI de 8 dígitos',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(8),
                      ],
                      onChanged: (value) {
                        if (value.length == 8) FocusScope.of(context).unfocus();
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Por favor ingresa tu DNI';
                        if (value.length != 8) return 'El DNI debe tener 8 dígitos';
                        if (!RegExp(r'^\d+$').hasMatch(value)) return 'El DNI solo debe contener números';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _pinController,
                      focusNode: _pinFocusNode,
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
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(6),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Ingresa tu PIN de 6 dígitos';
                        if (value.length != 6) return 'El PIN debe tener 6 dígitos';
                        return null;
                      },
                      onTap: () => setState(() => _showPinPad = true),
                    ),
                    const SizedBox(height: 16),
                    if (_showPinPad) ...[
                      NumericPinPad(
                        controller: _pinController,
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
                          onChanged: (value) => setState(() => _rememberMe = value ?? false),
                        ),
                        const Text('Recordarme'),
                      ],
                    ),
                  ],

                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
