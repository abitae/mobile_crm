import 'package:flutter/material.dart';
import 'package:crm_cazador/presentation/widgets/common/skeleton_loader.dart';

class ReservationListSkeleton extends StatelessWidget {
  const ReservationListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(12.0),
      itemCount: 6,
      itemBuilder: (context, index) {
        return SkeletonLoader(
          child: Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: SkeletonLoader.rectangular(
                          width: double.infinity,
                          height: 20,
                        ),
                      ),
                      const SizedBox(width: 8),
                      SkeletonLoader.rectangular(
                        width: 60,
                        height: 20,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      const SizedBox(width: 6),
                      SkeletonLoader.rectangular(
                        width: 60,
                        height: 20,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      SkeletonLoader.circular(size: 16),
                      const SizedBox(width: 6),
                      SkeletonLoader.rectangular(
                        width: 150,
                        height: 16,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      SkeletonLoader.circular(size: 16),
                      const SizedBox(width: 6),
                      SkeletonLoader.rectangular(
                        width: 200,
                        height: 14,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SkeletonLoader.rectangular(
                              width: 50,
                              height: 12,
                            ),
                            const SizedBox(height: 4),
                            SkeletonLoader.rectangular(
                              width: 80,
                              height: 14,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SkeletonLoader.rectangular(
                              width: 50,
                              height: 12,
                            ),
                            const SizedBox(height: 4),
                            SkeletonLoader.rectangular(
                              width: 80,
                              height: 14,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      SkeletonLoader.circular(size: 14),
                      const SizedBox(width: 4),
                      SkeletonLoader.rectangular(
                        width: 100,
                        height: 16,
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
