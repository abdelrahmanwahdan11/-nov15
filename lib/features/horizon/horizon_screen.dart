import 'package:flutter/material.dart';

import '../../controllers/horizon_controller.dart';
import '../../core/localization/localization_extensions.dart';
import '../../core/utils/models.dart';
import '../../core/widgets/ai_info_button.dart';
import '../../core/widgets/tag_chip.dart';

class HorizonScreen extends StatefulWidget {
  const HorizonScreen({super.key});

  @override
  State<HorizonScreen> createState() => _HorizonScreenState();
}

class _HorizonScreenState extends State<HorizonScreen> {
  final HorizonController _controller = HorizonController.instance;

  @override
  void initState() {
    super.initState();
    _controller.init();
  }

  Future<void> _onRefresh() async {
    await _controller.refreshPulse();
    await Future<void>.delayed(const Duration(milliseconds: 240));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('horizon_studio')),
        actions: [
          ValueListenableBuilder<HorizonPulse>(
            valueListenable: _controller.pulse,
            builder: (context, pulse, _) {
              return AIInfoButton(
                headlineKey: 'horizon_ai_headline',
                insightsBuilder: (locale) {
                  final alignment = (pulse.alignment * 100).toStringAsFixed(0);
                  final confidence = (pulse.confidence * 100).toStringAsFixed(0);
                  final themes = pulse.focusThemes.join(' · ');
                  final highlights = pulse.signalHighlights.join(' · ');
                  return [
                    '${locale.translate('horizon_ai_alignment')}: $alignment%',
                    '${locale.translate('horizon_ai_confidence')}: $confidence%',
                    '${locale.translate('horizon_ai_focus')}: $themes',
                    '${locale.translate('horizon_ai_signals')}: $highlights',
                    locale
                        .translate('horizon_ai_window')
                        .replaceAll('{slot}', pulse.nextWindow),
                    locale
                        .translate('horizon_ai_question')
                        .replaceAll('{question}', pulse.guidingQuestion),
                  ];
                },
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          children: [
            ValueListenableBuilder<HorizonPulse>(
              valueListenable: _controller.pulse,
              builder: (context, pulse, _) {
                return _PulseCard(
                  pulse: pulse,
                  onRaise: _controller.elevateAlignment,
                  onCool: _controller.coolAlignment,
                  onRefresh: _controller.refreshPulse,
                );
              },
            ),
            const SizedBox(height: 24),
            ValueListenableBuilder<List<HorizonScenario>>(
              valueListenable: _controller.scenarios,
              builder: (context, scenarios, _) {
                return _ScenarioDeck(
                  scenarios: scenarios,
                  onFocus: _controller.focusScenario,
                );
              },
            ),
            const SizedBox(height: 24),
            StreamBuilder<List<HorizonRunwayMarker>>(
              stream: _controller.runwayStream,
              builder: (context, snapshot) {
                final markers = snapshot.data ?? <HorizonRunwayMarker>[];
                return _RunwaySection(
                  markers: markers,
                  onToggle: _controller.toggleRunway,
                );
              },
            ),
            const SizedBox(height: 24),
            StreamBuilder<List<HorizonSignal>>(
              stream: _controller.signalStream,
              builder: (context, snapshot) {
                final signals = snapshot.data ?? <HorizonSignal>[];
                return _SignalSection(
                  signals: signals,
                  onToggle: _controller.toggleSignalFlag,
                );
              },
            ),
            const SizedBox(height: 24),
            ValueListenableBuilder<List<HorizonBlueprint>>(
              valueListenable: _controller.blueprints,
              builder: (context, blueprints, _) {
                return _BlueprintSection(
                  blueprints: blueprints,
                  onAdvance: _controller.advanceBlueprint,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PulseCard extends StatelessWidget {
  const _PulseCard({
    required this.pulse,
    required this.onRaise,
    required this.onCool,
    required this.onRefresh,
  });

  final HorizonPulse pulse;
  final Future<void> Function() onRaise;
  final Future<void> Function() onCool;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final alignment = (pulse.alignment * 100).clamp(0, 100).toStringAsFixed(0);
    final confidence = (pulse.confidence * 100).clamp(0, 100).toStringAsFixed(0);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 320),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withOpacity(0.16),
            theme.colorScheme.primary.withOpacity(0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.translate('horizon_pulse_card'),
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Text(
            pulse.headline,
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            children: [
              _MetricTile(
                label: l10n.translate('horizon_alignment'),
                value: '$alignment%',
                icon: Icons.compass_calibration_outlined,
              ),
              _MetricTile(
                label: l10n.translate('horizon_confidence'),
                value: '$confidence%',
                icon: Icons.waves,
              ),
              _MetricTile(
                label: l10n.translate('horizon_runway_days'),
                value: pulse.runwayDays.toString(),
                icon: Icons.route_outlined,
              ),
              _MetricTile(
                label: l10n.translate('horizon_next_window'),
                value: pulse.nextWindow,
                icon: Icons.schedule,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            l10n.translate('horizon_guiding_question'),
            style: theme.textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Text(
            pulse.guidingQuestion,
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          _TagRow(
            title: l10n.translate('horizon_focus_themes'),
            values: pulse.focusThemes,
          ),
          const SizedBox(height: 12),
          _TagRow(
            title: l10n.translate('horizon_signal_highlights'),
            values: pulse.signalHighlights,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: onRaise,
                  icon: const Icon(Icons.trending_up),
                  label: Text(l10n.translate('horizon_raise_alignment')),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed: onCool,
                  icon: const Icon(Icons.ac_unit),
                  label: Text(l10n.translate('horizon_cool_alignment')),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.translate('horizon_refresh_pulse')),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelMedium,
              ),
              Text(
                value,
                style: theme.textTheme.titleMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TagRow extends StatelessWidget {
  const _TagRow({required this.title, required this.values});

  final String title;
  final List<String> values;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: values
              .map((value) => TagChip(label: value, isSelected: false))
              .toList(),
        ),
      ],
    );
  }
}

class _ScenarioDeck extends StatelessWidget {
  const _ScenarioDeck({required this.scenarios, required this.onFocus});

  final List<HorizonScenario> scenarios;
  final Future<void> Function(String id) onFocus;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.translate('horizon_scenarios'), style: theme.textTheme.titleLarge),
        const SizedBox(height: 12),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: scenarios.map((scenario) {
            final probability = (scenario.probability * 100).toStringAsFixed(0);
            final impact = (scenario.impact * 100).toStringAsFixed(0);
            return AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              width: 320,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: scenario.isFocus
                    ? theme.colorScheme.primary.withOpacity(0.12)
                    : theme.colorScheme.surfaceVariant.withOpacity(0.35),
                border: Border.all(
                  color: scenario.isFocus
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline.withOpacity(0.4),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          scenario.title,
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                      if (scenario.isFocus)
                        Icon(Icons.auto_awesome,
                            color: theme.colorScheme.primary),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(scenario.narrative, style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    children: [
                      TagChip(
                        label:
                            '${l10n.translate('horizon_probability')}: $probability%',
                        isSelected: false,
                      ),
                      TagChip(
                        label:
                            '${l10n.translate('horizon_impact')}: $impact%',
                        isSelected: false,
                      ),
                      TagChip(
                        label: scenario.focus,
                        isSelected: scenario.isFocus,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  FilledButton.tonal(
                    onPressed: () => onFocus(scenario.id),
                    child: Text(
                      scenario.isFocus
                          ? l10n.translate('horizon_focus_active')
                          : l10n.translate('horizon_focus_cta'),
                    ),
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

class _RunwaySection extends StatelessWidget {
  const _RunwaySection({required this.markers, required this.onToggle});

  final List<HorizonRunwayMarker> markers;
  final Future<void> Function(String id) onToggle;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.translate('horizon_runway'), style: theme.textTheme.titleLarge),
        const SizedBox(height: 12),
        ...markers.map((marker) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Checkbox(
                value: marker.completed,
                onChanged: (_) => onToggle(marker.id),
              ),
              title: Text(marker.title, style: theme.textTheme.titleMedium),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(marker.notes),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    children: [
                      TagChip(label: marker.timeframe, isSelected: false),
                      TagChip(label: marker.priority, isSelected: marker.completed),
                    ],
                  ),
                ],
              ),
              trailing: IconButton(
                icon: Icon(
                  Icons.check_circle,
                  color: marker.completed
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline,
                ),
                onPressed: () => onToggle(marker.id),
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _SignalSection extends StatelessWidget {
  const _SignalSection({required this.signals, required this.onToggle});

  final List<HorizonSignal> signals;
  final Future<void> Function(String id) onToggle;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.translate('horizon_signals'), style: theme.textTheme.titleLarge),
        const SizedBox(height: 12),
        ...signals.map((signal) {
          final momentum = (signal.momentum * 100).toStringAsFixed(0);
          final confidence = (signal.confidence * 100).toStringAsFixed(0);
          return AnimatedContainer(
            duration: const Duration(milliseconds: 240),
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: signal.flagged
                  ? theme.colorScheme.secondaryContainer
                  : theme.colorScheme.surfaceVariant.withOpacity(0.35),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(signal.title, style: theme.textTheme.titleMedium),
                          const SizedBox(height: 4),
                          Text(signal.description),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => onToggle(signal.id),
                      icon: Icon(
                        signal.flagged
                            ? Icons.push_pin
                            : Icons.push_pin_outlined,
                      ),
                      tooltip: signal.flagged
                          ? l10n.translate('horizon_unflag_signal')
                          : l10n.translate('horizon_flag_signal'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  children: [
                    TagChip(label: signal.category, isSelected: signal.flagged),
                    TagChip(
                      label:
                          '${l10n.translate('horizon_momentum')}: $momentum%',
                      isSelected: false,
                    ),
                    TagChip(
                      label:
                          '${l10n.translate('horizon_confidence')}: $confidence%',
                      isSelected: false,
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _BlueprintSection extends StatelessWidget {
  const _BlueprintSection({required this.blueprints, required this.onAdvance});

  final List<HorizonBlueprint> blueprints;
  final Future<void> Function(String id) onAdvance;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.translate('horizon_blueprints'),
            style: theme.textTheme.titleLarge),
        const SizedBox(height: 12),
        ...blueprints.map((blueprint) {
          final confidence = (blueprint.confidence * 100).toStringAsFixed(0);
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(blueprint.pillar,
                                style: theme.textTheme.labelLarge),
                            const SizedBox(height: 4),
                            Text(blueprint.summary,
                                style: theme.textTheme.titleMedium),
                          ],
                        ),
                      ),
                      FilledButton.tonal(
                        onPressed: () => onAdvance(blueprint.id),
                        child: Text(l10n.translate('horizon_advance_blueprint')),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    children: [
                      TagChip(label: blueprint.owner, isSelected: false),
                      TagChip(label: blueprint.status, isSelected: true),
                      TagChip(
                        label:
                            '${l10n.translate('horizon_confidence')}: $confidence%',
                        isSelected: false,
                      ),
                      TagChip(
                        label:
                            '${l10n.translate('horizon_next_window')}: ${blueprint.nextWindow}',
                        isSelected: false,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(l10n.translate('horizon_actions_label'),
                      style: theme.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  ...blueprint.actions.map(
                    (action) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.check, size: 16),
                          const SizedBox(width: 8),
                          Expanded(child: Text(action)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
