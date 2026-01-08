import 'package:flutter/material.dart';
import 'package:crm_cazador/presentation/widgets/common/skeleton_loader.dart';

class DateroDetailSkeleton extends StatelessWidget {
  const DateroDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        SkeletonLoader(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
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
        ),
        const SizedBox(height: 16),
        ...List.generate(4, (index) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: SkeletonLoader(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonLoader.rectangular(
                          width: 120,
                          height: 16,
                        ),
                        const SizedBox(height: 12),
                        ...List.generate(3, (i) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  SkeletonLoader.rectangular(
                                    width: 100,
                                    height: 14,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: SkeletonLoader.rectangular(
                                      height: 14,
                                    ),
                                  ),
                                ],
                              ),
                            )),
                      ],
                    ),
                  ),
                ),
              ),
            )),
      ],
    );
  }
}
