import 'package:flutter/material.dart';
import 'package:crm_cazador/presentation/widgets/common/skeleton_loader.dart';

class ClientDetailSkeleton extends StatelessWidget {
  const ClientDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                SkeletonLoader.circular(size: 80),
                const SizedBox(height: 16),
                SkeletonLoader.rectangular(
                  width: 200,
                  height: 24,
                ),
                const SizedBox(height: 8),
                SkeletonLoader.rectangular(
                  width: 150,
                  height: 16,
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLoader.rectangular(
                  width: 120,
                  height: 20,
                ),
                const SizedBox(height: 16),
                ...List.generate(4, (index) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          SkeletonLoader.rectangular(
                            width: 100,
                            height: 16,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: SkeletonLoader.rectangular(
                              height: 16,
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
    );
  }
}
