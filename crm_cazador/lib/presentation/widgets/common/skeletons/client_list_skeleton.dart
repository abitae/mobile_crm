import 'package:flutter/material.dart';
import 'package:crm_cazador/presentation/widgets/common/skeleton_loader.dart';

class ClientListSkeleton extends StatelessWidget {
  const ClientListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: 6,
      itemBuilder: (context, index) {
        return SkeletonLoader(
          child: Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonLoader.rectangular(
                          width: double.infinity,
                          height: 20,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            SkeletonLoader.rectangular(
                              width: 100,
                              height: 14,
                            ),
                            const SizedBox(width: 12),
                            SkeletonLoader.rectangular(
                              width: 120,
                              height: 14,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    children: [
                      SkeletonLoader.rectangular(
                        width: 60,
                        height: 24,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          SkeletonLoader.circular(size: 20),
                          const SizedBox(width: 4),
                          SkeletonLoader.circular(size: 20),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
