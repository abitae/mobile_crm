import 'package:flutter/material.dart';
import 'package:crm_cazador/presentation/widgets/common/skeleton_loader.dart';

class DateroListSkeleton extends StatelessWidget {
  const DateroListSkeleton({super.key});

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
                  SkeletonLoader.circular(size: 56),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonLoader.rectangular(
                          width: double.infinity,
                          height: 20,
                        ),
                        const SizedBox(height: 8),
                        SkeletonLoader.rectangular(
                          width: 150,
                          height: 14,
                        ),
                        const SizedBox(height: 4),
                        SkeletonLoader.rectangular(
                          width: 120,
                          height: 14,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  SkeletonLoader.rectangular(
                    width: 60,
                    height: 24,
                    borderRadius: BorderRadius.circular(12),
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
