import 'package:flutter/material.dart';

import '../../controllers/mastery_controller.dart';
import '../../core/localization/localization_extensions.dart';
import '../../core/utils/insight_utils.dart';
import '../../core/utils/models.dart';
import '../../core/widgets/ai_info_button.dart';

class MasteryScreen extends StatefulWidget {
  const MasteryScreen({super.key});

  @override
  State<MasteryScreen> createState() => _MasteryScreenState();
}

class _MasteryScreenState extends State<MasteryScreen> {
  final MasteryController _controller = MasteryController.instance;
  final TextEditingController _reflectionController = TextEditingController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _controller.init().then((_) {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _reflectionController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    await _controller.refreshPulse();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('mastery_studio')),
        actions: [
          ValueListenableBuilder<MasteryPulse>(
            valueListenable: _controller.pulse,
            builder: (context, pulse, _) {
              return ValueListenableBuilder<List<MasteryModule>>(
                valueListenable: _controller.modules,
                builder: (context, modules, __) {
                  final focusModule = modules.firstWhere(
                    (module) => module.isFocus,
                    orElse: () => modules.isEmpty ? null : modules.first,
                  );
                  return AIInfoButton(
                    headlineKey: 'mastery_ai_hint',
                    insightsBuilder: (l10n) => InsightUtils.masteryNudges(
                      l10n,
                      pulse,
                      focusModule,
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _handleRefresh,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(24),
                  children: [
                    ValueListenableBuilder<MasteryPulse>(
                      valueListenable: _controller.pulse,
                      builder: (context, pulse, _) {
                        return _MasteryPulseCard(
                          pulse: pulse,
                          onRefresh: _handleRefresh,
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    ValueListenableBuilder<List<MasteryModule>>(
                      valueListenable: _controller.modules,
                      builder: (context, modules, _) {
                        return _ModuleSection(
                          modules: modules,
                          controller: _controller,
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    StreamBuilder<List<MasteryWorkshop>>(
                      stream: _controller.workshopStream,
                      builder: (context, snapshot) {
                        final workshops = snapshot.data ?? [];
                        return _WorkshopSection(
                          workshops: workshops,
                          controller: _controller,
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    ValueListenableBuilder<List<MasteryBadge>>(
                      valueListenable: _controller.badges,
                      builder: (context, badges, _) {
                        return _BadgeSection(badges: badges);
                      },
                    ),
                    const SizedBox(height: 24),
                    ValueListenableBuilder<List<MasteryReflection>>(
                      valueListenable: _controller.reflections,
                      builder: (context, reflections, _) {
                        return _ReflectionSection(
                          reflections: reflections,
                          controller: _controller,
                          reflectionController: _reflectionController,
                        );
                      },
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _MasteryPulseCard extends StatelessWidget {
  const _MasteryPulseCard({
    required this.pulse,
    required this.onRefresh,
  });

  final MasteryPulse pulse;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 320),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withOpacity(0.16),
            theme.colorScheme.secondary.withOpacity(0.08),
          ],
        ),
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
                      l10n.translate('mastery_quick_header'),
                      style: theme.textTheme.labelLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      pulse.focusTheme,
                      style: theme.textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => onRefresh(),
                tooltip: l10n.translate('mastery_refresh'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _MiniGauge(
                  label: l10n.translate('mastery_progress'),
                  value: pulse.momentum,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MiniGauge(
                  label: l10n.translate('mastery_energy_level'),
                  value: pulse.energy,
                  color: theme.colorScheme.tertiary ?? theme.colorScheme.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '${l10n.translate('mastery_micro_practice')}: ${pulse.microPractice}',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: pulse.pathways
                .map(
                  (path) => Chip(
                    label: Text(path),
                    backgroundColor:
                        theme.colorScheme.primary.withOpacity(0.12),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
          Text(
            pulse.coachNote,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _ModuleSection extends StatelessWidget {
  const _ModuleSection({
    required this.modules,
    required this.controller,
  });

  final List<MasteryModule> modules;
  final MasteryController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.translate('mastery_module_progress_label'),
              style: theme.textTheme.titleMedium,
            ),
            Text(
              l10n.translate('mastery_focus_pathways'),
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...modules.map((module) {
          final progress = module.progress.clamp(0.0, 1.0);
          return AnimatedContainer(
            key: ValueKey<String>(module.id),
            duration: const Duration(milliseconds: 280),
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: module.isFocus
                    ? theme.colorScheme.primary.withOpacity(0.3)
                    : theme.dividerColor.withOpacity(0.1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(module.icon, style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(module.title, style: theme.textTheme.titleMedium),
                          const SizedBox(height: 4),
                          Text(module.subtitle, style: theme.textTheme.bodySmall),
                        ],
                      ),
                    ),
                    FilledButton.tonal(
                      onPressed: () => controller.markLessonComplete(module.id),
                      child: Text(l10n.translate('mastery_mark_lesson')),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(8),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${l10n.translate('mastery_lessons_done')}: ${module.completedLessons}/${module.lessons}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                    Text(
                      '${(progress * 100).toStringAsFixed(0)}%',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '${l10n.translate('mastery_next_action')}: ${module.microPractice}',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => controller.toggleFocus(module.id),
                    icon: Icon(
                      module.isFocus ? Icons.star : Icons.star_outline,
                    ),
                    label: Text(
                      module.isFocus
                          ? l10n.translate('mastery_focus_active')
                          : l10n.translate('mastery_focus_toggle'),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _WorkshopSection extends StatelessWidget {
  const _WorkshopSection({
    required this.workshops,
    required this.controller,
  });

  final List<MasteryWorkshop> workshops;
  final MasteryController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.translate('mastery_workshops_title'),
            style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        ...workshops.map((workshop) {
          return AnimatedContainer(
            key: ValueKey<String>(workshop.id),
            duration: const Duration(milliseconds: 260),
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
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
                          Text(workshop.title,
                              style: theme.textTheme.titleMedium),
                          const SizedBox(height: 4),
                          Text('${workshop.focus} • ${workshop.host}',
                              style: theme.textTheme.bodySmall),
                        ],
                      ),
                    ),
                    FilledButton.tonal(
                      onPressed: () =>
                          controller.toggleWorkshopEnrollment(workshop.id),
                      child: Text(
                        workshop.enrolled
                            ? l10n.translate('mastery_leave')
                            : l10n.translate('mastery_enroll'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(workshop.date, style: theme.textTheme.bodySmall),
                const SizedBox(height: 8),
                Text(workshop.highlight, style: theme.textTheme.bodyMedium),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _BadgeSection extends StatelessWidget {
  const _BadgeSection({required this.badges});

  final List<MasteryBadge> badges;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.translate('mastery_badges_title'),
            style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: badges.map((badge) {
            return AnimatedContainer(
              key: ValueKey<String>(badge.id),
              duration: const Duration(milliseconds: 260),
              width: 160,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: badge.unlocked
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outlineVariant,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(badge.icon, style: const TextStyle(fontSize: 28)),
                  const SizedBox(height: 8),
                  Text(badge.title, style: theme.textTheme.titleSmall),
                  const SizedBox(height: 4),
                  Text(badge.description, style: theme.textTheme.bodySmall),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: badge.progress.clamp(0.0, 1.0),
                    minHeight: 6,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    badge.unlocked
                        ? l10n.translate('mastery_badge_unlocked')
                        : l10n.translate('mastery_badge_locked'),
                    style: theme.textTheme.labelSmall,
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

class _ReflectionSection extends StatefulWidget {
  const _ReflectionSection({
    required this.reflections,
    required this.controller,
    required this.reflectionController,
  });

  final List<MasteryReflection> reflections;
  final MasteryController controller;
  final TextEditingController reflectionController;

  @override
  State<_ReflectionSection> createState() => _ReflectionSectionState();
}

class _ReflectionSectionState extends State<_ReflectionSection> {
  bool _submitting = false;

  Future<void> _handleSubmit(BuildContext context) async {
    final message = widget.reflectionController.text;
    if (message.trim().isEmpty) {
      return;
    }
    setState(() {
      _submitting = true;
    });
    await widget.controller.logReflection(message);
    if (mounted) {
      setState(() {
        _submitting = false;
        widget.reflectionController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final reflections = widget.reflections;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.translate('mastery_reflections_title'),
            style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        TextField(
          controller: widget.reflectionController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: l10n.translate('mastery_reflection_placeholder'),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton(
            onPressed: _submitting ? null : () => _handleSubmit(context),
            child: _submitting
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.translate('mastery_save_reflection')),
          ),
        ),
        const SizedBox(height: 12),
        if (reflections.isEmpty)
          Text(l10n.translate('mastery_empty_reflections'),
              style: theme.textTheme.bodySmall)
        else
          ...reflections.map((reflection) {
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 4),
              title: Text(reflection.prompt),
              subtitle: Text(reflection.response),
              trailing: Text(
                MaterialLocalizations.of(context).formatShortDate(reflection.timestamp),
                style: theme.textTheme.bodySmall,
              ),
            );
          }),
      ],
    );
  }
}

class _MiniGauge extends StatelessWidget {
  const _MiniGauge({
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.bodySmall),
        const SizedBox(height: 6),
        Container(
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: color.withOpacity(0.18),
          ),
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: value.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text('${(value.clamp(0.0, 1.0) * 100).toStringAsFixed(0)}%',
            style: theme.textTheme.labelSmall),
      ],
    );
  }
}
