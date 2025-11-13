import 'package:flutter/material.dart';

import '../../controllers/insight_controller.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/localization/localization_extensions.dart';
import '../../core/utils/dummy_data.dart';
import '../../core/utils/models.dart';
import '../../core/widgets/demand_heatmap.dart';
import '../../core/widgets/goal_progress_card.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  final InsightController _controller = InsightController.instance;
  late Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = _controller.init();
  }

  Future<void> _handleRefresh() async {
    await _controller.regenerateInsights();
  }

  Future<void> _handleGoalChanged(int value) async {
    await _controller.updateWeeklyGoal(value);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.translate('goal_updated'))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('insights_center')),
      ),
      body: FutureBuilder<void>(
        future: _initFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          return RefreshIndicator(
            onRefresh: _handleRefresh,
            child: ListView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              padding: const EdgeInsets.all(24),
              children: [
                ValueListenableBuilder<int>(
                  valueListenable: _controller.weeklyGoal,
                  builder: (context, goal, _) {
                    return ValueListenableBuilder<int>(
                      valueListenable: _controller.weeklyProgress,
                      builder: (context, progress, __) {
                        return GoalProgressCard(
                          goal: goal,
                          progress: progress,
                          onGoalChanged: _handleGoalChanged,
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 28),
                _SectionHeader(title: l10n.translate('focus_areas')),
                const SizedBox(height: 12),
                StreamBuilder<List<FocusAreaSnapshot>>(
                  stream: _controller.focusStream,
                  initialData: dummyFocusSnapshots,
                  builder: (context, snapshot) {
                    final focus = snapshot.data ?? [];
                    if (focus.isEmpty) {
                      return Text(l10n.translate('no_rides_available'));
                    }
                    return SizedBox(
                      height: 176,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          final item = focus[index];
                          return _FocusCard(item: item);
                        },
                        separatorBuilder: (_, __) => const SizedBox(width: 16),
                        itemCount: focus.length,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 28),
                _SectionHeader(title: l10n.translate('demand_heatmap')),
                const SizedBox(height: 12),
                StreamBuilder<List<DemandHeatCell>>(
                  stream: _controller.heatmapStream,
                  initialData: dummyDemandHeatCells,
                  builder: (context, snapshot) {
                    final cells = snapshot.data ?? [];
                    if (cells.isEmpty) {
                      return Text(l10n.translate('no_rides_available'));
                    }
                    return DemandHeatmap(cells: cells);
                  },
                ),
                const SizedBox(height: 28),
                _SectionHeader(title: l10n.translate('trend_pulses')),
                const SizedBox(height: 12),
                StreamBuilder<List<DemandPulse>>(
                  stream: _controller.pulsesStream,
                  initialData: dummyDemandPulses,
                  builder: (context, snapshot) {
                    final pulses = snapshot.data ?? [];
                    if (pulses.isEmpty) {
                      return Text(l10n.translate('no_rides_available'));
                    }
                    return Column(
                      children: pulses
                          .map(
                            (pulse) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: _PulseTile(pulse: pulse),
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.center,
                  child: TextButton.icon(
                    onPressed: _handleRefresh,
                    icon: const Icon(Icons.refresh),
                    label: Text(l10n.translate('refresh_insights')),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium,
    );
  }
}

class _FocusCard extends StatelessWidget {
  const _FocusCard({required this.item});

  final FocusAreaSnapshot item;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final demand = (item.demandScore * 100).round();
    return Container(
      width: 220,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.area, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(item.window, style: theme.textTheme.bodyMedium),
          const Spacer(),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(
                avatar: const Icon(Icons.local_fire_department, size: 18),
                label: Text('$demand%'),
                backgroundColor: theme.colorScheme.primary.withOpacity(0.12),
                labelStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
              Chip(
                avatar: const Icon(Icons.directions_car, size: 18),
                label:
                    Text('${item.rideCount} ${l10n.translate('rides_short')}'),
              ),
              Chip(
                avatar: const Icon(Icons.trending_up, size: 18),
                label: Text('${l10n.translate('surge_multiplier_label')}: ${item.surge.toStringAsFixed(2)}x'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PulseTile extends StatelessWidget {
  const _PulseTile({required this.pulse});

  final DemandPulse pulse;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final changePercent = (pulse.change * 100).toStringAsFixed(0);
    final direction = _directionLabel(l10n, pulse.direction);
    final directionIcon = pulse.direction == TrendDirection.up
        ? Icons.arrow_upward
        : pulse.direction == TrendDirection.down
            ? Icons.arrow_downward
            : Icons.trending_flat;
    final color = pulse.direction == TrendDirection.down
        ? theme.colorScheme.error
        : theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(directionIcon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pulse.area,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  pulse.window,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  '$direction • $changePercent%',
                  style: theme.textTheme.bodySmall?.copyWith(color: color),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${pulse.potentialTrips} ${l10n.translate('rides_short')}',
                style: theme.textTheme.bodyMedium,
              ),
              Text(
                '${pulse.focusMinutes} ${l10n.translate('minutes_short')}',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _directionLabel(AppLocalizations l10n, TrendDirection direction) {
    switch (direction) {
      case TrendDirection.up:
        return l10n.translate('trend_rising');
      case TrendDirection.down:
        return l10n.translate('trend_cooling');
      case TrendDirection.steady:
        return l10n.translate('trend_flat');
    }
  }
}
