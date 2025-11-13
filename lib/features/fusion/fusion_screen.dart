import 'package:flutter/material.dart';

import '../../controllers/fusion_controller.dart';
import '../../core/localization/localization_extensions.dart';
import '../../core/utils/models.dart';
import '../../core/widgets/ai_info_button.dart';

class FusionScreen extends StatefulWidget {
  const FusionScreen({super.key});

  @override
  State<FusionScreen> createState() => _FusionScreenState();
}

class _FusionScreenState extends State<FusionScreen> {
  final FusionController _controller = FusionController.instance;

  @override
  void initState() {
    super.initState();
    _controller.init();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('fusion_studio')),
        actions: [
          AIInfoButton(
            headlineKey: 'fusion_ai_headline',
            insightsBuilder: (localL10n) {
              final pulse = _controller.pulse.value;
              final alignment = (pulse.alignment * 100).clamp(0, 100).toInt();
              final cohesion = (pulse.cohesion * 100).clamp(0, 100).toInt();
              return [
                '${localL10n.translate('fusion_focus_label')}: ${pulse.focus}',
                '${localL10n.translate('fusion_alignment')}: $alignment%',
                '${localL10n.translate('fusion_cohesion')}: $cohesion%',
                '${localL10n.translate('fusion_next_sync')}: ${pulse.nextSync}',
                pulse.highlight,
              ];
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _controller.refreshPulse(),
        icon: const Icon(Icons.refresh),
        label: Text(l10n.translate('fusion_refresh')),
      ),
      body: ValueListenableBuilder<FusionPulse>(
        valueListenable: _controller.pulse,
        builder: (context, pulse, _) {
          return RefreshIndicator(
            onRefresh: () => _controller.refreshPulse(),
            child: ListView(
              padding: const EdgeInsets.all(24),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                Text(
                  l10n.translate('fusion_intro'),
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                _FusionPulseCard(pulse: pulse),
                const SizedBox(height: 24),
                _FusionStrandSection(controller: _controller),
                const SizedBox(height: 24),
                _FusionCanvasSection(controller: _controller),
                const SizedBox(height: 24),
                _FusionExperimentSection(controller: _controller),
                const SizedBox(height: 24),
                _FusionSignalSection(controller: _controller),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _FusionPulseCard extends StatelessWidget {
  const _FusionPulseCard({required this.pulse});

  final FusionPulse pulse;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final alignment = pulse.alignment.clamp(0.0, 1.0);
    final cohesion = pulse.cohesion.clamp(0.0, 1.0);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 320),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withOpacity(0.14),
            theme.colorScheme.primary.withOpacity(0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(pulse.headline, style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          Text(pulse.highlight, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 16),
          _PulseMetric(
            label: l10n.translate('fusion_alignment'),
            value: alignment,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 12),
          _PulseMetric(
            label: l10n.translate('fusion_cohesion'),
            value: cohesion,
            color: theme.colorScheme.secondary,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _PulseChip(
                icon: Icons.auto_awesome,
                label:
                    '${l10n.translate('fusion_focus_label')}: ${pulse.focus}',
              ),
              _PulseChip(
                icon: Icons.schedule,
                label:
                    '${l10n.translate('fusion_window_label')}: ${pulse.window}',
              ),
              _PulseChip(
                icon: Icons.sync_alt,
                label:
                    '${l10n.translate('fusion_next_sync')}: ${pulse.nextSync}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PulseMetric extends StatelessWidget {
  const _PulseMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percent = (value * 100).clamp(0, 100).toInt();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '$label: $percent%',
                style: theme.textTheme.labelLarge,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 8,
            backgroundColor: theme.colorScheme.onSurface.withOpacity(0.08),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

class _PulseChip extends StatelessWidget {
  const _PulseChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(label, style: theme.textTheme.labelSmall),
        ],
      ),
    );
  }
}

class _FusionStrandSection extends StatelessWidget {
  const _FusionStrandSection({required this.controller});

  final FusionController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.translate('fusion_strands_title'),
                style: theme.textTheme.titleMedium,
              ),
            ),
            Text(
              l10n.translate('fusion_focus_label'),
              style: theme.textTheme.labelLarge,
            ),
          ],
        ),
        const SizedBox(height: 12),
        ValueListenableBuilder<List<FusionStrand>>(
          valueListenable: controller.strands,
          builder: (context, strands, _) {
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: strands.map((strand) {
                final alignment = (strand.alignment * 100).toStringAsFixed(0);
                final flow = (strand.flow * 100).toStringAsFixed(0);
                return ChoiceChip(
                  labelPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  label: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('${strand.icon} ${strand.title}'),
                      const SizedBox(height: 4),
                      Text(
                        strand.snapshot,
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${l10n.translate('fusion_alignment')}: $alignment% • ${l10n.translate('fusion_flow')}: $flow%',
                        style: theme.textTheme.labelSmall,
                      ),
                    ],
                  ),
                  selected: strand.isFocus,
                  onSelected: (_) => controller.focusStrand(strand.id),
                  selectedColor:
                      theme.colorScheme.primary.withOpacity(0.18),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

class _FusionCanvasSection extends StatelessWidget {
  const _FusionCanvasSection({required this.controller});

  final FusionController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.translate('fusion_canvas_title'),
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        ValueListenableBuilder<List<FusionCanvas>>(
          valueListenable: controller.canvases,
          builder: (context, canvases, _) {
            if (canvases.isEmpty) {
              return Text(l10n.translate('fusion_canvas_empty'));
            }
            return Column(
              children: canvases.map((canvas) {
                final heat = (canvas.heat * 100).clamp(0, 100).toInt();
                final cohesion = (canvas.cohesion * 100).clamp(0, 100).toInt();
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: theme.colorScheme.primary.withOpacity(0.12),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(canvas.title, style: theme.textTheme.titleSmall),
                      const SizedBox(height: 4),
                      Text(canvas.description,
                          style: theme.textTheme.bodySmall),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: canvas.threads
                            .map((thread) => Chip(
                                  label: Text(thread),
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${l10n.translate('fusion_canvas_heat')}: $heat% • ${l10n.translate('fusion_canvas_cohesion')}: $cohesion%',
                        style: theme.textTheme.labelSmall,
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

class _FusionExperimentSection extends StatelessWidget {
  const _FusionExperimentSection({required this.controller});

  final FusionController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.translate('fusion_experiments_title'),
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        StreamBuilder<List<FusionExperiment>>(
          stream: controller.experimentStream,
          builder: (context, snapshot) {
            final experiments = snapshot.data ?? const <FusionExperiment>[];
            if (experiments.isEmpty) {
              return Text(l10n.translate('fusion_experiments_empty'));
            }
            return Column(
              children: experiments.map((experiment) {
                final confidence =
                    (experiment.confidence * 100).clamp(0, 100).toInt();
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: experiment.active
                        ? theme.colorScheme.primary.withOpacity(0.12)
                        : theme.colorScheme.surfaceVariant.withOpacity(0.18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              experiment.title,
                              style: theme.textTheme.titleSmall,
                            ),
                          ),
                          Text(
                            '${l10n.translate('fusion_confidence')}: $confidence%',
                            style: theme.textTheme.labelSmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(experiment.intent,
                          style: theme.textTheme.bodySmall),
                      const SizedBox(height: 8),
                      Text(
                        '${l10n.translate('fusion_stage')}: ${experiment.stage}',
                        style: theme.textTheme.labelSmall,
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: FilledButton.tonalIcon(
                          onPressed: () =>
                              controller.toggleExperiment(experiment.id),
                          icon: Icon(
                            experiment.active
                                ? Icons.pause_circle_outline
                                : Icons.play_circle_outline,
                          ),
                          label: Text(
                            l10n.translate(
                              experiment.active
                                  ? 'fusion_pause'
                                  : 'fusion_activate',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

class _FusionSignalSection extends StatelessWidget {
  const _FusionSignalSection({required this.controller});

  final FusionController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.translate('fusion_signals_title'),
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        StreamBuilder<List<FusionSignal>>(
          stream: controller.signalStream,
          builder: (context, snapshot) {
            final signals = snapshot.data ?? const <FusionSignal>[];
            if (signals.isEmpty) {
              return Text(l10n.translate('fusion_signals_empty'));
            }
            return Column(
              children: signals.map((signal) {
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  leading: CircleAvatar(
                    backgroundColor:
                        theme.colorScheme.primary.withOpacity(0.14),
                    child: Text(
                      signal.urgency.toString(),
                      style: theme.textTheme.titleSmall,
                    ),
                  ),
                  title: Text(signal.title),
                  subtitle: Text(signal.detail),
                  trailing: FilledButton.tonal(
                    onPressed: () => controller.toggleSignalCapture(signal.id),
                    child: Text(
                      l10n.translate(
                        signal.captured
                            ? 'fusion_release'
                            : 'fusion_capture',
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}
