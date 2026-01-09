import 'package:flutter/material.dart';
import '../../app/theme/colors.dart';

class EmptyState extends StatelessWidget {
  final String title;
  final String? subtitle;
  const EmptyState({super.key, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.inbox_outlined, size: 48, color: AppColors.subtext),
            const SizedBox(height: 12),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(subtitle!, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.subtext)),
            ],
          ],
        ),
      ),
    );
  }
}
