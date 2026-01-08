import 'package:flutter/material.dart';
import 'package:crm_cazador/presentation/widgets/common/skeleton_loader.dart';

class ClientFormSkeleton extends StatelessWidget {
  const ClientFormSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...List.generate(8, (index) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonLoader.rectangular(
                      width: 100,
                      height: 16,
                    ),
                    const SizedBox(height: 8),
                    SkeletonLoader.rectangular(
                      width: double.infinity,
                      height: 56,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 24),
          SkeletonLoader.rectangular(
            width: double.infinity,
            height: 48,
            borderRadius: BorderRadius.circular(24),
          ),
        ],
      ),
    );
  }
}
