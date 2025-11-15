import 'package:flutter/material.dart';

import '../localization/localization_extensions.dart';

class GoalProgressCard extends StatefulWidget {
  const GoalProgressCard({
    super.key,
    required this.goal,
    required this.progress,
    required this.onGoalChanged,
  });

  final int goal;
  final int progress;
  final ValueChanged<int> onGoalChanged;

  @override
  State<GoalProgressCard> createState() => _GoalProgressCardState();
}

class _GoalProgressCardState extends State<GoalProgressCard> {
  late double _draftGoal;

  @override
  void initState() {
    super.initState();
    _draftGoal = widget.goal.toDouble();
  }

  @override
  void didUpdateWidget(covariant GoalProgressCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.goal != widget.goal) {
      _draftGoal = widget.goal.toDouble();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final goalValue = _draftGoal.round().clamp(200, 2000);
    final safeGoal = goalValue == 0 ? 1 : goalValue;
    final ratio = (widget.progress / safeGoal).clamp(0.0, 1.0);
    final remaining = (goalValue - widget.progress).clamp(0, goalValue);
    final estimatedTrips = remaining <= 0 ? 0 : (remaining / 22).ceil();
    final estimatedMinutes = estimatedTrips * 18;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.translate('weekly_goal'),
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.translate('goal_progress'),
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              Chip(
                label: Text('\$${goalValue.toString()}'),
                backgroundColor: theme.colorScheme.primary.withOpacity(0.12),
                labelStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 140,
                  height: 140,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: ratio),
                    duration: const Duration(milliseconds: 620),
                    curve: Curves.easeOut,
                    builder: (context, value, _) {
                      return CircularProgressIndicator(
                        value: value,
                        strokeWidth: 12,
                        backgroundColor:
                            theme.colorScheme.primary.withOpacity(0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.primary,
                        ),
                      );
                    },
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '\$${widget.progress}',
                      style: theme.textTheme.titleLarge,
                    ),
                    Text(
                      '${(ratio * 100).round()}%',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${l10n.translate('goal_recommendation')} \$${goalValue.toString()}',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          Text(
            estimatedTrips == 0
                ? l10n.translate('goal_reached')
                : '${l10n.translate('target_reach_estimate')} $estimatedTrips ${l10n.translate('rides_short')} • $estimatedMinutes ${l10n.translate('minutes_short')}',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          Slider(
            value: _draftGoal,
            min: 300,
            max: 1500,
            divisions: 12,
            label: '\$${goalValue.toString()}',
            onChanged: (value) {
              setState(() {
                _draftGoal = value;
              });
            },
            onChangeEnd: (value) {
              widget.onGoalChanged(value.round());
            },
            activeColor: theme.colorScheme.primary,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              l10n.translate('adjust_goal'),
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
