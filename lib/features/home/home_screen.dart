import 'package:flutter/material.dart';

import '../../controllers/app_controller.dart';
import '../../controllers/ride_controller.dart';
import '../../core/localization/localization_extensions.dart';
import '../../core/routing/route_names.dart';
import '../../core/widgets/app_drawer.dart';
import '../../core/widgets/map_placeholder.dart';
import '../../core/widgets/ride_card.dart';
import '../../core/widgets/skeleton_list.dart';
import '../../core/utils/models.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ValueNotifier<bool> _online = ValueNotifier(false);
  final RideController _rideController = RideController.instance;
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
                              Navigator.of(context).pushNamed(RouteNames.search);
                            },
                            icon: const Icon(Icons.search),
                            label: Text(l10n.translate('search')),
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
