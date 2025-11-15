import 'package:flutter/material.dart';

import '../../controllers/odyssey_controller.dart';
import '../../core/localization/localization_extensions.dart';
import '../../core/utils/models.dart';
import '../../core/widgets/ai_info_button.dart';

class OdysseyScreen extends StatefulWidget {
  const OdysseyScreen({super.key});

  @override
  State<OdysseyScreen> createState() => _OdysseyScreenState();
}

class _OdysseyScreenState extends State<OdysseyScreen> {
  final OdysseyController _controller = OdysseyController.instance;

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
        title: Text(l10n.translate('odyssey_studio')),
        actions: [
          AIInfoButton(
            headlineKey: 'odyssey_ai_headline',
            insightsBuilder: (localL10n) {
              final pulse = _controller.pulse.value;
              final rhythm = (pulse.rhythm * 100).clamp(0, 100).toInt();
              final momentum = (pulse.momentum * 100).clamp(0, 100).toInt();
              return [
                '${localL10n.translate('odyssey_focus_chip')}: ${pulse.focus}',
                '${localL10n.translate('odyssey_rhythm')}: $rhythm%',
                '${localL10n.translate('odyssey_momentum')}: $momentum%',
                '${localL10n.translate('odyssey_milestone_chip')}: ${pulse.nextMilestone}',
                pulse.storyBeat,
              ];
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _controller.refreshPulse(),
        icon: const Icon(Icons.auto_awesome),
        label: Text(l10n.translate('odyssey_refresh')),
      ),
      body: ValueListenableBuilder<OdysseyPulse>(
        valueListenable: _controller.pulse,
        builder: (context, pulse, _) {
          return RefreshIndicator(
            onRefresh: () => _controller.refreshPulse(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24),
              children: [
                Text(l10n.translate('odyssey_intro'),
                    style: theme.textTheme.bodyLarge),
                const SizedBox(height: 16),
                _OdysseyPulseCard(pulse: pulse),
                const SizedBox(height: 24),
                ValueListenableBuilder<List<OdysseyChapter>>(
                  valueListenable: _controller.chapters,
                  builder: (context, chapters, __) {
                    return _OdysseyChapterSection(
                      chapters: chapters,
                      onFocus: _controller.focusOnChapter,
                    );
                  },
                ),
                const SizedBox(height: 24),
                StreamBuilder<List<OdysseyRoute>>(
                  stream: _controller.routeStream,
                  initialData: const <OdysseyRoute>[],
                  builder: (context, snapshot) {
                    final routes = snapshot.data ?? const <OdysseyRoute>[];
                    return _OdysseyRouteSection(
                      routes: routes,
                      onToggle: _controller.toggleRoute,
                    );
                  },
                ),
                const SizedBox(height: 24),
                StreamBuilder<List<OdysseyBeacon>>(
                  stream: _controller.beaconStream,
                  initialData: const <OdysseyBeacon>[],
                  builder: (context, snapshot) {
                    final beacons = snapshot.data ?? const <OdysseyBeacon>[];
                    return _OdysseyBeaconSection(
                      beacons: beacons,
                      onToggle: _controller.toggleBeacon,
                    );
                  },
                ),
                const SizedBox(height: 24),
                ValueListenableBuilder<List<OdysseyReflection>>(
                  valueListenable: _controller.reflections,
                  builder: (context, reflections, __) {
                    return _OdysseyReflectionSection(
                      reflections: reflections,
                      onLog: (reflection) => _showReflectionSheet(reflection),
                    );
                  },
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _showReflectionSheet(OdysseyReflection reflection) async {
    final l10n = context.l10n;
    final textController = TextEditingController(text: reflection.lastEntry);
    double energy = reflection.energy;
    String sentiment = reflection.sentiment;
    final sentimentOptions = [
      l10n.translate('odyssey_sentiment_hopeful'),
      l10n.translate('odyssey_sentiment_grounded'),
      l10n.translate('odyssey_sentiment_charged'),
      l10n.translate('odyssey_sentiment_grateful'),
    ];

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final theme = Theme.of(context);
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(reflection.prompt, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 12),
                  TextField(
                    controller: textController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: l10n.translate('odyssey_reflection_last_entry'),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(l10n.translate('odyssey_reflection_energy_label'),
                      style: theme.textTheme.labelLarge),
                  Slider(
                    value: energy,
                    min: 0,
                    max: 1,
                    divisions: 20,
                    label: '${(energy * 100).round()}%',
                    onChanged: (value) {
                      setModalState(() {
                        energy = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  Text(l10n.translate('odyssey_reflection_sentiment_label'),
                      style: theme.textTheme.labelLarge),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: sentimentOptions.map((option) {
                      final selected = sentiment == option;
                      return ChoiceChip(
                        label: Text(option),
                        selected: selected,
                        onSelected: (_) {
                          setModalState(() {
                            sentiment = option;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child:
                            Text(l10n.translate('odyssey_reflection_cancel')),
                      ),
                      const SizedBox(width: 12),
                      FilledButton(
                        onPressed: () {
                          _controller.logReflection(
                            id: reflection.id,
                            entry: textController.text.trim().isEmpty
                                ? reflection.lastEntry
                                : textController.text.trim(),
                            energy: energy,
                            sentiment: sentiment,
                          );
                          Navigator.of(context).pop();
                        },
                        child: Text(l10n.translate('odyssey_reflection_save')),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _OdysseyPulseCard extends StatelessWidget {
  const _OdysseyPulseCard({required this.pulse});

  final OdysseyPulse pulse;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
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
          Text(pulse.storyBeat, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 16),
          _MetricBar(
            label: l10n.translate('odyssey_rhythm'),
            value: pulse.rhythm,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 12),
          _MetricBar(
            label: l10n.translate('odyssey_momentum'),
            value: pulse.momentum,
            color: theme.colorScheme.secondary,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _PulseChip(
                icon: Icons.explore,
                label:
                    '${l10n.translate('odyssey_focus_chip')}: ${pulse.focus}',
              ),
              _PulseChip(
                icon: Icons.schedule,
                label:
                    '${l10n.translate('odyssey_window_chip')}: ${pulse.window}',
              ),
              _PulseChip(
                icon: Icons.flag,
                label:
                    '${l10n.translate('odyssey_milestone_chip')}: ${pulse.nextMilestone}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricBar extends StatelessWidget {
  const _MetricBar({
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
        Text('$label: $percent%', style: theme.textTheme.labelLarge),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: theme.colorScheme.primary.withOpacity(0.08),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.primary),
          const SizedBox(width: 6),
          Text(label, style: theme.textTheme.labelSmall),
        ],
      ),
    );
  }
}

class _OdysseyChapterSection extends StatelessWidget {
  const _OdysseyChapterSection({
    required this.chapters,
    required this.onFocus,
  });

  final List<OdysseyChapter> chapters;
  final Future<void> Function(String) onFocus;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.translate('odyssey_chapter_section_title'),
            style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: chapters.map((chapter) {
              final isFocus = chapter.isFocus;
              final percent = (chapter.progress * 100).clamp(0, 100).toInt();
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 240,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: isFocus
                        ? theme.colorScheme.primary.withOpacity(0.12)
                        : theme.cardColor,
                    border: Border.all(
                      color: isFocus
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(chapter.title,
                                style: theme.textTheme.titleSmall),
                          ),
                          AnimatedOpacity(
                            duration: const Duration(milliseconds: 200),
                            opacity: isFocus ? 1 : 0.4,
                            child: Icon(Icons.local_fire_department,
                                color: theme.colorScheme.primary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(chapter.motif, style: theme.textTheme.bodySmall),
                      const SizedBox(height: 8),
                      Text(chapter.spotlight,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          )),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: chapter.progress,
                        minHeight: 6,
                        backgroundColor:
                            theme.colorScheme.onSurface.withOpacity(0.08),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text('$percent%', style: theme.textTheme.labelSmall),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => onFocus(chapter.id),
                          child: Text(isFocus
                              ? l10n.translate('odyssey_chapter_focus_active')
                              : l10n.translate('odyssey_chapter_focus_cta')),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _OdysseyRouteSection extends StatelessWidget {
  const _OdysseyRouteSection({
    required this.routes,
    required this.onToggle,
  });

  final List<OdysseyRoute> routes;
  final Future<void> Function(String) onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    if (routes.isEmpty) {
      return Text(l10n.translate('odyssey_routes_empty'),
          style: theme.textTheme.bodyMedium);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.translate('odyssey_routes_section_title'),
            style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        ...routes.map((route) {
          final percent = (route.readiness * 100).clamp(0, 100).toInt();
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: route.tracking
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline.withOpacity(0.2),
                ),
                color: route.tracking
                    ? theme.colorScheme.primary.withOpacity(0.08)
                    : theme.cardColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(route.title,
                            style: theme.textTheme.titleSmall),
                      ),
                      Text(
                        l10n.translate('odyssey_route_stage') + ': ${route.stage}',
                        style: theme.textTheme.labelSmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(route.signal, style: theme.textTheme.bodySmall),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: route.readiness,
                          minHeight: 6,
                          backgroundColor:
                              theme.colorScheme.onSurface.withOpacity(0.08),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text('$percent%', style: theme.textTheme.labelSmall),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${l10n.translate('odyssey_route_distance')} ${route.distance.toStringAsFixed(1)} km',
                        style: theme.textTheme.labelSmall,
                      ),
                      TextButton.icon(
                        onPressed: () => onToggle(route.id),
                        icon: Icon(route.tracking
                            ? Icons.pause_circle
                            : Icons.play_circle_fill),
                        label: Text(route.tracking
                            ? l10n.translate('odyssey_untrack_button')
                            : l10n.translate('odyssey_track_button')),
                      ),
                    ],
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

class _OdysseyBeaconSection extends StatelessWidget {
  const _OdysseyBeaconSection({
    required this.beacons,
    required this.onToggle,
  });

  final List<OdysseyBeacon> beacons;
  final Future<void> Function(String) onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    if (beacons.isEmpty) {
      return Text(l10n.translate('odyssey_beacons_empty'),
          style: theme.textTheme.bodyMedium);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.translate('odyssey_beacons_section_title'),
            style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: beacons.map((beacon) {
            final percent = (beacon.energy * 100).clamp(0, 100).toInt();
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 210,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: beacon.boosted
                    ? theme.colorScheme.secondary.withOpacity(0.12)
                    : theme.cardColor,
                border: Border.all(
                  color: beacon.boosted
                      ? theme.colorScheme.secondary
                      : theme.colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(beacon.title, style: theme.textTheme.titleSmall),
                  const SizedBox(height: 6),
                  Text(beacon.intent, style: theme.textTheme.bodySmall),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: beacon.energy,
                    minHeight: 6,
                    backgroundColor:
                        theme.colorScheme.onSurface.withOpacity(0.08),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      theme.colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text('${l10n.translate('odyssey_beacon_energy')} $percent%',
                      style: theme.textTheme.labelSmall),
                  const SizedBox(height: 8),
                  Text('${l10n.translate('odyssey_beacon_eta')} ${beacon.eta}',
                      style: theme.textTheme.labelSmall),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => onToggle(beacon.id),
                      child: Text(beacon.boosted
                          ? l10n.translate('odyssey_unboost_button')
                          : l10n.translate('odyssey_boost_button')),
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

class _OdysseyReflectionSection extends StatelessWidget {
  const _OdysseyReflectionSection({
    required this.reflections,
    required this.onLog,
  });

  final List<OdysseyReflection> reflections;
  final void Function(OdysseyReflection) onLog;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    if (reflections.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.translate('odyssey_reflection_section_title'),
            style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        ...reflections.map((reflection) {
          final percent = (reflection.energy * 100).clamp(0, 100).toInt();
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: theme.cardColor,
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(reflection.prompt, style: theme.textTheme.titleSmall),
                  const SizedBox(height: 6),
                  Text(reflection.lastEntry,
                      style: theme.textTheme.bodySmall,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${l10n.translate('odyssey_reflection_sentiment_label')}: ${reflection.sentiment}',
                        style: theme.textTheme.labelSmall,
                      ),
                      Text('${percent}%', style: theme.textTheme.labelSmall),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () => onLog(reflection),
                      icon: const Icon(Icons.bubble_chart),
                      label: Text(l10n.translate('odyssey_reflection_log_button')),
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
