import 'package:flutter/material.dart';

/// Widget para mostrar el logo de Lotesenremate.pe
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
        // Logo como imagen
        Image.asset(
          'assets/images/ler_logo.png',
          height: height,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            // Fallback si la imagen no se encuentra
            return _buildFallbackLogo(context, theme);
          },
        ),
        // Nombre de la app si se proporciona
        if (appName != null) ...[
          const SizedBox(height: 12),
          Text(
            appName!,
            style: TextStyle(
              fontSize: (height ?? 120) * 0.15,
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ],
    );
  }

  /// Widget de respaldo si la imagen no se puede cargar
  Widget _buildFallbackLogo(BuildContext context, ThemeData theme) {
    const brightGreen = Color(0xFF00C853);
    const darkBlue = Color(0xFF1A237E);

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Icono arquitectónico (estilizado)
        Container(
          height: height,
          width: height! * 0.6,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            children: [
              // Forma azul oscura (vertical)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: height! * 0.25,
                child: Container(
                  decoration: BoxDecoration(
                    color: darkBlue,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      bottomLeft: Radius.circular(8),
                    ),
                  ),
                ),
              ),
              // Forma verde (techo y extensión)
              Positioned(
                left: height! * 0.15,
                top: 0,
                child: Container(
                  width: height! * 0.45,
                  height: height! * 0.4,
                  decoration: BoxDecoration(
                    color: brightGreen,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(8),
                    ),
                  ),
                ),
              ),
              // Línea vertical verde
              Positioned(
                left: height! * 0.15,
                top: height! * 0.4,
                bottom: 0,
                width: height! * 0.1,
                child: Container(
                  color: brightGreen,
                ),
              ),
              // Extensión horizontal verde
              Positioned(
                left: height! * 0.25,
                top: height! * 0.6,
                right: -height! * 0.1,
                height: height! * 0.15,
                child: Container(
                  decoration: BoxDecoration(
                    color: brightGreen,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // Texto "Lotesenremate.pe"
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Lotesenremate.pe',
              style: TextStyle(
                fontSize: height! * 0.25,
                fontWeight: FontWeight.bold,
                color: brightGreen,
                letterSpacing: -0.5,
              ),
            ),
            if (showTagline) ...[
              const SizedBox(height: 4),
              Text(
                'Somos parte de Tus Sueños',
                style: TextStyle(
                  fontSize: height! * 0.12,
                  color: darkBlue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

