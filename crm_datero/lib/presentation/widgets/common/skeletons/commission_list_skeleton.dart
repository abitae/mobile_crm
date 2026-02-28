import 'package:flutter/material.dart';
import '../skeleton_loader.dart';

/// Skeleton de carga para la lista de comisiones.
class CommissionListSkeleton extends StatelessWidget {
  final int itemCount;

  const CommissionListSkeleton({super.key, this.itemCount = 6});

  @override
  Widget build(BuildContext context) {
    return SkeletonLoader(
      type: SkeletonType.commissionCard,
      itemCount: itemCount,
    );
  }
}
