import 'package:flutter/material.dart';

/// Widget para mostrar el logo de Lotesenremate.pe
///
/// Usa la imagen oficial `ler_logo.png` ubicada en `assets/images/ler_logo.png`,
/// que corresponde al mismo logo configurado para Android en
/// `android/assets/images/ler_logo.png`.
class LerLogo extends StatelessWidget {
  final double? height;
  final bool showTagline;
  final String? appName;

  const LerLogo({
    super.key,
    this.height = 120,
    this.showTagline = true,
    this.appName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo oficial desde asset
        Image.asset(
          'assets/images/ler_logo.png',
          height: height,
          fit: BoxFit.contain,
        ),
        if (showTagline || appName != null) ...[
          const SizedBox(height: 8),
          if (showTagline)
            const Text(
              'Somos parte de Tus Sueños',
              textAlign: TextAlign.center,
            ),
          if (appName != null) ...[
            const SizedBox(height: 4),
            Text(
              appName!,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ],
    );
  }
}

