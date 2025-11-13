import 'package:flutter/material.dart';

import '../../controllers/momentum_controller.dart';
import '../../core/localization/localization_extensions.dart';
import '../../core/utils/models.dart';
import '../../core/widgets/ai_info_button.dart';

class MomentumScreen extends StatefulWidget {
  const MomentumScreen({super.key});

  @override
  State<MomentumScreen> createState() => _MomentumScreenState();
}

class _MomentumScreenState extends State<MomentumScreen> {
  final MomentumController _controller = MomentumController.instance;
  late Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = _controller.init();
  }

  Future<void> _handleRefresh() async {
    await _controller.refreshMomentum();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.translate('momentum_refresh_toast'))),
    );
  }

  Future<void> _handleTrackSelect(String id) async {
    await _controller.selectTrack(id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.translate('momentum_track_switched'))),
    );
  }

  Future<void> _handleMilestoneAdvance(
    SkillTrack track,
    SkillMilestone milestone,
  ) async {
    final willComplete = !milestone.isComplete &&
        milestone.completedSteps + 1 >= milestone.totalSteps;
    await _controller.advanceMilestone(track.id, milestone.id);
    if (!mounted) return;
    final l10n = context.l10n;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          willComplete
              ? l10n.translate('momentum_milestone_completed')
              : l10n.translate('momentum_step_logged'),
        ),
      ),
    );
  }

  Future<void> _handleChallengeTap(MomentumChallenge challenge) async {
    final willComplete =
        !challenge.isComplete && challenge.progress + 1 >= challenge.target;
    await _controller.logChallengeProgress(challenge.id);
    if (!mounted) return;
    final l10n = context.l10n;
    final message = willComplete
        ? l10n.translate('momentum_challenge_complete')
        : l10n.translate('momentum_challenge_progress');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('momentum_hub')),
        actions: [
          AIInfoButton(
            headlineKey: 'momentum_hub',
            insightsBuilder: (localization) => [
              localization.translate('momentum_ai_tip_1'),
              localization.translate('momentum_ai_tip_2'),
              localization.translate('momentum_ai_tip_3'),
            ],
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
            onRefresh: _handleRefresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.all(24),
              children: [
                _MomentumPulsePanel(controller: _controller),
                const SizedBox(height: 24),
                _TrackSelector(
                  controller: _controller,
                  onSelect: _handleTrackSelect,
                ),
                const SizedBox(height: 24),
                _MilestoneList(
                  controller: _controller,
                  onAdvance: _handleMilestoneAdvance,
                ),
                const SizedBox(height: 24),
                _ChallengeSection(
                  controller: _controller,
                  onChallengeTap: _handleChallengeTap,
                ),
                const SizedBox(height: 24),
                _CoachSignalSection(controller: _controller),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MomentumPulsePanel extends StatelessWidget {
  const _MomentumPulsePanel({required this.controller});

  final MomentumController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return ValueListenableBuilder<MomentumPulse>(
      valueListenable: controller.pulse,
      builder: (context, pulse, _) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 380),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary.withOpacity(0.22),
                theme.colorScheme.secondaryContainer.withOpacity(0.18),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(32),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    l10n.translate('momentum_pulse_title'),
                    style: theme.textTheme.titleMedium,
                  ),
                  const Spacer(),
                  Chip(
                    backgroundColor:
                        theme.colorScheme.surface.withOpacity(0.2),
                    label: Text(
                      '${l10n.translate('momentum_level')} ${pulse.level}',
                      style: theme.textTheme.labelLarge,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: Text(
                  pulse.message,
                  key: ValueKey<String>(pulse.message),
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: LinearProgressIndicator(
                  value: pulse.progress,
                  minHeight: 10,
                  backgroundColor:
                      theme.colorScheme.onSurface.withOpacity(0.08),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${pulse.xp}/${pulse.xpToNext} ${l10n.translate('momentum_xp')}',
                style: theme.textTheme.labelMedium,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: pulse.highlights
                    .map(
                      (highlight) => Chip(
                        label: Text(highlight),
                        avatar: const Icon(Icons.flash_on, size: 16),
                        backgroundColor:
                            theme.colorScheme.primary.withOpacity(0.16),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.local_fire_department,
                      color: theme.colorScheme.secondary),
                  const SizedBox(width: 6),
                  Text(
                    '${l10n.translate('momentum_streak')} ${pulse.streakDays}',
                    style: theme.textTheme.labelLarge,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TrackSelector extends StatelessWidget {
  const _TrackSelector({
    required this.controller,
    required this.onSelect,
  });

  final MomentumController controller;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.translate('momentum_tracks_header'),
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        ValueListenableBuilder<List<SkillTrack>>(
          valueListenable: controller.tracks,
          builder: (context, tracks, _) {
            return ValueListenableBuilder<SkillTrack?>(
              valueListenable: controller.focusTrack,
              builder: (context, focused, __) {
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: tracks.map((track) {
                    final isSelected = track.id == focused?.id;
                    return ChoiceChip(
                      label: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${track.icon} ${track.title}'),
                          const SizedBox(height: 4),
                          SizedBox(
                            width: 120,
                            child: LinearProgressIndicator(
                              value: track.progress,
                              minHeight: 6,
                              backgroundColor: theme.colorScheme.surfaceVariant,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      selected: isSelected,
                      onSelected: (_) => onSelect(track.id),
                    );
                  }).toList(),
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class _MilestoneList extends StatelessWidget {
  const _MilestoneList({
    required this.controller,
    required this.onAdvance,
  });

  final MomentumController controller;
  final Future<void> Function(SkillTrack, SkillMilestone) onAdvance;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return ValueListenableBuilder<SkillTrack?>(
      valueListenable: controller.focusTrack,
      builder: (context, track, _) {
        if (track == null) {
          return const SizedBox.shrink();
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.translate('momentum_milestone_header'),
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ...track.milestones.map((milestone) {
              final progressLabel =
                  '${milestone.completedSteps}/${milestone.totalSteps}';
              return AnimatedContainer(
                key: ValueKey<String>(milestone.id),
                duration: const Duration(milliseconds: 320),
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: theme.colorScheme.primary.withOpacity(0.15),
                  ),
                  color: milestone.isComplete
                      ? theme.colorScheme.primary.withOpacity(0.12)
                      : theme.colorScheme.surface,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            milestone.title,
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                        Text(
                          '+${milestone.xpReward} XP',
                          style: theme.textTheme.labelLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      milestone.description,
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: LinearProgressIndicator(
                        value: milestone.progress,
                        minHeight: 10,
                        backgroundColor:
                            theme.colorScheme.onSurface.withOpacity(0.08),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          milestone.isComplete
                              ? theme.colorScheme.secondary
                              : theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(progressLabel, style: theme.textTheme.labelMedium),
                        const Spacer(),
                        Text(
                          milestone.isComplete
                              ? l10n.translate('momentum_done')
                              : l10n.translate('momentum_action_next'),
                          style: theme.textTheme.labelSmall,
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: milestone.isComplete
                              ? null
                              : () => onAdvance(track, milestone),
                          icon: const Icon(Icons.playlist_add_check),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        );
      },
    );
  }
}

class _ChallengeSection extends StatelessWidget {
  const _ChallengeSection({
    required this.controller,
    required this.onChallengeTap,
  });

  final MomentumController controller;
  final Future<void> Function(MomentumChallenge) onChallengeTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.translate('momentum_challenges_header'),
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        StreamBuilder<List<MomentumChallenge>>(
          stream: controller.challengeStream,
          initialData: controller.currentChallenges,
          builder: (context, snapshot) {
            final challenges = snapshot.data ?? <MomentumChallenge>[];
            if (challenges.isEmpty) {
              return Text(l10n.translate('momentum_no_challenges'));
            }
            return Column(
              children: challenges.map((challenge) {
                final progressLabel =
                    '${challenge.progress}/${challenge.target}';
                return AnimatedOpacity(
                  key: ValueKey<String>(challenge.id),
                  duration: const Duration(milliseconds: 300),
                  opacity: challenge.isComplete ? 0.7 : 1,
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                challenge.icon ?? Icons.bolt,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  challenge.title,
                                  style: theme.textTheme.titleMedium,
                                ),
                              ),
                              Chip(
                                label: Text(challenge.focusArea),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(challenge.subtitle,
                              style: theme.textTheme.bodyMedium),
                          const SizedBox(height: 12),
                          LinearProgressIndicator(
                            value: challenge.percent.clamp(0, 1),
                            minHeight: 8,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(progressLabel,
                                  style: theme.textTheme.labelMedium),
                              const Spacer(),
                              Text(
                                '+${challenge.rewardXp} XP',
                                style: theme.textTheme.labelLarge,
                              ),
                              const SizedBox(width: 12),
                              FilledButton.icon(
                                onPressed: challenge.isComplete
                                    ? null
                                    : () => onChallengeTap(challenge),
                                icon: const Icon(Icons.add_task),
                                label: Text(
                                  challenge.isComplete
                                      ? l10n.translate('momentum_done')
                                      : l10n.translate('momentum_mark_progress'),
                                ),
                              ),
                            ],
                          ),
                        ],
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

class _CoachSignalSection extends StatelessWidget {
  const _CoachSignalSection({required this.controller});

  final MomentumController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.translate('momentum_signals_header'),
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        ValueListenableBuilder<List<CoachSignal>>(
          valueListenable: controller.signals,
          builder: (context, signals, _) {
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 320),
              child: Wrap(
                key: ValueKey<int>(signals.hashCode),
                spacing: 12,
                runSpacing: 12,
                children: signals.map((signal) {
                  return Container(
                    width: MediaQuery.of(context).size.width * 0.42,
                    constraints: const BoxConstraints(minWidth: 180),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${signal.emoji} ${signal.title}',
                            style: theme.textTheme.titleSmall),
                        const SizedBox(height: 6),
                        Text(
                          signal.caption,
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        Chip(
                          label: Text(signal.tag),
                          backgroundColor:
                              theme.colorScheme.primary.withOpacity(0.12),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            );
          },
        ),
      ],
    );
  }
}
