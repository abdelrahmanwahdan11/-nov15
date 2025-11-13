import 'package:flutter/material.dart';

import '../../controllers/wellness_controller.dart';
import '../../core/localization/localization_extensions.dart';
import '../../core/utils/models.dart';
import '../../core/widgets/ai_info_button.dart';

class WellnessScreen extends StatefulWidget {
  const WellnessScreen({super.key});

  @override
  State<WellnessScreen> createState() => _WellnessScreenState();
}

class _WellnessScreenState extends State<WellnessScreen> {
  final WellnessController _controller = WellnessController.instance;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await _controller.init();
      if (!mounted) return;
      setState(() {});
    });
  }

  Future<void> _onRefresh() async {
    await _controller.refreshRhythm();
    await Future<void>.delayed(const Duration(milliseconds: 320));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('wellness_studio')),
        actions: [
          AIInfoButton(
            headlineKey: 'wellness_studio',
            insightsBuilder: (localization) => [
              localization.translate('wellness_ai_tip_1'),
              localization.translate('wellness_ai_tip_2'),
              localization.translate('wellness_ai_tip_3'),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          children: [
            _SnapshotPanel(controller: _controller),
            const SizedBox(height: 24),
            _CheckInSection(controller: _controller),
            const SizedBox(height: 16),
            _VibeSelector(controller: _controller),
            const SizedBox(height: 24),
            _SpotlightRitual(controller: _controller),
            const SizedBox(height: 24),
            _BreathDeck(controller: _controller),
            const SizedBox(height: 24),
            _RitualList(controller: _controller),
            const SizedBox(height: 24),
            _RecoveryMoments(controller: _controller),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _SnapshotPanel extends StatelessWidget {
  const _SnapshotPanel({required this.controller});

  final WellnessController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return ValueListenableBuilder<WellnessSnapshot>(
      valueListenable: controller.snapshot,
      builder: (_, snapshot, __) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 360),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary.withOpacity(0.18),
                theme.colorScheme.primary.withOpacity(0.06),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: Image.network(
                    'https://images.unsplash.com/photo-1526401485004-46910ecc8e51?auto=format&fit=crop&w=1200&q=80',
                    fit: BoxFit.cover,
                    color: theme.colorScheme.surface.withOpacity(0.72),
                    colorBlendMode: BlendMode.softLight,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.translate('wellness_intro'),
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 320),
                      child: Text(
                        snapshot.message,
                        key: ValueKey<String>(snapshot.vibe + snapshot.message),
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _AnimatedStat(
                            label: l10n.translate('wellness_alignment'),
                            value: snapshot.alignmentScore,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _AnimatedStat(
                            label: l10n.translate('wellness_energy'),
                            value: snapshot.energyScore,
                            color: theme.colorScheme.secondary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _AnimatedStat(
                            label: l10n.translate('wellness_focus'),
                            value: snapshot.focusScore,
                            color: theme.colorScheme.tertiary ?? theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: snapshot.anchorNotes
                          .map(
                            (note) => Chip(
                              backgroundColor:
                                  theme.colorScheme.primary.withOpacity(0.12),
                              label: Text(
                                note,
                                style: theme.textTheme.bodySmall,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AnimatedStat extends StatelessWidget {
  const _AnimatedStat({
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
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value.clamp(0.0, 1.0)),
      duration: const Duration(milliseconds: 420),
      builder: (_, animated, __) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: theme.textTheme.labelMedium),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: LinearProgressIndicator(
                minHeight: 8,
                value: animated,
                color: color,
                backgroundColor: color.withOpacity(0.18),
              ),
            ),
            const SizedBox(height: 6),
            Text('${(animated * 100).round()}%', style: theme.textTheme.bodySmall),
          ],
        );
      },
    );
  }
}

class _CheckInSection extends StatelessWidget {
  const _CheckInSection({required this.controller});

  final WellnessController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return ValueListenableBuilder<WellnessSnapshot>(
      valueListenable: controller.snapshot,
      builder: (_, snapshot, __) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.translate('wellness_check_in_title'),
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.translate('wellness_check_in_body'),
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              Text(l10n.translate('wellness_energy'), style: theme.textTheme.labelMedium),
              Slider(
                value: snapshot.energyScore.clamp(0.2, 1.0),
                min: 0.2,
                max: 1.0,
                divisions: 8,
                onChanged: controller.updateEnergy,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${(snapshot.energyScore * 100).round()}%',
                  style: theme.textTheme.bodySmall,
                ),
              ),
              const SizedBox(height: 16),
              Text(l10n.translate('wellness_focus'), style: theme.textTheme.labelMedium),
              Slider(
                value: snapshot.focusScore.clamp(0.2, 1.0),
                min: 0.2,
                max: 1.0,
                divisions: 8,
                onChanged: controller.updateFocus,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${(snapshot.focusScore * 100).round()}%',
                  style: theme.textTheme.bodySmall,
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: controller.refreshRhythm,
                  icon: const Icon(Icons.autorenew),
                  label: Text(l10n.translate('reset_rhythm')),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _VibeSelector extends StatelessWidget {
  const _VibeSelector({required this.controller});

  final WellnessController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final options = <String, String>{
      'calm': l10n.translate('vibe_calm'),
      'focus': l10n.translate('vibe_focus'),
      'energize': l10n.translate('vibe_energize'),
    };
    return ValueListenableBuilder<String>(
      valueListenable: controller.vibe,
      builder: (_, active, __) {
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: options.entries.map((entry) {
            final selected = entry.key == active;
            return ChoiceChip(
              label: Text(entry.value),
              selected: selected,
              onSelected: (value) {
                if (value) {
                  controller.selectVibe(entry.key);
                }
              },
              selectedColor: theme.colorScheme.primary.withOpacity(0.2),
            );
          }).toList(),
        );
      },
    );
  }
}

class _SpotlightRitual extends StatelessWidget {
  const _SpotlightRitual({required this.controller});

  final WellnessController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return ValueListenableBuilder<MindfulRitual?>(
      valueListenable: controller.spotlight,
      builder: (_, ritual, __) {
        if (ritual == null) {
          return const SizedBox.shrink();
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.translate('wellness_spotlight'),
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 360),
              child: GestureDetector(
                key: ValueKey<String>(ritual.id + ritual.completed.toString()),
                onTap: () => controller.toggleCompletion(ritual.id),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Stack(
                    children: [
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Image.network(
                          ritual.imageUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.15),
                                Colors.black.withOpacity(0.65),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 20,
                        right: 20,
                        bottom: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  ritual.completed
                                      ? Icons.check_circle
                                      : Icons.auto_awesome,
                                  color: ritual.completed
                                      ? Colors.greenAccent
                                      : theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  ritual.completed
                                      ? l10n.translate('wellness_completed')
                                      : l10n.translate('wellness_tap_to_mark'),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              ritual.title,
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              ritual.subtitle,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _BreathDeck extends StatelessWidget {
  const _BreathDeck({required this.controller});

  final WellnessController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.translate('breath_sequences'),
                style: theme.textTheme.titleMedium,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.shuffle),
              onPressed: controller.refreshRhythm,
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 160,
          child: StreamBuilder<List<BreathGuide>>(
            stream: controller.breathStream,
            initialData: controller.currentBreaths,
            builder: (_, snapshot) {
              final items = snapshot.data ?? controller.currentBreaths;
              if (items.isEmpty) {
                return Center(
                  child: Text(l10n.translate('wellness_no_sequences')),
                );
              }
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                itemBuilder: (_, index) {
                  final guide = items[index];
                  return _BreathCard(guide: guide);
                },
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemCount: items.length,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _BreathCard extends StatelessWidget {
  const _BreathCard({required this.guide});

  final BreathGuide guide;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Container(
      width: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(guide.title, style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          Text(
            guide.description,
            style: theme.textTheme.bodySmall,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Text(
            '${guide.inhaleSeconds}${l10n.translate('seconds_short')} • ${guide.holdSeconds}${l10n.translate('seconds_short')} • ${guide.exhaleSeconds}${l10n.translate('seconds_short')}',
            style: theme.textTheme.labelSmall,
          ),
          const SizedBox(height: 4),
          Text(
            '${guide.cycles} ${l10n.translate('cycles_label')}',
            style: theme.textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}

class _RitualList extends StatelessWidget {
  const _RitualList({required this.controller});

  final WellnessController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.translate('mindful_rituals'), style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        ValueListenableBuilder<List<MindfulRitual>>(
          valueListenable: controller.rituals,
          builder: (_, rituals, __) {
            if (rituals.isEmpty) {
              return Text(l10n.translate('wellness_no_rituals'));
            }
            return Column(
              children: rituals
                  .map((ritual) => _RitualTile(
                        ritual: ritual,
                        onToggle: () => controller.toggleCompletion(ritual.id),
                      ))
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}

class _RitualTile extends StatelessWidget {
  const _RitualTile({required this.ritual, required this.onToggle});

  final MindfulRitual ritual;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: ritual.completed
              ? theme.colorScheme.primary
              : theme.colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              ritual.imageUrl,
              width: 72,
              height: 72,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ritual.title, style: theme.textTheme.titleSmall),
                const SizedBox(height: 4),
                Text(
                  ritual.subtitle,
                  style: theme.textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  '${ritual.durationMinutes} ${l10n.translate('minutes_short')}',
                  style: theme.textTheme.labelSmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          IconButton(
            onPressed: onToggle,
            icon: Icon(
              ritual.completed ? Icons.check_circle : Icons.radio_button_unchecked,
              color: ritual.completed
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecoveryMoments extends StatelessWidget {
  const _RecoveryMoments({required this.controller});

  final WellnessController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.translate('micro_breaks'), style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        StreamBuilder<List<RecoveryMoment>>(
          stream: controller.momentsStream,
          initialData: controller.currentMoments,
          builder: (_, snapshot) {
            final moments = snapshot.data ?? controller.currentMoments;
            if (moments.isEmpty) {
              return Text(l10n.translate('wellness_no_breaks'));
            }
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: moments
                  .map(
                    (moment) => _MomentChip(moment: moment),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}

class _MomentChip extends StatelessWidget {
  const _MomentChip({required this.moment});

  final RecoveryMoment moment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.45),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(moment.icon, style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(moment.title, style: theme.textTheme.titleSmall),
          const SizedBox(height: 4),
          Text(
            moment.subtitle,
            style: theme.textTheme.bodySmall,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Text(
            '${moment.durationMinutes} ${l10n.translate('minutes_short')}',
            style: theme.textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}
