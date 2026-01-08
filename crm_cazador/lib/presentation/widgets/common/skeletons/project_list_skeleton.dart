import 'package:flutter/material.dart';
import 'package:crm_cazador/presentation/widgets/common/skeleton_loader.dart';

class ProjectListSkeleton extends StatelessWidget {
  const ProjectListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: 5,
      itemBuilder: (context, index) {
        return SkeletonLoader(
          child: Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SkeletonLoader.rectangular(
                              width: double.infinity,
                              height: 24,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                SkeletonLoader.rectangular(
                                  width: 60,
                                  height: 20,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                const SizedBox(width: 8),
                                SkeletonLoader.rectangular(
                                  width: 60,
                                  height: 20,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SkeletonLoader.rectangular(
                        width: 60,
                        height: 24,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SkeletonLoader.rectangular(
                    width: double.infinity,
                    height: 14,
                  ),
                  const SizedBox(height: 4),
                  SkeletonLoader.rectangular(
                    width: 200,
                    height: 14,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            SkeletonLoader.circular(size: 20),
                            const SizedBox(height: 4),
                            SkeletonLoader.rectangular(width: 30, height: 16),
                            const SizedBox(height: 2),
                            SkeletonLoader.rectangular(width: 40, height: 12),
                          ],
                        ),
                        Column(
                          children: [
                            SkeletonLoader.circular(size: 20),
                            const SizedBox(height: 4),
                            SkeletonLoader.rectangular(width: 30, height: 16),
                            const SizedBox(height: 2),
                            SkeletonLoader.rectangular(width: 50, height: 12),
                          ],
                        ),
                        Column(
                          children: [
                            SkeletonLoader.circular(size: 20),
                            const SizedBox(height: 4),
                            SkeletonLoader.rectangular(width: 30, height: 16),
                            const SizedBox(height: 2),
                            SkeletonLoader.rectangular(width: 40, height: 12),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SkeletonLoader.rectangular(
                    width: double.infinity,
                    height: 6,
                    borderRadius: BorderRadius.circular(3),
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
