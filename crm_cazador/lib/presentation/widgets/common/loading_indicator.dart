import 'package:flutter/material.dart';
import 'package:crm_cazador/presentation/widgets/common/skeleton_loader.dart';

/// Widget de carga
class LoadingIndicator extends StatelessWidget {
  final bool isLoading;
  final Widget? child;
  final Widget? skeleton;

  const LoadingIndicator({
    super.key,
    this.isLoading = true,
    this.child,
    this.skeleton,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return skeleton ?? const Center(child: CircularProgressIndicator());
    }
    return child ?? const SizedBox.shrink();
  }
}

