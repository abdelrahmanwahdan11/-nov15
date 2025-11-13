import 'package:flutter/material.dart';

import '../../controllers/app_controller.dart';
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
