import 'package:flutter/material.dart';

import '../../controllers/community_controller.dart';
import '../../core/localization/localization_extensions.dart';
import '../../core/utils/models.dart';
import '../../core/widgets/ai_info_button.dart';
import '../../core/widgets/skeleton_list.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final CommunityController _controller = CommunityController.instance;
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
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('community_lounge')),
        actions: [
          IconButton(
            onPressed: _controller.refreshPulse,
            icon: const Icon(Icons.refresh),
            tooltip: l10n.translate('community_refresh'),
          ),
        ],
      ),
      body: _loading
          ? const Padding(
              padding: EdgeInsets.all(24),
              child: SkeletonList(),
            )
          : RefreshIndicator(
              onRefresh: _controller.refreshPulse,
              child: ValueListenableBuilder<List<CrewCircle>>(
                valueListenable: _controller.circles,
                builder: (_, circles, __) {
                  return ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      ValueListenableBuilder<CirclePulse>(
                        valueListenable: _controller.pulse,
                        builder: (_, pulse, __) {
                          return _PulseCard(pulse: pulse);
                        },
                      ),
                      const SizedBox(height: 24),
                      Text(
                        l10n.translate('community_crews'),
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: circles
                            .map(
                              (circle) => ChoiceChip(
                                selected: circle.joined,
                                label: Text('${circle.icon} ${circle.name}'),
                                onSelected: (_) =>
                                    _controller.selectCircle(circle.id),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 16),
                      ValueListenableBuilder<CrewCircle?>(
                        valueListenable: _controller.activeCircle,
                        builder: (_, circle, __) {
                          if (circle == null) {
                            return const SizedBox.shrink();
                          }
                          return _CircleDetailCard(circle: circle);
                        },
                      ),
                      const SizedBox(height: 24),
                      Text(
                        l10n.translate('community_beacons'),
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      StreamBuilder<List<PeerBeacon>>(
                        stream: _controller.beaconStream,
                        builder: (_, snapshot) {
                          final beacons = snapshot.data ?? [];
                          final activeId = _controller.activeCircle.value?.id;
                          final visible = activeId == null
                              ? beacons
                              : beacons
                                  .where((beacon) => beacon.circleId == activeId)
                                  .toList();
                          if (visible.isEmpty) {
                            return Text(l10n.translate('community_no_beacons'));
                          }
                          return Column(
                            children: visible
                                .map(
                                  (beacon) => _BeaconCard(
                                    beacon: beacon,
                                    onBoost: () =>
                                        _controller.boostBeacon(beacon.id),
                                  ),
                                )
                                .toList(),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      Text(
                        l10n.translate('community_sprints'),
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      StreamBuilder<List<CommunitySprint>>(
                        stream: _controller.sprintStream,
                        builder: (_, snapshot) {
                          final sprints = snapshot.data ?? [];
                          final activeId = _controller.activeCircle.value?.id;
                          final visible = activeId == null
                              ? sprints
                              : sprints
                                  .where((sprint) => sprint.circleId == activeId)
                                  .toList();
                          if (visible.isEmpty) {
                            return Text(l10n.translate('community_no_sprints'));
                          }
                          return Column(
                            children: visible
                                .map(
                                  (sprint) => _SprintTile(
                                    sprint: sprint,
                                    onToggle: () =>
                                        _controller.toggleSprint(sprint.id),
                                  ),
                                )
                                .toList(),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      Text(
                        l10n.translate('community_resources'),
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      ValueListenableBuilder<List<CommunityResource>>(
                        valueListenable: _controller.resources,
                        builder: (_, resources, __) {
                          if (resources.isEmpty) {
                            return Text(l10n.translate('community_no_resources'));
                          }
                          return Column(
                            children: resources
                                .map(
                                  (resource) => _ResourceCard(
                                    resource: resource,
                                    onSave: () => _controller
                                        .toggleResourceSave(resource.id),
                                  ),
                                )
                                .toList(),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
    );
  }
}

class _PulseCard extends StatelessWidget {
  const _PulseCard({required this.pulse});

  final CirclePulse pulse;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withOpacity(0.14),
            theme.colorScheme.secondary.withOpacity(0.08),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  l10n.translate('community_pulse'),
                  style: theme.textTheme.titleLarge,
                ),
              ),
              AIInfoButton(
                message: l10n.translate('community_ai_tip'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(pulse.message, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 16),
          _MetricBar(
            label: l10n.translate('community_collaboration'),
            value: pulse.collaborationIndex,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 12),
          _MetricBar(
            label: l10n.translate('community_share_rate'),
            value: pulse.shareRate,
            color: theme.colorScheme.secondary,
          ),
          const SizedBox(height: 12),
          _MetricBar(
            label: l10n.translate('community_assist_rate'),
            value: pulse.assistRate,
            color: theme.colorScheme.tertiary ?? theme.colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: pulse.highlights
                .take(4)
                .map(
                  (highlight) => Chip(
                    label: Text(
                      highlight,
                      style: theme.textTheme.labelSmall,
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _CircleDetailCard extends StatelessWidget {
  const _CircleDetailCard({required this.circle});

  final CrewCircle circle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 320),
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
          Text(
            '${circle.icon} ${circle.name}',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(circle.tagline, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: circle.signatureMoves
                .map(
                  (move) => Chip(
                    label: Text(move, style: theme.textTheme.labelSmall),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  label: l10n.translate('community_active_drivers'),
                  value: circle.activeDrivers.toString(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MiniStat(
                  label: l10n.translate('community_energy'),
                  value: '${(circle.energy * 100).toStringAsFixed(0)}%',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${l10n.translate('community_next_sync')}: ${circle.nextSync}',
            style: theme.textTheme.labelMedium,
          ),
        ],
      ),
    );
  }
}

class _BeaconCard extends StatelessWidget {
  const _BeaconCard({required this.beacon, required this.onBoost});

  final PeerBeacon beacon;
  final VoidCallback onBoost;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: theme.cardColor.withOpacity(0.8),
        border: Border.all(
          color: beacon.isBoosted
              ? theme.colorScheme.primary
              : theme.colorScheme.primary.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  beacon.driverName,
                  style: theme.textTheme.titleSmall,
                ),
              ),
              Text(
                beacon.timeAgo,
                style: theme.textTheme.labelSmall,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(beacon.message, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: beacon.tags
                .map(
                  (tag) => Chip(
                    label: Text('#$tag', style: theme.textTheme.labelSmall),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                '${beacon.boosts} ${l10n.translate('community_boosts')}',
                style: theme.textTheme.labelMedium,
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: onBoost,
                icon: Icon(
                  beacon.isBoosted ? Icons.flash_on : Icons.flashlight_on,
                ),
                label: Text(
                  beacon.isBoosted
                      ? l10n.translate('community_boosted')
                      : l10n.translate('community_boost'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SprintTile extends StatelessWidget {
  const _SprintTile({required this.sprint, required this.onToggle});

  final CommunitySprint sprint;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            sprint.title,
            style: theme.textTheme.titleSmall,
          ),
          const SizedBox(height: 4),
          Text(sprint.timeframe, style: theme.textTheme.labelMedium),
          const SizedBox(height: 8),
          Text(sprint.description, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: sprint.focusTags
                .map((tag) => Chip(label: Text('#$tag')))
                .toList(),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.tonal(
              onPressed: onToggle,
              child: Text(
                sprint.joined
                    ? l10n.translate('community_sprint_joined')
                    : l10n.translate('community_join_sprint'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResourceCard extends StatelessWidget {
  const _ResourceCard({required this.resource, required this.onSave});

  final CommunityResource resource;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.12),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.library_music, size: 36, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(resource.title, style: theme.textTheme.titleSmall),
                const SizedBox(height: 4),
                Text(resource.subtitle, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 6),
                Text(
                  '${resource.format} • ${resource.duration} • ${resource.vibe}',
                  style: theme.textTheme.labelMedium,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: onSave,
            icon: Icon(
              resource.isSaved ? Icons.bookmark : Icons.bookmark_add_outlined,
            ),
            tooltip: resource.isSaved
                ? l10n.translate('community_saved')
                : l10n.translate('community_save'),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelMedium),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: value.clamp(0.0, 1.0),
          minHeight: 6,
          backgroundColor: theme.colorScheme.onSurface.withOpacity(0.08),
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});

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
        Text(value, style: theme.textTheme.titleMedium),
      ],
    );
  }
}
