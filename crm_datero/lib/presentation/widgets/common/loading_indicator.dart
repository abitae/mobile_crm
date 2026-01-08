import 'package:flutter/material.dart';
import 'skeleton_loader.dart';

/// Indicador de carga
class LoadingIndicator extends StatelessWidget {
  final SkeletonType? skeletonType;
  final int itemCount;
  final bool useSkeleton;

  const LoadingIndicator({
    super.key,
    this.skeletonType,
    this.itemCount = 3,
    this.useSkeleton = false,
  });

  @override
  Widget build(BuildContext context) {
    if (useSkeleton && skeletonType != null) {
      return SkeletonLoader(
        type: skeletonType!,
        itemCount: itemCount,
      );
    }
    
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}

