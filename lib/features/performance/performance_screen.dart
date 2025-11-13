import 'package:flutter/material.dart';

import '../../core/localization/localization_extensions.dart';
class PerformanceScreen extends StatelessWidget {
  const PerformanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final stats = [
      (l10n.translate('total_trips'), 1284.0),
      (l10n.translate('completion_rate'), 95.0),
      (l10n.translate('average_rating'), 4.9),
      (l10n.translate('total_distance'), 18230.0),
    ];
    return Scaffold(
      appBar: AppBar(title: Text(l10n.translate('performance'))),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: stats.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemBuilder: (_, index) {
                final item = stats[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item[0] as String),
                      const SizedBox(height: 12),
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: (item[1] as double)),
                        duration: const Duration(milliseconds: 800),
                        builder: (_, value, __) => Text(value.toStringAsFixed(1), style: Theme.of(context).textTheme.titleLarge),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(6, (index) {
                  final height = (index + 1) * 40;
                  return Expanded(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: height.toDouble()),
                      duration: const Duration(milliseconds: 600 + index * 120),
                      builder: (context, value, child) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        height: value,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.75),
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
