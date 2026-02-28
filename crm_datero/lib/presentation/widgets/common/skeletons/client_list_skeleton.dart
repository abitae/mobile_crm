import 'package:flutter/material.dart';
import '../skeleton_loader.dart';

/// Skeleton de carga para la lista de clientes (mismo patrón que Cazador).
class ClientListSkeleton extends StatelessWidget {
  final int itemCount;

  const ClientListSkeleton({super.key, this.itemCount = 6});

  @override
  Widget build(BuildContext context) {
    return SkeletonLoader(
      type: SkeletonType.clientCard,
      itemCount: itemCount,
    );
  }
}
