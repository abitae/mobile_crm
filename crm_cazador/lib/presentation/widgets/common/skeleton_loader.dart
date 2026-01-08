import 'package:flutter/material.dart';
import 'package:crm_cazador/presentation/widgets/common/shimmer_widget.dart';

class SkeletonLoader extends StatelessWidget {
  final Widget child;
  final bool isLoading;

  const SkeletonLoader({
    super.key,
    required this.child,
    this.isLoading = true,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerWidget(
      isLoading: isLoading,
      child: child,
    );
  }

  static Widget rectangular({
    double width = double.infinity,
    double height = 16,
    BorderRadiusGeometry? borderRadius,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: borderRadius ?? BorderRadius.circular(4),
      ),
    );
  }

  static Widget circular({
    double size = 48,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
    );
  }
}
