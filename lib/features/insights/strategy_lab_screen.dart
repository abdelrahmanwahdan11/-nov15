import 'package:flutter/material.dart';

import '../../controllers/planner_controller.dart';
import '../../core/localization/localization_extensions.dart';
import '../../core/utils/models.dart';

class StrategyLabScreen extends StatefulWidget {
  const StrategyLabScreen({super.key});

  @override
  State<StrategyLabScreen> createState() => _StrategyLabScreenState();
}

class _StrategyLabScreenState extends State<StrategyLabScreen> {
  final PlannerController _controller = PlannerController.instance;
  late Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = _controller.init();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('strategy_lab')),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_graph),
            onPressed: () => _controller.regeneratePlan(),
            tooltip: l10n.translate('planner_regenerate'),
          ),
        ],
      ),
      body: FutureBuilder<void>(
        future: _initFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          return RefreshIndicator(
            onRefresh: _controller.regeneratePlan,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 36),
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              children: [
                ValueListenableBuilder<List<ShiftScenario>>(
                  valueListenable: _controller.scenarios,
                  builder: (_, scenarios, __) {
                    return ValueListenableBuilder<ShiftScenario?>(
                      valueListenable: _controller.activeScenario,
                      builder: (_, active, __) {
                        if (scenarios.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: scenarios.map((scenario) {
                            final selected = active?.id == scenario.id;
                            return ChoiceChip(
                              label: SizedBox(
                                width: 160,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      scenario.title,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      scenario.focusArea,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              selected: selected,
                              onSelected: (_) =>
                                  _controller.selectScenario(scenario.id),
                            );
                          }).toList(),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 20),
                ValueListenableBuilder<ShiftScenario?>(
                  valueListenable: _controller.activeScenario,
                  builder: (_, scenario, __) {
                    if (scenario == null) {
                      return const SizedBox.shrink();
                    }
                    return _ScenarioSummaryCard(scenario: scenario);
                  },
                ),
                const SizedBox(height: 28),
                ValueListenableBuilder<int>(
                  valueListenable: _controller.focusMinutes,
                  builder: (_, minutes, __) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              l10n.translate('planner_focus_label'),
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const Spacer(),
                            Text(
                              '${minutes.toString()} ${l10n.translate('minutes_short')}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                        Slider(
                          value: minutes.toDouble(),
                          min: 120,
                          max: 360,
                          divisions: 8,
                          label: '$minutes',
                          onChanged: (value) =>
                              _controller.updateFocusMinutes(value.round()),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 8),
                ValueListenableBuilder<bool>(
                  valueListenable: _controller.autonomousBoost,
                  builder: (_, boost, __) {
                    return SwitchListTile.adaptive(
                      value: boost,
                      onChanged: (value) => _controller.toggleAutonomous(value),
                      title: Text(l10n.translate('planner_autonomous_mode')),
                      subtitle:
                          Text(l10n.translate('planner_autonomous_hint')),
                    );
                  },
                ),
                const SizedBox(height: 24),
                _SectionLabel(title: l10n.translate('planner_metrics_label')),
                const SizedBox(height: 12),
                StreamBuilder<PlannerSummary>(
                  stream: _controller.summaryStream,
                  builder: (_, snapshot) {
                    final summary = snapshot.data;
                    if (summary == null) {
                      return Text(l10n.translate('no_rides_available'));
                    }
                    return Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        _MetricCard(
                          title: l10n.translate('planner_projected_earnings'),
                          value: '\$${summary.projectedEarnings.round()}',
                          icon: Icons.payments,
                        ),
                        _MetricCard(
                          title: l10n.translate('planner_expected_trips'),
                          value: '${summary.expectedTrips}',
                          icon: Icons.route,
                        ),
                        _MetricCard(
                          title: l10n.translate('planner_avg_demand'),
                          value: '${(summary.averageDemand * 100).round()}%',
                          icon: Icons.local_fire_department,
                        ),
                        _MetricCard(
                          title: l10n.translate('planner_confidence'),
                          value: '${(summary.confidence * 100).round()}%',
                          icon: Icons.shield_moon,
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
                _SectionLabel(title: l10n.translate('planner_timeline')),
                const SizedBox(height: 12),
                StreamBuilder<List<ShiftSegmentPlan>>(
                  stream: _controller.timelineStream,
                  builder: (_, snapshot) {
                    final timeline = snapshot.data ?? [];
                    if (timeline.isEmpty) {
                      return Text(l10n.translate('no_rides_available'));
                    }
                    return Column(
                      children: timeline
                          .map(
                            (segment) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8),
                              child: _TimelineTile(segment: segment),
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
                const SizedBox(height: 24),
                _SectionLabel(title: l10n.translate('planner_actions')),
                const SizedBox(height: 12),
                StreamBuilder<List<MomentumAction>>(
                  stream: _controller.actionsStream,
                  builder: (_, snapshot) {
                    final actions = snapshot.data ?? [];
                    if (actions.isEmpty) {
                      return Text(l10n.translate('no_rides_available'));
                    }
                    return Column(
                      children: actions
                          .map(
                            (action) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8),
                              child: _ActionTile(action: action),
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.center,
                  child: FilledButton.icon(
                    onPressed: () => _controller.regeneratePlan(),
                    icon: const Icon(Icons.refresh),
                    label: Text(l10n.translate('planner_regenerate')),
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

class _ScenarioSummaryCard extends StatelessWidget {
  const _ScenarioSummaryCard({required this.scenario});

  final ShiftScenario scenario;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final riskPercent = (scenario.riskLevel * 100).round();
    return AnimatedContainer(
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            scenario.title,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            scenario.subtitle,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _InfoPill(
                icon: Icons.place,
                label: l10n.translate('planner_focus_area'),
                value: scenario.focusArea,
              ),
              _InfoPill(
                icon: Icons.trending_up,
                label: l10n.translate('planner_surge'),
                value: '${(scenario.surgeBoost * 100).round()}%',
              ),
              _InfoPill(
                icon: Icons.shield,
                label: l10n.translate('planner_risk'),
                value: '$riskPercent%',
              ),
              if (scenario.tags.isNotEmpty)
                _InfoPill(
                  icon: Icons.sell,
                  label: l10n.translate('planner_tags'),
                  value: scenario.tags.join(' • '),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: theme.textTheme.bodySmall),
              Text(
                value,
                style: theme.textTheme.labelLarge,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium,
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 320),
      width: 160,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.07),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(height: 12),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontSize: 20,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _TimelineTile extends StatelessWidget {
  const _TimelineTile({required this.segment});

  final ShiftSegmentPlan segment;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final demand = (segment.demandScore * 100).round();
    return AnimatedContainer(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  segment.label,
                  style: theme.textTheme.titleSmall,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text('$demand%'),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${segment.start} - ${segment.end}',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: segment.demandScore.clamp(0, 1),
              minHeight: 10,
              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
              valueColor:
                  AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${segment.expectedTrips} ${l10n.translate('rides_short')}',
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({required this.action});

  final MomentumAction action;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  action.title,
                  style: theme.textTheme.titleSmall,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(action.category),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            action.description,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Text(
            '${l10n.translate('planner_impact')}: ${action.impact}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
