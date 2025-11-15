import 'package:flutter/material.dart';

import '../../controllers/cosmos_controller.dart';
import '../../core/localization/localization_extensions.dart';
import '../../core/utils/models.dart';
import '../../core/widgets/ai_info_button.dart';

class CosmosScreen extends StatefulWidget {
  const CosmosScreen({super.key});

  @override
  State<CosmosScreen> createState() => _CosmosScreenState();
}

class _CosmosScreenState extends State<CosmosScreen> {
  final CosmosController _controller = CosmosController.instance;
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

  Future<void> _handleRefresh() async {
    await _controller.refreshPulse();
  }

  void _handleBeaconToggle(CosmosBeacon beacon) {
    _controller.toggleBeaconBoost(beacon.id);
    final l10n = context.l10n;
    final toggled = !beacon.boosted;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          toggled
              ? l10n.translate('cosmos_boosted_message')
              : l10n.translate('cosmos_unboosted_message'),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleExpeditionToggle(CosmosExpedition expedition) {
    _controller.toggleExpedition(expedition.id);
    final l10n = context.l10n;
    final toggled = !expedition.enrolled;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          toggled
              ? l10n.translate('cosmos_enrolled_message')
              : l10n.translate('cosmos_removed_message'),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleArtifactToggle(CosmosArtifact artifact) {
    _controller.toggleArtifactSaved(artifact.id);
    final l10n = context.l10n;
    final toggled = !artifact.saved;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          toggled
              ? l10n.translate('cosmos_saved_message')
              : l10n.translate('cosmos_unsaved_message'),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('cosmos_studio')),
        actions: [
          AIInfoButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.translate('ai_placeholder'))),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.autorenew),
            onPressed: _controller.refreshPulse,
            tooltip: l10n.translate('cosmos_refresh'),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      ValueListenableBuilder<CosmosPulse>(
                        valueListenable: _controller.pulse,
                        builder: (_, pulse, __) {
                          return _CosmosPulseCard(pulse: pulse);
                        },
                      ),
                      const SizedBox(height: 24),
                      ValueListenableBuilder<List<CosmosConstellation>>(
                        valueListenable: _controller.constellations,
                        builder: (_, constellations, __) {
                          return _ConstellationSection(
                            constellations: constellations,
                            onFocus: _controller.focusConstellation,
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      ValueListenableBuilder<List<CosmosOrbit>>(
                        valueListenable: _controller.orbits,
                        builder: (_, orbits, __) {
                          return _OrbitSection(orbits: orbits);
                        },
                      ),
                      const SizedBox(height: 24),
                      StreamBuilder<List<CosmosBeacon>>(
                        stream: _controller.beaconStream,
                        initialData: const <CosmosBeacon>[],
                        builder: (_, snapshot) {
                          final beacons = snapshot.data ?? <CosmosBeacon>[];
                          return _BeaconSection(
                            beacons: beacons,
                            onToggle: _handleBeaconToggle,
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      StreamBuilder<List<CosmosExpedition>>(
                        stream: _controller.expeditionStream,
                        initialData: const <CosmosExpedition>[],
                        builder: (_, snapshot) {
                          final expeditions =
                              snapshot.data ?? <CosmosExpedition>[];
                          return _ExpeditionSection(
                            expeditions: expeditions,
                            onToggle: _handleExpeditionToggle,
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      ValueListenableBuilder<List<CosmosArtifact>>(
                        valueListenable: _controller.artifacts,
                        builder: (_, artifacts, __) {
                          return _ArtifactSection(
                            artifacts: artifacts,
                            onToggle: _handleArtifactToggle,
                          );
                        },
                      ),
                      const SizedBox(height: 32),
                      Text(
                        l10n.translate('cosmos_intro'),
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _CosmosPulseCard extends StatelessWidget {
  const _CosmosPulseCard({required this.pulse});

  final CosmosPulse pulse;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
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
          Text(
            l10n.translate('cosmos_pulse_title'),
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(pulse.headline, style: theme.textTheme.titleLarge),
          const SizedBox(height: 12),
          _MetricProgress(
            label: l10n.translate('cosmos_magnetism'),
            value: pulse.magnetism,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 12),
          _MetricProgress(
            label: l10n.translate('cosmos_signal'),
            value: pulse.signalStrength,
            color: theme.colorScheme.secondary,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${l10n.translate('cosmos_alliances')}: ${pulse.activeAlliances}',
                  style: theme.textTheme.labelLarge,
                ),
              ),
              Chip(
                label: Text(pulse.window),
                avatar: const Icon(Icons.schedule, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(pulse.highlight, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _InfoChip(
                icon: Icons.auto_fix_high,
                label: '${l10n.translate('cosmos_focus_label')}: ${pulse.focus}',
              ),
              _InfoChip(
                icon: Icons.rocket_launch,
                label:
                    '${l10n.translate('cosmos_next_trajectory')}: ${pulse.nextTrajectory}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ConstellationSection extends StatelessWidget {
  const _ConstellationSection({
    required this.constellations,
    required this.onFocus,
  });

  final List<CosmosConstellation> constellations;
  final ValueChanged<String> onFocus;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    if (constellations.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.translate('cosmos_constellations_title'),
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: constellations.map((constellation) {
            final isFocus = constellation.isFocus;
            return GestureDetector(
              onTap: () => onFocus(constellation.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 220,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isFocus
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outline.withOpacity(0.2),
                  ),
                  color: isFocus
                      ? theme.colorScheme.primary.withOpacity(0.08)
                      : theme.colorScheme.surface,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          constellation.icon,
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            constellation.title,
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      constellation.snapshot,
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 12),
                    _MetricProgress(
                      label: l10n.translate('cosmos_resonance'),
                      value: constellation.resonance,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${l10n.translate('cosmos_window_label')}: ${constellation.window}',
                      style: theme.textTheme.labelSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${l10n.translate('cosmos_focus_label')}: ${constellation.anchor}',
                      style: theme.textTheme.labelSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.translate('cosmos_tap_to_focus'),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _OrbitSection extends StatelessWidget {
  const _OrbitSection({required this.orbits});

  final List<CosmosOrbit> orbits;

  @override
  Widget build(BuildContext context) {
    if (orbits.isEmpty) {
      return const SizedBox.shrink();
    }
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.translate('cosmos_orbits_title'),
            style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        SizedBox(
          height: 180,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              final orbit = orbits[index];
              final trendIcon = orbit.trajectory >= 0
                  ? Icons.trending_up
                  : Icons.trending_down;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 220,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: theme.colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(orbit.label, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 6),
                    Text(orbit.window, style: theme.textTheme.bodySmall),
                    const SizedBox(height: 8),
                    _MetricProgress(
                      label: l10n.translate('cosmos_magnetism'),
                      value: orbit.magnetic,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(trendIcon, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          orbit.trajectory.toStringAsFixed(2),
                          style: theme.textTheme.labelMedium,
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      orbit.tone,
                      style: theme.textTheme.labelSmall,
                    ),
                  ],
                ),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemCount: orbits.length,
          ),
        ),
      ],
    );
  }
}

class _BeaconSection extends StatelessWidget {
  const _BeaconSection({required this.beacons, required this.onToggle});

  final List<CosmosBeacon> beacons;
  final ValueChanged<CosmosBeacon> onToggle;

  @override
  Widget build(BuildContext context) {
    if (beacons.isEmpty) {
      return const SizedBox.shrink();
    }
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.translate('cosmos_beacons_title'),
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        ...beacons.map((beacon) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: beacon.boosted
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
                      child: Text(
                        beacon.title,
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                    Chip(
                      avatar: const Icon(Icons.flash_on, size: 16),
                      label: Text('${(beacon.energy * 100).round()}%'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(beacon.subtitle, style: theme.textTheme.bodySmall),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${l10n.translate('cosmos_urgency')}: ${beacon.urgency}',
                        style: theme.textTheme.labelSmall,
                      ),
                    ),
                    TextButton(
                      onPressed: () => onToggle(beacon),
                      child: Text(
                        beacon.boosted
                            ? l10n.translate('cosmos_release')
                            : l10n.translate('cosmos_boost'),
                      ),
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

class _ExpeditionSection extends StatelessWidget {
  const _ExpeditionSection({required this.expeditions, required this.onToggle});

  final List<CosmosExpedition> expeditions;
  final ValueChanged<CosmosExpedition> onToggle;

  @override
  Widget build(BuildContext context) {
    if (expeditions.isEmpty) {
      return const SizedBox.shrink();
    }
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.translate('cosmos_expeditions_title'),
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        ...expeditions.map((expedition) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: expedition.enrolled
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
                      child: Text(
                        expedition.title,
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                    Text(expedition.window,
                        style: theme.textTheme.labelSmall),
                  ],
                ),
                const SizedBox(height: 8),
                Text(expedition.focus, style: theme.textTheme.bodySmall),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: expedition.progress,
                  minHeight: 6,
                  backgroundColor:
                      theme.colorScheme.onSurface.withOpacity(0.08),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => onToggle(expedition),
                    child: Text(
                      expedition.enrolled
                          ? l10n.translate('cosmos_leave')
                          : l10n.translate('cosmos_enroll'),
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

class _ArtifactSection extends StatelessWidget {
  const _ArtifactSection({required this.artifacts, required this.onToggle});

  final List<CosmosArtifact> artifacts;
  final ValueChanged<CosmosArtifact> onToggle;

  @override
  Widget build(BuildContext context) {
    if (artifacts.isEmpty) {
      return const SizedBox.shrink();
    }
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.translate('cosmos_artifacts_title'),
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: artifacts.map((artifact) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 220,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: artifact.saved
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
                        child: Text(
                          artifact.title,
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                      Chip(label: Text(artifact.tag)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(artifact.summary, style: theme.textTheme.bodySmall),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => onToggle(artifact),
                      child: Text(
                        artifact.saved
                            ? l10n.translate('cosmos_saved')
                            : l10n.translate('cosmos_save'),
                      ),
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

class _MetricProgress extends StatelessWidget {
  const _MetricProgress({
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
        Text(label, style: theme.textTheme.labelLarge),
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

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
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
