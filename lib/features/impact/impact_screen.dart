import 'package:flutter/material.dart';

import '../../controllers/impact_controller.dart';
import '../../core/localization/localization_extensions.dart';
import '../../core/utils/models.dart';
import '../../core/widgets/ai_info_button.dart';
import '../../core/widgets/skeleton_list.dart';

class ImpactScreen extends StatefulWidget {
  const ImpactScreen({super.key});

  @override
  State<ImpactScreen> createState() => _ImpactScreenState();
}

class _ImpactScreenState extends State<ImpactScreen> {
  final ImpactController _controller = ImpactController.instance;
  final Map<String, double> _goalDrafts = <String, double>{};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _controller.init().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
      });
    });
  }

  Future<void> _handleRefresh() async {
    await _controller.refreshPulse();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('impact_studio')),
        actions: [
          IconButton(
            tooltip: l10n.translate('impact_refresh'),
            icon: const Icon(Icons.refresh),
            onPressed: () => _controller.refreshPulse(),
          ),
        ],
      ),
      body: SafeArea(
        child: _loading
            ? const Padding(
                padding: EdgeInsets.all(24),
                child: SkeletonList(),
              )
            : RefreshIndicator(
                onRefresh: _handleRefresh,
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    ValueListenableBuilder<ImpactPulse>(
                      valueListenable: _controller.pulse,
                      builder: (context, pulse, _) {
                        return _ImpactPulseCard(pulse: pulse);
                      },
                    ),
                    const SizedBox(height: 24),
                    ValueListenableBuilder<String>(
                      valueListenable: _controller.focusMode,
                      builder: (context, focus, _) {
                        return _ImpactFocusModes(
                          focus: focus,
                          modes: _controller.focusModes,
                          onSelect: (mode) async {
                            if (mode == focus) {
                              return;
                            }
                            await _controller.setFocus(mode);
                            if (!mounted) {
                              return;
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  l10n.translate('impact_focus_updated'),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    ValueListenableBuilder<List<ImpactGoal>>(
                      valueListenable: _controller.goals,
                      builder: (context, goals, _) {
                        if (goals.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.translate('impact_goals'),
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 12),
                            ...goals.map((goal) {
                              final value = _goalDrafts[goal.id] ?? goal.current;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _ImpactGoalCard(
                                  goal: goal,
                                  value: value,
                                  onChanged: (updated) {
                                    setState(() {
                                      _goalDrafts[goal.id] = updated;
                                    });
                                  },
                                  onChangeEnd: (updated) async {
                                    await _controller.setGoalProgress(
                                      goal.id,
                                      updated,
                                    );
                                    if (!mounted) {
                                      return;
                                    }
                                    setState(() {
                                      _goalDrafts.remove(goal.id);
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          l10n.translate('impact_goal_updated'),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            }).toList(),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    ValueListenableBuilder<List<ImpactInitiative>>(
                      valueListenable: _controller.initiatives,
                      builder: (context, initiatives, _) {
                        if (initiatives.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return _ImpactInitiativesRow(
                          initiatives: initiatives,
                          onToggle: (id) async {
                            await _controller.toggleInitiative(id);
                            if (!mounted) {
                              return;
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  l10n.translate('impact_initiative_joined_toast'),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    StreamBuilder<List<ImpactAction>>(
                      stream: _controller.actionsStream,
                      initialData: _controller.currentActions,
                      builder: (context, snapshot) {
                        final actions = snapshot.data ?? const <ImpactAction>[];
                        if (actions.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return _ImpactActionList(
                          actions: actions,
                          onToggle: (id) async {
                            await _controller.toggleAction(id);
                            if (!mounted) {
                              return;
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  l10n.translate('impact_action_completed_toast'),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    ValueListenableBuilder<List<ImpactRipple>>(
                      valueListenable: _controller.ripples,
                      builder: (context, ripples, _) {
                        if (ripples.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return _ImpactRippleWrap(ripples: ripples);
                      },
                    ),
                    const SizedBox(height: 24),
                    Text(
                      l10n.translate('impact_ai_tip'),
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Theme.of(context).hintColor),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _ImpactPulseCard extends StatelessWidget {
  const _ImpactPulseCard({required this.pulse});

  final ImpactPulse pulse;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 320),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.translate('impact_pulse_title'),
                  style: theme.textTheme.titleLarge,
                ),
              ),
              const AIInfoButton(),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            pulse.message,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _ImpactMetricTile(
                label: l10n.translate('impact_city_label'),
                value: pulse.city,
              ),
              _ImpactMetricTile(
                label: l10n.translate('impact_co2_saved'),
                value: '${pulse.co2Saved.toStringAsFixed(1)} kg',
              ),
              _ImpactMetricTile(
                label: l10n.translate('impact_clean_km'),
                value: '${pulse.cleanKm.toStringAsFixed(0)} km',
              ),
              _ImpactMetricTile(
                label: l10n.translate('impact_renewable_share'),
                value: '${(pulse.renewableShare * 100).toStringAsFixed(0)}%',
              ),
              _ImpactMetricTile(
                label: l10n.translate('impact_streak'),
                value: '${pulse.streakDays} ${l10n.translate('impact_streak_days')}',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            l10n.translate('impact_highlights'),
            style: theme.textTheme.labelLarge,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: pulse.highlights
                .map(
                  (highlight) => Chip(
                    label: Text(highlight, style: theme.textTheme.labelSmall),
                    backgroundColor:
                        theme.colorScheme.primary.withOpacity(0.08),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _ImpactMetricTile extends StatelessWidget {
  const _ImpactMetricTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: theme.colorScheme.primary.withOpacity(0.08),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelSmall),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}

class _ImpactFocusModes extends StatelessWidget {
  const _ImpactFocusModes({
    required this.focus,
    required this.modes,
    required this.onSelect,
  });

  final String focus;
  final List<String> modes;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.translate('impact_focus_modes'),
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: modes
              .map(
                (mode) => ChoiceChip(
                  label: Text(
                    l10n.translate('impact_theme_$mode'),
                  ),
                  selected: focus == mode,
                  onSelected: (_) => onSelect(mode),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _ImpactGoalCard extends StatelessWidget {
  const _ImpactGoalCard({
    required this.goal,
    required this.value,
    required this.onChanged,
    required this.onChangeEnd,
  });

  final ImpactGoal goal;
  final double value;
  final ValueChanged<double> onChanged;
  final ValueChanged<double> onChangeEnd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final trendPercent = (goal.trend * 100).toStringAsFixed(0);
    IconData icon;
    Color color;
    switch (goal.direction) {
      case TrendDirection.up:
        icon = Icons.trending_up;
        color = theme.colorScheme.primary;
        break;
      case TrendDirection.down:
        icon = Icons.trending_down;
        color = theme.colorScheme.error;
        break;
      case TrendDirection.steady:
        icon = Icons.linear_scale;
        color = theme.colorScheme.outline;
        break;
    }
    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  goal.title,
                  style: theme.textTheme.titleMedium,
                ),
              ),
              Icon(icon, color: color),
              const SizedBox(width: 6),
              Text(
                '${goal.trend >= 0 ? '+' : ''}$trendPercent%',
                style: theme.textTheme.labelMedium?.copyWith(color: color),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(goal.description, style: theme.textTheme.bodySmall),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: goal.progress,
            minHeight: 6,
            backgroundColor: theme.colorScheme.primary.withOpacity(0.08),
            valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '${value.toStringAsFixed(0)} / ${goal.target.toStringAsFixed(0)} ${goal.unit}',
                style: theme.textTheme.labelSmall,
              ),
              const Spacer(),
              Text(
                l10n.translate('impact_goal_target'),
                style: theme.textTheme.labelSmall,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Slider(
            value: value.clamp(0, goal.target),
            max: goal.target <= 0 ? 1 : goal.target,
            onChanged: onChanged,
            onChangeEnd: onChangeEnd,
          ),
          Text(
            l10n.translate('impact_goal_progress_hint'),
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _ImpactInitiativesRow extends StatelessWidget {
  const _ImpactInitiativesRow({
    required this.initiatives,
    required this.onToggle,
  });

  final List<ImpactInitiative> initiatives;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.translate('impact_initiatives'),
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: initiatives.map((initiative) {
              final joined = initiative.joined;
              return Container(
                width: 240,
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: joined
                        ? theme.colorScheme.primary
                        : theme.dividerColor.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      initiative.icon,
                      style: const TextStyle(fontSize: 32),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      initiative.title,
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      initiative.subtitle,
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Chip(
                          label: Text(initiative.category),
                        ),
                        const SizedBox(width: 8),
                        Chip(
                          label: Text(
                            '${(initiative.impactScore * 100).toStringAsFixed(0)}%',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      initiative.hours,
                      style: theme.textTheme.labelSmall,
                    ),
                    const Spacer(),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => onToggle(initiative.id),
                        child: Text(
                          joined
                              ? l10n.translate('impact_joined')
                              : l10n.translate('impact_join'),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _ImpactActionList extends StatelessWidget {
  const _ImpactActionList({
    required this.actions,
    required this.onToggle,
  });

  final List<ImpactAction> actions;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.translate('impact_actions'),
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        ...actions.map((action) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: theme.dividerColor.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Checkbox(
                  value: action.completed,
                  onChanged: (_) => onToggle(action.id),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(action.title, style: theme.textTheme.titleSmall),
                      const SizedBox(height: 4),
                      Text(action.description, style: theme.textTheme.bodySmall),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        children: [
                          Chip(label: Text('#${action.tag}')),
                          Chip(
                            label: Text(
                              '${(action.impactValue * 100).toStringAsFixed(0)}%',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  action.completed
                      ? l10n.translate('impact_completed')
                      : l10n.translate('impact_mark_complete'),
                  style: theme.textTheme.labelSmall,
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
}

class _ImpactRippleWrap extends StatelessWidget {
  const _ImpactRippleWrap({required this.ripples});

  final List<ImpactRipple> ripples;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.translate('impact_ripples'),
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: ripples.map((ripple) {
            IconData icon;
            Color color;
            switch (ripple.direction) {
              case TrendDirection.up:
                icon = Icons.arrow_upward;
                color = theme.colorScheme.primary;
                break;
              case TrendDirection.down:
                icon = Icons.arrow_downward;
                color = theme.colorScheme.error;
                break;
              case TrendDirection.steady:
                icon = Icons.horizontal_rule;
                color = theme.colorScheme.outline;
                break;
            }
            return Container(
              width: 200,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ripple.title, style: theme.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Text(
                    '${ripple.value.toStringAsFixed(2)} ${ripple.unit}',
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(icon, size: 16, color: color),
                      const SizedBox(width: 6),
                      Text(
                        '${ripple.change >= 0 ? '+' : ''}${(ripple.change * 100).toStringAsFixed(0)}%',
                        style: theme.textTheme.labelMedium?.copyWith(color: color),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
