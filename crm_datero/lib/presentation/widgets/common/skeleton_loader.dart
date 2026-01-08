import 'package:flutter/material.dart';
import 'shimmer_widget.dart';
import '../../theme/app_colors.dart';

/// Skeleton loader genérico para listas
class SkeletonLoader extends StatelessWidget {
  final SkeletonType type;
  final int itemCount;

  const SkeletonLoader({
    super.key,
    required this.type,
    this.itemCount = 3,
  });

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case SkeletonType.clientCard:
        return _ClientCardSkeleton(itemCount: itemCount);
      case SkeletonType.commissionCard:
        return _CommissionCardSkeleton(itemCount: itemCount);
      case SkeletonType.clientDetail:
        return _ClientDetailSkeleton();
      case SkeletonType.profile:
        return _ProfileSkeleton();
      case SkeletonType.form:
        return _FormSkeleton();
      default:
        return const _DefaultSkeleton();
    }
  }
}

enum SkeletonType {
  clientCard,
  commissionCard,
  clientDetail,
  profile,
  form,
  defaultType,
}

/// Skeleton para tarjeta de cliente
class _ClientCardSkeleton extends StatelessWidget {
  final int itemCount;

  const _ClientCardSkeleton({required this.itemCount});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Avatar circular
                const ShimmerCircle(diameter: 48),
                const SizedBox(width: 16),
                // Información
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const ShimmerBox(width: double.infinity, height: 20),
                      const SizedBox(height: 8),
                      const ShimmerBox(width: 150, height: 16),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const ShimmerBox(width: 100, height: 14),
                          const SizedBox(width: 12),
                          const ShimmerBox(width: 80, height: 14),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Score y badges
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const ShimmerBox(width: 50, height: 24, borderRadius: 6),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const ShimmerCircle(diameter: 20),
                        const SizedBox(width: 4),
                        const ShimmerCircle(diameter: 20),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Skeleton para tarjeta de comisión
class _CommissionCardSkeleton extends StatelessWidget {
  final int itemCount;

  const _CommissionCardSkeleton({required this.itemCount});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShimmerBox(width: double.infinity, height: 20),
                          SizedBox(height: 8),
                          ShimmerBox(width: 120, height: 16),
                        ],
                      ),
                    ),
                    const ShimmerBox(width: 80, height: 28, borderRadius: 14),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShimmerBox(width: 60, height: 14),
                        SizedBox(height: 4),
                        ShimmerBox(width: 100, height: 24),
                      ],
                    ),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        ShimmerBox(width: 50, height: 14),
                        SizedBox(height: 4),
                        ShimmerBox(width: 80, height: 16),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Skeleton para detalle de cliente
class _ClientDetailSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const ShimmerCircle(diameter: 80),
                  const SizedBox(height: 16),
                  const ShimmerBox(width: 200, height: 24),
                  const SizedBox(height: 8),
                  const ShimmerBox(width: 150, height: 16),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const ShimmerBox(width: 80, height: 28, borderRadius: 14),
                      const SizedBox(width: 8),
                      const ShimmerBox(width: 80, height: 28, borderRadius: 14),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Información de contacto
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ShimmerBox(width: 180, height: 20),
                  const SizedBox(height: 16),
                  ...List.generate(3, (index) => const Padding(
                        padding: EdgeInsets.only(bottom: 16.0),
                        child: Row(
                          children: [
                            ShimmerCircle(diameter: 24),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ShimmerBox(width: 80, height: 14),
                                  SizedBox(height: 4),
                                  ShimmerBox(width: double.infinity, height: 18),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton para perfil
class _ProfileSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // QR Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const ShimmerBox(width: 150, height: 20),
                  const SizedBox(height: 16),
                  const ShimmerBox(width: 200, height: 200, borderRadius: 12),
                  const SizedBox(height: 8),
                  const ShimmerBox(width: double.infinity, height: 14),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Información personal
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ShimmerBox(width: 180, height: 20),
                  const SizedBox(height: 16),
                  ...List.generate(3, (index) => const Padding(
                        padding: EdgeInsets.only(bottom: 16.0),
                        child: ShimmerBox(width: double.infinity, height: 56),
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton para formulario
class _FormSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        ...List.generate(5, (index) => Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const ShimmerBox(width: 120, height: 16),
                      const SizedBox(height: 8),
                      const ShimmerBox(width: double.infinity, height: 56),
                    ],
                  ),
                ),
              ),
            )),
      ],
    );
  }
}

/// Skeleton por defecto
class _DefaultSkeleton extends StatelessWidget {
  const _DefaultSkeleton();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const ShimmerCircle(diameter: 64),
          const SizedBox(height: 16),
          const ShimmerBox(width: 200, height: 20),
          const SizedBox(height: 8),
          const ShimmerBox(width: 150, height: 16),
        ],
      ),
    );
  }
}
