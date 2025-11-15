import 'package:flutter/material.dart';

import '../../controllers/innovation_controller.dart';
import '../../core/localization/localization_extensions.dart';
import '../../core/utils/models.dart';
import '../../core/widgets/ai_info_button.dart';
import '../../core/widgets/tag_chip.dart';

class InnovationScreen extends StatefulWidget {
  const InnovationScreen({super.key});

  @override
  State<InnovationScreen> createState() => _InnovationScreenState();
}

class _InnovationScreenState extends State<InnovationScreen> {
  final InnovationController _controller = InnovationController.instance;

  @override
  void initState() {
    super.initState();
    _controller.init();
  }

  Future<void> _onRefresh() async {
    await _controller.refreshPulse();
    await Future<void>.delayed(const Duration(milliseconds: 240));
  }

  Future<void> _handleAdvance(InnovationPrototype prototype) async {
    final l10n = context.l10n;
    await _controller.advancePrototype(prototype.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.translate('innovation_progress_updated'))),
    );
  }

  void _rotateFocus() {
    _controller.rotateFocusLane();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('innovation_lab')),
        actions: [
          ValueListenableBuilder<InnovationPulse>(
            valueListenable: _controller.pulse,
            builder: (context, pulse, _) {
              return AIInfoButton(
                headlineKey: 'innovation_ai_headline',
                insightsBuilder: (locale) {
                  final readiness = (pulse.readiness * 100).toStringAsFixed(0);
                  final temperature = (pulse.temperature * 100).toStringAsFixed(0);
                  final focus = pulse.focusLanes.isEmpty
                      ? '-'
                      : pulse.focusLanes.take(2).join(' · ');
                  return [
                    '${locale.translate('innovation_ready_score_label')}: $readiness%',
                    '${locale.translate('innovation_temperature')}: $temperature%',
                    '${locale.translate('innovation_focus_lane_label')}: $focus',
                    locale
                        .translate('innovation_next_review_on')
                        .replaceAll('{slot}', pulse.nextReview),
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
            ValueListenableBuilder<InnovationPulse>(
              valueListenable: _controller.pulse,
              builder: (context, pulse, _) {
                return _PulseCard(
                  pulse: pulse,
                  onRotate: _rotateFocus,
                );
              },
            ),
            const SizedBox(height: 24),
            ValueListenableBuilder<List<InnovationPrototype>>(
              valueListenable: _controller.prototypes,
              builder: (context, prototypes, _) {
                return _PrototypeSection(
                  prototypes: prototypes,
                  onAdvance: _handleAdvance,
                );
              },
            ),
            const SizedBox(height: 24),
            StreamBuilder<List<InnovationExperiment>>(
              stream: _controller.experimentStream,
              builder: (context, snapshot) {
                final experiments = snapshot.data ?? <InnovationExperiment>[];
                return _ExperimentSection(experiments: experiments);
              },
            ),
            const SizedBox(height: 24),
            ValueListenableBuilder<List<InnovationBlueprint>>(
              valueListenable: _controller.blueprints,
              builder: (context, blueprints, _) {
                return _BlueprintSection(blueprints: blueprints);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PulseCard extends StatelessWidget {
  const _PulseCard({required this.pulse, required this.onRotate});

  final InnovationPulse pulse;
  final VoidCallback onRotate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final readiness = (pulse.readiness * 100).clamp(0, 100).toStringAsFixed(0);
    final temperature = (pulse.temperature * 100).clamp(0, 100).toStringAsFixed(0);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 320),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withOpacity(0.14),
            theme.colorScheme.primary.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
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
                    Text(
                      l10n.translate('innovation_pulse_card'),
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      pulse.headline,
                      style: theme.textTheme.headlineSmall,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: l10n.translate('innovation_rotate_focus'),
                onPressed: onRotate,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _PulseMetric(
                  label: l10n.translate('innovation_readiness'),
                  value: '$readiness%',
                  progress: pulse.readiness.clamp(0.0, 1.0),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _PulseMetric(
                  label: l10n.translate('innovation_temperature'),
                  value: '$temperature%',
                  progress: pulse.temperature.clamp(0.0, 1.0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.schedule, size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                l10n.translate('innovation_next_review_on').replaceAll('{slot}', pulse.nextReview),
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            l10n.translate('innovation_focus_lanes'),
            style: theme.textTheme.labelLarge,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: pulse.focusLanes
                .map((lane) => TagChip(label: lane))
                .toList(),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.translate('innovation_energy_bursts'),
            style: theme.textTheme.labelLarge,
          ),
          const SizedBox(height: 8),
          ...pulse.energyBursts.map(
            (burst) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.auto_awesome, size: 18, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      burst,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PulseMetric extends StatelessWidget {
  const _PulseMetric({required this.label, required this.value, required this.progress});

  final String label;
  final String value;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelLarge),
        const SizedBox(height: 4),
        LinearProgressIndicator(value: progress, minHeight: 6),
        const SizedBox(height: 4),
        Text(value, style: theme.textTheme.bodyMedium),
      ],
    );
  }
}

class _PrototypeSection extends StatelessWidget {
  const _PrototypeSection({required this.prototypes, required this.onAdvance});

  final List<InnovationPrototype> prototypes;
  final Future<void> Function(InnovationPrototype prototype) onAdvance;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.translate('innovation_pipeline'), style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        if (prototypes.isEmpty)
          Text(l10n.translate('innovation_no_prototypes'), style: theme.textTheme.bodyMedium)
        else
          ...prototypes.map(
            (prototype) => _PrototypeCard(
              prototype: prototype,
              onAdvance: () => onAdvance(prototype),
            ),
          ),
      ],
    );
  }
}

class _PrototypeCard extends StatelessWidget {
  const _PrototypeCard({required this.prototype, required this.onAdvance});

  final InnovationPrototype prototype;
  final VoidCallback onAdvance;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final progress = (prototype.progress * 100).clamp(0, 100).toStringAsFixed(0);
    final confidence = (prototype.confidence * 100).clamp(0, 100).toStringAsFixed(0);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(prototype.title, style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(prototype.summary, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 12),
          LinearProgressIndicator(value: prototype.progress.clamp(0.0, 1.0), minHeight: 6),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _PrototypeStat(
                  label: l10n.translate('innovation_stage'),
                  value: prototype.stage,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _PrototypeStat(
                  label: l10n.translate('innovation_confidence'),
                  value: '$confidence%',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: prototype.tags.map((tag) => TagChip(label: tag)).toList(),
          ),
          const SizedBox(height: 12),
          Text(
            '${l10n.translate('innovation_next_step')}: ${prototype.nextStep}',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 6),
          Text(
            '${l10n.translate('innovation_last_note')}: ${prototype.lastNote}',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.tonalIcon(
              onPressed: onAdvance,
              icon: const Icon(Icons.auto_fix_high),
              label: Text(l10n.translate('innovation_advance')),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrototypeStat extends StatelessWidget {
  const _PrototypeStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelMedium),
        const SizedBox(height: 4),
        Text(value, style: theme.textTheme.bodyMedium),
      ],
    );
  }
}

class _ExperimentSection extends StatelessWidget {
  const _ExperimentSection({required this.experiments});

  final List<InnovationExperiment> experiments;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.translate('innovation_experiment_grid'), style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        if (experiments.isEmpty)
          Text(l10n.translate('innovation_no_experiments'), style: theme.textTheme.bodyMedium)
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: experiments
                  .map(
                    (experiment) => _ExperimentCard(experiment: experiment),
                  )
                  .toList(),
            ),
          ),
      ],
    );
  }
}

class _ExperimentCard extends StatelessWidget {
  const _ExperimentCard({required this.experiment});

  final InnovationExperiment experiment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final confidence = (experiment.confidence * 100).clamp(0, 100).toStringAsFixed(0);
    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(experiment.title, style: theme.textTheme.titleSmall),
          const SizedBox(height: 6),
          Text(experiment.hypothesis, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 12),
          Text('${l10n.translate('status')}: ${experiment.status}', style: theme.textTheme.bodySmall),
          const SizedBox(height: 4),
          Text('${l10n.translate('metric')}: ${experiment.metric}', style: theme.textTheme.bodySmall),
          const SizedBox(height: 4),
          Text('${l10n.translate('innovation_confidence')}: $confidence%', style: theme.textTheme.bodySmall),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.insights, size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(experiment.signal, style: theme.textTheme.bodyMedium),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BlueprintSection extends StatelessWidget {
  const _BlueprintSection({required this.blueprints});

  final List<InnovationBlueprint> blueprints;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.translate('innovation_blueprint_deck'), style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        if (blueprints.isEmpty)
          Text(l10n.translate('innovation_no_blueprints'), style: theme.textTheme.bodyMedium)
        else
          ...blueprints.map((blueprint) => _BlueprintCard(blueprint: blueprint)),
      ],
    );
  }
}

class _BlueprintCard extends StatelessWidget {
  const _BlueprintCard({required this.blueprint});

  final InnovationBlueprint blueprint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final readiness = (blueprint.readiness * 100).clamp(0, 100).toStringAsFixed(0);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: theme.colorScheme.surfaceVariant.withOpacity(0.35),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(blueprint.title, style: theme.textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(blueprint.description, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.person_outline, size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '${l10n.translate('innovation_owner')}: ${blueprint.owner}',
                  style: theme.textTheme.bodySmall,
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.timeline, size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 6),
              Text(
                '${l10n.translate('innovation_horizon')}: ${blueprint.horizon}',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(value: blueprint.readiness.clamp(0.0, 1.0), minHeight: 6),
          const SizedBox(height: 6),
          Text(
            '${l10n.translate('innovation_readiness')}: $readiness%',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: blueprint.phases
                .map((phase) => TagChip(label: phase))
                .toList(),
          ),
        ],
      ),
    );
  }
}
