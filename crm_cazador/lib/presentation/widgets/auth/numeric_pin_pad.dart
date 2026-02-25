import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Teclado virtual numérico para entrada de PIN (6 dígitos).
/// Al insertar el 6º dígito se invoca [onPinComplete] y el padre puede ocultar el keypad.
class NumericPinPad extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback? onPinComplete;
  final int maxLength;

  const NumericPinPad({
    super.key,
    required this.controller,
    this.onPinComplete,
    this.maxLength = 6,
  });

  void _onDigit(String digit) {
    if (controller.text.length >= maxLength) return;
    final newText = controller.text + digit;
    controller.text = newText;
    if (newText.length == maxLength) {
      onPinComplete?.call();
    }
  }

  void _onBackspace() {
    if (controller.text.isEmpty) return;
    controller.text = controller.text.substring(0, controller.text.length - 1);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _PadButton(label: '1', onTap: () => _onDigit('1'), colorScheme: colorScheme),
              const SizedBox(width: 12),
              _PadButton(label: '2', onTap: () => _onDigit('2'), colorScheme: colorScheme),
              const SizedBox(width: 12),
              _PadButton(label: '3', onTap: () => _onDigit('3'), colorScheme: colorScheme),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _PadButton(label: '4', onTap: () => _onDigit('4'), colorScheme: colorScheme),
              const SizedBox(width: 12),
              _PadButton(label: '5', onTap: () => _onDigit('5'), colorScheme: colorScheme),
              const SizedBox(width: 12),
              _PadButton(label: '6', onTap: () => _onDigit('6'), colorScheme: colorScheme),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _PadButton(label: '7', onTap: () => _onDigit('7'), colorScheme: colorScheme),
              const SizedBox(width: 12),
              _PadButton(label: '8', onTap: () => _onDigit('8'), colorScheme: colorScheme),
              const SizedBox(width: 12),
              _PadButton(label: '9', onTap: () => _onDigit('9'), colorScheme: colorScheme),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(width: 56, height: 56),
              const SizedBox(width: 12),
              _PadButton(label: '0', onTap: () => _onDigit('0'), colorScheme: colorScheme),
              const SizedBox(width: 12),
              _PadButton(
                icon: Icons.backspace_outlined,
                onTap: _onBackspace,
                colorScheme: colorScheme,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PadButton extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final VoidCallback onTap;
  final ColorScheme colorScheme;

  const _PadButton({
    this.label,
    this.icon,
    required this.onTap,
    required this.colorScheme,
  }) : assert(label != null || icon != null);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: SizedBox(
          width: 56,
          height: 56,
          child: Center(
            child: icon != null
                ? Icon(icon, size: 24, color: colorScheme.onSurface)
                : Text(
                    label!,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                  ),
          ),
        ),
      ),
    );
  }
}
