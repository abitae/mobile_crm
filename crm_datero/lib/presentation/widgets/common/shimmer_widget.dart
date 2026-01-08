import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../theme/app_colors.dart';

/// Widget base para efecto shimmer
class ShimmerWidget extends StatelessWidget {
  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;

  const ShimmerWidget({
    super.key,
    required this.child,
    this.baseColor,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultBaseColor = baseColor ?? 
        theme.colorScheme.surfaceVariant.withOpacity(0.3);
    final defaultHighlightColor = highlightColor ?? 
        theme.colorScheme.surfaceVariant.withOpacity(0.5);

    return Shimmer.fromColors(
      baseColor: defaultBaseColor,
      highlightColor: defaultHighlightColor,
      period: const Duration(milliseconds: 1500),
      child: child,
    );
  }
}

/// Widget de placeholder con shimmer para elementos rectangulares
class ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final Color? color;

  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerWidget(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color ?? AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

/// Widget de placeholder circular con shimmer
class ShimmerCircle extends StatelessWidget {
  final double diameter;
  final Color? color;

  const ShimmerCircle({
    super.key,
    required this.diameter,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerWidget(
      child: Container(
        width: diameter,
        height: diameter,
        decoration: BoxDecoration(
          color: color ?? AppColors.surfaceVariant,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
