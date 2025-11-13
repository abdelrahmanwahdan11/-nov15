import 'package:flutter/material.dart';

import '../localization/localization_extensions.dart';
import '../utils/models.dart';

class DemandHeatmap extends StatelessWidget {
  const DemandHeatmap({super.key, required this.cells});

  final List<DemandHeatCell> cells;

  static const Map<String, int> _slotPriority = {
    'am': 0,
    'mid': 1,
    'pm': 2,
  };

  @override
  Widget build(BuildContext context) {
    if (cells.isEmpty) {
      return const SizedBox.shrink();
    }
    final l10n = context.l10n;
    final dayLabels = <int, String>{
      1: l10n.translate('weekday_mon'),
      2: l10n.translate('weekday_tue'),
      3: l10n.translate('weekday_wed'),
      4: l10n.translate('weekday_thu'),
      5: l10n.translate('weekday_fri'),
      6: l10n.translate('weekday_sat'),
      7: l10n.translate('weekday_sun'),
    };
    final slotLabels = <String, String>{
      'am': l10n.translate('slot_morning'),
      'mid': l10n.translate('slot_midday'),
      'pm': l10n.translate('slot_evening'),
    };
    final dayIndexes = cells.map((cell) => cell.dayIndex).toSet().toList()
      ..sort();
    final slotKeys = cells.map((cell) => cell.slotKey).toSet().toList()
      ..sort((a, b) => (_slotPriority[a] ?? 0).compareTo(_slotPriority[b] ?? 0));
    final primary = Theme.of(context).colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              const SizedBox(width: 72),
              ...dayIndexes.map(
                (day) => Expanded(
                  child: Text(
                    dayLabels[day] ?? day.toString(),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
            ],
          ),
        ),
        ...slotKeys.map((slot) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 72,
                child: Text(
                  slotLabels[slot] ?? slot,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              ...dayIndexes.map((day) {
                final cell = cells.firstWhere(
                  (element) => element.dayIndex == day && element.slotKey == slot,
                  orElse: () => DemandHeatCell(
                    dayIndex: day,
                    slotKey: slot,
                    intensity: 0.28,
                    potentialTrips: 0,
                  ),
                );
                final intensity = cell.intensity.clamp(0.0, 1.0);
                final color = Color.lerp(
                  primary.withOpacity(0.14),
                  primary,
                  intensity,
                );
                return Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 420),
                    curve: Curves.easeOut,
                    margin: const EdgeInsets.all(6),
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${cell.potentialTrips} ${l10n.translate('rides_short')}',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${(intensity * 100).round()}%',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          );
        }).toList(),
        const SizedBox(height: 12),
        Text(
          l10n.translate('heatmap_hint'),
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7)),
        ),
      ],
    );
  }
}
