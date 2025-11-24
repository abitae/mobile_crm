import 'package:flutter/material.dart';

/// Sistema de colores Material Design 3
class AppColors {
  // Material Design 3 Color Scheme
  static const Color primary = Color(0xFF2196F3); // Material Blue
  static const Color primaryContainer = Color(0xFFBBDEFB);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFF0D47A1);

  static const Color secondary = Color(0xFF4CAF50); // Material Green
  static const Color secondaryContainer = Color(0xFFC8E6C9);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onSecondaryContainer = Color(0xFF1B5E20);

  static const Color tertiary = Color(0xFFFF9800); // Material Orange
  static const Color tertiaryContainer = Color(0xFFFFE0B2);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color onTertiaryContainer = Color(0xFFE65100);

  // Estado y Semántica
  static const Color error = Color(0xFFB00020);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color onErrorContainer = Color(0xFF410002);

  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);

  // Superficies y Fondos
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F5F5);
  static const Color onSurface = Color(0xFF212121);
  static const Color onSurfaceVariant = Color(0xFF757575);

  static const Color background = Color(0xFFFAFAFA);
  static const Color onBackground = Color(0xFF212121);

  // Outlines y Bordes
  static const Color outline = Color(0xFFBDBDBD);
  static const Color outlineVariant = Color(0xFFE0E0E0);

  // Elevación y Sombras (Material Design elevation)
  static List<BoxShadow> getElevation(int level) {
    switch (level) {
      case 1:
        return [
          BoxShadow(
              color: Colors.black12, blurRadius: 1, offset: Offset(0, 1))
        ];
      case 2:
        return [
          BoxShadow(
              color: Colors.black12, blurRadius: 2, offset: Offset(0, 2))
        ];
      case 3:
        return [
          BoxShadow(
              color: Colors.black26, blurRadius: 4, offset: Offset(0, 4))
        ];
      case 4:
        return [
          BoxShadow(
              color: Colors.black26, blurRadius: 8, offset: Offset(0, 8))
        ];
      default:
        return [];
    }
  }
}

