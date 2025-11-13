import 'package:flutter/material.dart';

import '../../controllers/app_controller.dart';
import '../../controllers/community_controller.dart';
import '../../controllers/cosmos_controller.dart';
import '../../controllers/impact_controller.dart';
import '../../controllers/horizon_controller.dart';
import '../../controllers/innovation_controller.dart';
import '../../controllers/mastery_controller.dart';
import '../../controllers/momentum_controller.dart';
import '../../controllers/ride_controller.dart';
import '../../controllers/wellness_controller.dart';
import '../../core/localization/localization_extensions.dart';
import '../../core/routing/route_names.dart';
import '../../core/utils/insight_utils.dart';
import '../../core/utils/models.dart';
import '../../core/widgets/app_drawer.dart';
import '../../core/widgets/map_placeholder.dart';
import '../../core/widgets/ride_card.dart';
import '../../core/widgets/skeleton_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ValueNotifier<bool> _online = ValueNotifier(false);
  final RideController _rideController = RideController.instance;
  final WellnessController _wellnessController = WellnessController.instance;
  final MomentumController _momentumController = MomentumController.instance;
  final CommunityController _communityController =
      CommunityController.instance;
  final CosmosController _cosmosController = CosmosController.instance;
  final ImpactController _impactController = ImpactController.instance;
  final InnovationController _innovationController =
      InnovationController.instance;
  final MasteryController _masteryController = MasteryController.instance;
  final HorizonController _horizonController = HorizonController.instance;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _rideController.loadInitial().then((_) {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    });
    _wellnessController.init();
    _momentumController.init();
    _communityController.init();
    _impactController.init();
    _innovationController.init();
    _masteryController.init();
    _horizonController.init();
    _cosmosController.init();
  }

  @override
  void dispose() {
    _online.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: Text(l10n.translate('home')),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          ValueListenableBuilder<bool>(
            valueListenable: _online,
            builder: (_, value, __) {
              return Switch.adaptive(
                value: value,
                onChanged: (val) => _online.value = val,
                activeColor: Theme.of(context).colorScheme.primary,
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: _loading
              ? const Padding(
                  padding: EdgeInsets.all(24),
                  child: SkeletonList(),
                )
              : ValueListenableBuilder<bool>(
                  valueListenable: _online,
                  builder: (_, online, __) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const MapPlaceholder(),
                          const SizedBox(height: 24),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            transitionBuilder: (child, animation) => SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 0.1),
                                end: Offset.zero,
                              ).animate(animation),
                              child: FadeTransition(opacity: animation, child: child),
                            ),
                            child: online
                                ? StreamBuilder<List<Ride>>(
                                    stream: _rideController.ridesStream,
                                    builder: (context, snapshot) {
                                      final rides = snapshot.data ?? [];
                                      if (rides.isEmpty) {
                                        return Text(l10n.translate('no_rides_available'));
                                      }
                                      final ride = rides.first;
                                      return RideCard(ride: ride);
                                    },
                                  )
                                : _OfflineCard(message: l10n.translate('enable_location_description')),
                          ),
                          const SizedBox(height: 24),
                          TextButton.icon(
                            onPressed: () {
                              Navigator.of(context)
                                  .pushNamed(RouteNames.search);
                            },
                            icon: const Icon(Icons.search),
                            label: Text(l10n.translate('search')),
                          ),
                          const SizedBox(height: 12),
                          FilledButton.icon(
                            onPressed: () => _openShiftPlanner(context),
                            icon: const Icon(Icons.timeline),
                            label: Text(l10n.translate('shift_planner')),
                          ),
                          const SizedBox(height: 12),
                          FilledButton.tonalIcon(
                            onPressed: () =>
                                Navigator.of(context).pushNamed(RouteNames.strategyLab),
                            icon: const Icon(Icons.bolt),
                            label: Text(l10n.translate('strategy_lab')),
                          ),
                          const SizedBox(height: 12),
                          FilledButton.tonalIcon(
                            onPressed: () =>
                                Navigator.of(context).pushNamed(RouteNames.wellness),
                            icon: const Icon(Icons.self_improvement),
                            label: Text(l10n.translate('wellness_studio')),
                          ),
                          const SizedBox(height: 12),
                          FilledButton.tonalIcon(
                            onPressed: () =>
                                Navigator.of(context).pushNamed(RouteNames.momentum),
                            icon: const Icon(Icons.flag),
                            label: Text(l10n.translate('momentum_hub')),
                          ),
                          const SizedBox(height: 12),
                          FilledButton.tonalIcon(
                            onPressed: () =>
                                Navigator.of(context).pushNamed(RouteNames.community),
                            icon: const Icon(Icons.groups_2_outlined),
                            label: Text(l10n.translate('community_lounge')),
                          ),
                          const SizedBox(height: 12),
                          FilledButton.tonalIcon(
                            onPressed: () =>
                                Navigator.of(context).pushNamed(RouteNames.mastery),
                            icon: const Icon(Icons.school_outlined),
                            label: Text(l10n.translate('mastery_studio')),
                          ),
                          const SizedBox(height: 12),
                          FilledButton.tonalIcon(
                            onPressed: () =>
                                Navigator.of(context).pushNamed(RouteNames.horizon),
                            icon: const Icon(Icons.auto_awesome),
                            label: Text(l10n.translate('horizon_studio')),
                          ),
                          const SizedBox(height: 12),
                          FilledButton.tonalIcon(
                            onPressed: () =>
                                Navigator.of(context).pushNamed(RouteNames.cosmos),
                            icon: const Icon(Icons.public),
                            label: Text(l10n.translate('cosmos_studio')),
                          ),
                          const SizedBox(height: 12),
                          FilledButton.tonalIcon(
                            onPressed: () =>
                                Navigator.of(context).pushNamed(RouteNames.innovation),
                            icon: const Icon(Icons.lightbulb_outline),
                            label: Text(l10n.translate('innovation_lab')),
                          ),
                          const SizedBox(height: 12),
                          FilledButton.tonalIcon(
                            onPressed: () =>
                                Navigator.of(context).pushNamed(RouteNames.impact),
                            icon: const Icon(Icons.eco_outlined),
                            label: Text(l10n.translate('impact_studio')),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: () =>
                                Navigator.of(context).pushNamed(RouteNames.insights),
                            icon: const Icon(Icons.auto_graph),
                            label: Text(l10n.translate('view_full_insights')),
                          ),
                          const SizedBox(height: 16),
                          ValueListenableBuilder<Ride?>(
                            valueListenable: _rideController.currentRide,
                            builder: (context, ride, _) {
                              if (ride == null) {
                                return const SizedBox.shrink();
                              }
                              final insights = InsightUtils.rideInsights(l10n, ride);
                              return AnimatedOpacity(
                                duration: const Duration(milliseconds: 400),
                                opacity: insights.isEmpty ? 0 : 1,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.translate('smart_insights'),
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge,
                                    ),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: insights
                                          .take(3)
                                          .map(
                                            (insight) => Chip(
                                              label: Text(
                                                insight,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall,
                                              ),
                                              backgroundColor: Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                                  .withOpacity(0.12),
                                            ),
                                          )
                                          .toList(),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                          ValueListenableBuilder<WellnessSnapshot>(
                            valueListenable: _wellnessController.snapshot,
                            builder: (context, snapshot, _) {
                              return _WellnessQuickCard(snapshot: snapshot);
                            },
                          ),
                          const SizedBox(height: 16),
                          ValueListenableBuilder<MomentumPulse>(
                            valueListenable: _momentumController.pulse,
                            builder: (context, pulse, _) {
                              return ValueListenableBuilder<SkillTrack?>(
                                valueListenable: _momentumController.focusTrack,
                                builder: (context, track, __) {
                                  return _MomentumQuickCard(
                                    pulse: pulse,
                                    track: track,
                                  );
                                },
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          ValueListenableBuilder<CirclePulse>(
                            valueListenable: _communityController.pulse,
                            builder: (context, pulse, _) {
                              return ValueListenableBuilder<CrewCircle?>(
                                valueListenable: _communityController.activeCircle,
                                builder: (context, circle, __) {
                                  return _CommunityQuickCard(
                                    pulse: pulse,
                                    circle: circle,
                                  );
                                },
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          ValueListenableBuilder<MasteryPulse>(
                            valueListenable: _masteryController.pulse,
                            builder: (context, pulse, _) {
                              return ValueListenableBuilder<List<MasteryModule>>(
                                valueListenable: _masteryController.modules,
                                builder: (context, modules, __) {
                                  MasteryModule? focusModule;
                                  if (modules.isNotEmpty) {
                                    focusModule = modules.firstWhere(
                                      (module) => module.isFocus,
                                      orElse: () => modules.first,
                                    );
                                  }
                                  return _MasteryQuickCard(
                                    pulse: pulse,
                                    module: focusModule,
                                  );
                                },
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          ValueListenableBuilder<HorizonPulse>(
                            valueListenable: _horizonController.pulse,
                            builder: (context, pulse, _) {
                              return ValueListenableBuilder<List<HorizonScenario>>(
                                valueListenable: _horizonController.scenarios,
                                builder: (context, scenarios, __) {
                                  HorizonScenario? focusScenario;
                                  if (scenarios.isNotEmpty) {
                                    focusScenario = scenarios.firstWhere(
                                      (scenario) => scenario.isFocus,
                                      orElse: () => scenarios.first,
                                    );
                                  }
                                  return _HorizonQuickCard(
                                    pulse: pulse,
                                    scenario: focusScenario,
                                  );
                                },
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          ValueListenableBuilder<CosmosPulse>(
                            valueListenable: _cosmosController.pulse,
                            builder: (context, pulse, _) {
                              return ValueListenableBuilder<List<CosmosConstellation>>(
                                valueListenable: _cosmosController.constellations,
                                builder: (context, constellations, __) {
                                  CosmosConstellation? focusConstellation;
                                  if (constellations.isNotEmpty) {
                                    focusConstellation = constellations.firstWhere(
                                      (constellation) => constellation.isFocus,
                                      orElse: () => constellations.first,
                                    );
                                  }
                                  return _CosmosQuickCard(
                                    pulse: pulse,
                                    constellation: focusConstellation,
                                  );
                                },
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          ValueListenableBuilder<InnovationPulse>(
                            valueListenable: _innovationController.pulse,
                            builder: (context, pulse, _) {
                              return ValueListenableBuilder<List<InnovationPrototype>>(
                                valueListenable: _innovationController.prototypes,
                                builder: (context, prototypes, __) {
                                  return _InnovationQuickCard(
                                    pulse: pulse,
                                    prototype:
                                        prototypes.isEmpty ? null : prototypes.first,
                                  );
                                },
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          ValueListenableBuilder<ImpactPulse>(
                            valueListenable: _impactController.pulse,
                            builder: (context, pulse, _) {
                              return ValueListenableBuilder<List<ImpactRipple>>(
                                valueListenable: _impactController.ripples,
                                builder: (context, ripples, __) {
                                  return _ImpactQuickCard(
                                    pulse: pulse,
                                    ripple: ripples.isEmpty ? null : ripples.first,
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}



class _WellnessQuickCard extends StatelessWidget {
  const _WellnessQuickCard({required this.snapshot});

  final WellnessSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 320),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.translate('wellness_mini_header'),
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(snapshot.message, style: theme.textTheme.bodySmall),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: snapshot.anchorNotes
                .take(3)
                .map(
                  (note) => Chip(
                    label: Text(note, style: theme.textTheme.labelSmall),
                    backgroundColor:
                        theme.colorScheme.primary.withOpacity(0.12),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _MiniGauge(
                  label: l10n.translate('wellness_alignment'),
                  value: snapshot.alignmentScore,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MiniGauge(
                  label: l10n.translate('wellness_energy'),
                  value: snapshot.energyScore,
                  color: theme.colorScheme.secondary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MiniGauge(
                  label: l10n.translate('wellness_focus'),
                  value: snapshot.focusScore,
                  color: theme.colorScheme.tertiary ?? theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed(RouteNames.wellness),
              child: Text(l10n.translate('open_wellness_full')),
            ),
          ),
        ],
      ),
    );
  }
}

class _MomentumQuickCard extends StatelessWidget {
  const _MomentumQuickCard({required this.pulse, this.track});

  final MomentumPulse pulse;
  final SkillTrack? track;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 320),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.translate('momentum_quick_header'),
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(pulse.message, style: theme.textTheme.bodySmall),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${l10n.translate('momentum_level')} ${pulse.level}',
                      style: theme.textTheme.labelLarge,
                    ),
                    const SizedBox(height: 6),
                    LinearProgressIndicator(
                      value: pulse.progress,
                      minHeight: 6,
                      backgroundColor:
                          theme.colorScheme.onSurface.withOpacity(0.08),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${pulse.xp}/${pulse.xpToNext} ${l10n.translate('momentum_xp')}',
                      style: theme.textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
              if (track != null) ...[
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${track!.icon} ${track!.title}',
                      style: theme.textTheme.labelLarge,
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      width: 90,
                      child: LinearProgressIndicator(
                        value: track!.progress,
                        minHeight: 6,
                        backgroundColor:
                            theme.colorScheme.onSurface.withOpacity(0.08),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.secondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.translate('momentum_action_next'),
                      style: theme.textTheme.labelSmall,
                    ),
                  ],
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: pulse.highlights
                .take(2)
                .map(
                  (highlight) => Chip(
                    label: Text(highlight, style: theme.textTheme.labelSmall),
                    backgroundColor:
                        theme.colorScheme.primary.withOpacity(0.12),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _CommunityQuickCard extends StatelessWidget {
  const _CommunityQuickCard({required this.pulse, this.circle});

  final CirclePulse pulse;
  final CrewCircle? circle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 320),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.translate('community_quick_header'),
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(pulse.message, style: theme.textTheme.bodySmall),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MiniGauge(
                  label: l10n.translate('community_collaboration'),
                  value: pulse.collaborationIndex,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MiniGauge(
                  label: l10n.translate('community_share_rate'),
                  value: pulse.shareRate,
                  color: theme.colorScheme.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: pulse.highlights
                .take(3)
                .map(
                  (highlight) => Chip(
                    label: Text(highlight, style: theme.textTheme.labelSmall),
                    backgroundColor:
                        theme.colorScheme.primary.withOpacity(0.12),
                  ),
                )
                .toList(),
          ),
          if (circle != null) ...[
            const SizedBox(height: 12),
            Text(
              '${circle!.icon} ${circle!.name} • ${circle!.activeDrivers} ${l10n.translate('community_active_drivers')}',
              style: theme.textTheme.labelMedium,
            ),
          ],
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed(RouteNames.community),
              child: Text(l10n.translate('community_open_full')),
            ),
          ),
        ],
      ),
    );
  }
}

class _MasteryQuickCard extends StatelessWidget {
  const _MasteryQuickCard({required this.pulse, this.module});

  final MasteryPulse pulse;
  final MasteryModule? module;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final progress = module?.progress ?? pulse.momentum;
    final focusTitle = module?.title ?? pulse.focusTheme;
    final insights = InsightUtils.masteryNudges(l10n, pulse, module).take(2).toList();
    return AnimatedContainer(
      duration: const Duration(milliseconds: 320),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.translate('mastery_studio'), style: theme.textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(focusTitle, style: theme.textTheme.labelLarge),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: 8,
            borderRadius: BorderRadius.circular(8),
          ),
          const SizedBox(height: 6),
          Text(
            '${l10n.translate('mastery_module_progress_label')}: ${(progress * 100).toStringAsFixed(0)}%',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: pulse.pathways
                .take(2)
                .map(
                  (path) => Chip(
                    label: Text(path),
                    backgroundColor:
                        theme.colorScheme.primary.withOpacity(0.12),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          ...insights.map(
            (insight) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                insight,
                style: theme.textTheme.bodySmall,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.tonalIcon(
              onPressed: () =>
                  Navigator.of(context).pushNamed(RouteNames.mastery),
              icon: const Icon(Icons.school_outlined),
              label: Text(l10n.translate('mastery_view_full')),
            ),
          ),
        ],
      ),
    );
  }
}

class _HorizonQuickCard extends StatelessWidget {
  const _HorizonQuickCard({required this.pulse, this.scenario});

  final HorizonPulse pulse;
  final HorizonScenario? scenario;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final alignment = (pulse.alignment * 100).clamp(0, 100).toStringAsFixed(0);
    final confidence = (pulse.confidence * 100).clamp(0, 100).toStringAsFixed(0);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 320),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.translate('horizon_quick_header'),
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(pulse.headline, style: theme.textTheme.bodySmall),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${l10n.translate('horizon_alignment')}: $alignment%',
                  style: theme.textTheme.bodySmall,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${l10n.translate('horizon_confidence')}: $confidence%',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
          if (scenario != null) ...[
            const SizedBox(height: 12),
            Text(
              scenario!.title,
              style: theme.textTheme.labelLarge,
            ),
            const SizedBox(height: 4),
            Text(
              '${scenario!.timeframe} · ${scenario!.focus}',
              style: theme.textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: pulse.signalHighlights
                .map((highlight) => TagChip(label: highlight, isSelected: false))
                .toList(),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.tonalIcon(
              onPressed: () =>
                  Navigator.of(context).pushNamed(RouteNames.horizon),
              icon: const Icon(Icons.auto_awesome),
              label: Text(l10n.translate('horizon_open_full')),
            ),
          ),
        ],
      ),
    );
  }
}

class _InnovationQuickCard extends StatelessWidget {
  const _InnovationQuickCard({required this.pulse, this.prototype});

  final InnovationPulse pulse;
  final InnovationPrototype? prototype;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final readiness = (pulse.readiness * 100).clamp(0, 100).toStringAsFixed(0);
    final focus = pulse.focusLanes.take(2).join(' · ');
    final focusLabel = focus.isEmpty ? '-' : focus;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 320),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.translate('innovation_lab'),
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(pulse.headline, style: theme.textTheme.bodySmall),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${l10n.translate('innovation_readiness')}: $readiness%',
                  style: theme.textTheme.bodySmall,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${l10n.translate('innovation_focus_lane_label')}: $focusLabel',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
          if (prototype != null) ...[
            const SizedBox(height: 12),
            Text(prototype!.title, style: theme.textTheme.labelLarge),
            const SizedBox(height: 4),
            Text(
              '${l10n.translate('innovation_stage')}: ${prototype!.stage}',
              style: theme.textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.tonalIcon(
              onPressed: () =>
                  Navigator.of(context).pushNamed(RouteNames.innovation),
              icon: const Icon(Icons.lightbulb_outline),
              label: Text(l10n.translate('innovation_lab')),
            ),
          ),
        ],
      ),
    );
  }
}

class _CosmosQuickCard extends StatelessWidget {
  const _CosmosQuickCard({required this.pulse, this.constellation});

  final CosmosPulse pulse;
  final CosmosConstellation? constellation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final magnetism = (pulse.magnetism.clamp(0.0, 1.0) * 100).round();
    final signal = (pulse.signalStrength.clamp(0.0, 1.0) * 100).round();
    return AnimatedContainer(
      duration: const Duration(milliseconds: 320),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.translate('cosmos_quick_header'),
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(pulse.highlight, style: theme.textTheme.bodySmall),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${l10n.translate('cosmos_magnetism')}: $magnetism%',
                      style: theme.textTheme.labelLarge,
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: pulse.magnetism.clamp(0.0, 1.0),
                        minHeight: 6,
                        backgroundColor:
                            theme.colorScheme.onSurface.withOpacity(0.08),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${l10n.translate('cosmos_signal')}: $signal%',
                      style: theme.textTheme.labelLarge,
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: pulse.signalStrength.clamp(0.0, 1.0),
                        minHeight: 6,
                        backgroundColor:
                            theme.colorScheme.onSurface.withOpacity(0.08),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.secondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _QuickChip(
                icon: Icons.star_border_rounded,
                label:
                    '${l10n.translate('cosmos_alliances')}: ${pulse.activeAlliances}',
              ),
              _QuickChip(
                icon: Icons.schedule,
                label:
                    '${l10n.translate('cosmos_quick_window')}: ${pulse.window}',
              ),
            ],
          ),
          if (constellation != null) ...[
            const SizedBox(height: 12),
            Text(
              '${constellation!.icon} ${constellation!.title}',
              style: theme.textTheme.labelLarge,
            ),
            const SizedBox(height: 4),
            Text(constellation!.snapshot, style: theme.textTheme.bodySmall),
            const SizedBox(height: 4),
            Text(
              '${l10n.translate('cosmos_focus_label')}: ${constellation!.anchor}',
              style: theme.textTheme.labelSmall,
            ),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _QuickChip(
                icon: Icons.auto_fix_high,
                label:
                    '${l10n.translate('cosmos_quick_focus')}: ${pulse.focus}',
              ),
              _QuickChip(
                icon: Icons.rocket_launch,
                label:
                    '${l10n.translate('cosmos_next_trajectory')}: ${pulse.nextTrajectory}',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.tonalIcon(
              onPressed: () => Navigator.of(context).pushNamed(RouteNames.cosmos),
              icon: const Icon(Icons.public),
              label: Text(l10n.translate('cosmos_quick_open')),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  const _QuickChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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

class _ImpactQuickCard extends StatelessWidget {
  const _ImpactQuickCard({required this.pulse, this.ripple});

  final ImpactPulse pulse;
  final ImpactRipple? ripple;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final co2Score = (120 - pulse.co2Saved).clamp(0.0, 120) / 120;
    final cleanScore = (pulse.cleanKm / 240).clamp(0.0, 1.0);
    final renewable = pulse.renewableShare.clamp(0.0, 1.0);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 320),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.translate('impact_quick_header'),
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(pulse.message, style: theme.textTheme.bodySmall),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MiniGauge(
                  label: l10n.translate('impact_co2_saved'),
                  value: co2Score,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MiniGauge(
                  label: l10n.translate('impact_clean_km'),
                  value: cleanScore,
                  color: theme.colorScheme.secondary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MiniGauge(
                  label: l10n.translate('impact_renewable_share'),
                  value: renewable,
                  color: theme.colorScheme.tertiary ?? theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: pulse.highlights
                .take(2)
                .map(
                  (highlight) => Chip(
                    label: Text(highlight, style: theme.textTheme.labelSmall),
                    backgroundColor:
                        theme.colorScheme.primary.withOpacity(0.12),
                  ),
                )
                .toList(),
          ),
          if (ripple != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  ripple!.direction == TrendDirection.up
                      ? Icons.trending_up
                      : ripple!.direction == TrendDirection.down
                          ? Icons.trending_down
                          : Icons.linear_scale,
                  color: ripple!.direction == TrendDirection.down
                      ? theme.colorScheme.error
                      : theme.colorScheme.primary,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${ripple!.title} • ${ripple!.value.toStringAsFixed(1)} ${ripple!.unit}',
                    style: theme.textTheme.labelSmall,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed(RouteNames.impact),
              child: Text(l10n.translate('impact_open_full')),
            ),
          ),
        ],
      ),
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
        Text(label, style: theme.textTheme.labelSmall),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: LinearProgressIndicator(
            minHeight: 6,
            value: value.clamp(0.0, 1.0),
            color: color,
            backgroundColor: color.withOpacity(0.12),
          ),
        ),
        const SizedBox(height: 4),
        Text('${(value * 100).round()}%', style: theme.textTheme.labelSmall),
      ],
    );
  }
}

void _openShiftPlanner(BuildContext context) {
  final l10n = context.l10n;
  final theme = Theme.of(context);
  final windows = InsightUtils.shiftWindows(RideController.instance.allRides);
  showModalBottomSheet<void>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (ctx) {
      if (windows.isEmpty) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Center(child: Text(l10n.translate('demand_calm'))),
        );
      }
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.dividerColor.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.translate('shift_planner'),
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(ctx).size.height * 0.5,
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: windows.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, index) {
                    final window = windows[index];
                    final demand = window.demandScore.clamp(0, 1);
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(window.window,
                                  style: theme.textTheme.titleSmall),
                              Text('${window.surge.toStringAsFixed(2)}x'),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${l10n.translate('suggested_follow_up')}: ${window.focusArea}',
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: LinearProgressIndicator(
                              value: demand,
                              minHeight: 8,
                              backgroundColor:
                                  theme.colorScheme.primary.withOpacity(0.15),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text('${l10n.translate('demand_trend_label')}: '
                              '${demand >= 0.85 ? l10n.translate('demand_peak') : demand >= 0.7 ? l10n.translate('demand_balanced') : l10n.translate('demand_calm')}'),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(l10n.translate('close')),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _OfflineCard extends StatelessWidget {
  const _OfflineCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      key: const ValueKey('offline-card'),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          const Icon(Icons.location_pin, size: 48, color: Colors.orange),
          const SizedBox(height: 16),
          Text(l10n.translate('enable_location'), style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => AppController.instance.setLoggedIn(true, guest: true),
            child: Text(l10n.translate('continue')),
          )
        ],
      ),
    );
  }
}
