import 'package:flutter/material.dart';
import 'package:crm_cazador/presentation/widgets/common/skeleton_loader.dart';

class ProjectDetailSkeleton extends StatelessWidget {
  const ProjectDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonLoader.rectangular(
            width: double.infinity,
            height: 200,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLoader.rectangular(
                  width: 250,
                  height: 28,
                ),
                const SizedBox(height: 8),
                SkeletonLoader.rectangular(
                  width: 150,
                  height: 16,
                ),
                const SizedBox(height: 24),
                ...List.generate(6, (index) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SkeletonLoader.rectangular(
                            width: 120,
                            height: 16,
                          ),
                          const SizedBox(height: 8),
                          SkeletonLoader.rectangular(
                            width: double.infinity,
                            height: 20,
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
