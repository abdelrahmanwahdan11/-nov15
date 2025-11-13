
import 'package:flutter/material.dart';

import '../../controllers/catalog_controller.dart';
import '../../controllers/ride_controller.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/localization/localization_extensions.dart';
import '../../core/routing/route_names.dart';
import '../../core/utils/insight_utils.dart';
import '../../core/utils/models.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  final RideController _rideController = RideController.instance;
  final CatalogController _catalogController = CatalogController.instance;
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late final TabController _tabController;

  String _query = '';
  String? _statusFilter;
  final List<String> _recentQueries = <String>[];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _catalogController.load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final rides = _rideController.filterRides(_query, status: _statusFilter);
    final catalog = _catalogController.items.where((item) {
      if (_query.isEmpty) return true;
      return item.title.toLowerCase().contains(_query.toLowerCase()) ||
          item.subtitle.toLowerCase().contains(_query.toLowerCase()) ||
          item.tags.any((tag) => tag.toLowerCase().contains(_query.toLowerCase()));
    }).toList();
    final allRides = _rideController.filterRides('', status: null);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.translate('search'))),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _textController,
              focusNode: _focusNode,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: l10n.translate('search_data'),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _query = '';
                            _textController.clear();
                          });
                        },
                      ),
              ),
              onChanged: (value) => setState(() => _query = value),
              onSubmitted: _handleSubmitted,
            ),
            const SizedBox(height: 16),
            _SummaryCard(rides: rides, allRides: allRides, catalog: catalog),
            const SizedBox(height: 16),
            _StatusFilterChips(
              activeStatus: _statusFilter,
              onStatusChanged: (value) => setState(() => _statusFilter = value),
            ),
            const SizedBox(height: 12),
            _RecentSearches(
              recentQueries: _recentQueries,
              onSelect: (value) {
                setState(() {
                  _query = value;
                  _textController.text = value;
                  _textController.selection = TextSelection.collapsed(offset: value.length);
                });
              },
              onClear: () => setState(() {
                _recentQueries.clear();
              }),
            ),
            const SizedBox(height: 12),
            TabBar(
              controller: _tabController,
              labelColor: Theme.of(context).colorScheme.primary,
              indicatorColor: Theme.of(context).colorScheme.primary,
              tabs: [
                Tab(text: l10n.translate('search_summary')),
                Tab(text: l10n.translate('rides_label')),
                Tab(text: l10n.translate('catalog_label')),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _CombinedResults(
                    rides: rides,
                    catalog: catalog,
                    onRideTap: (ride) => _openRide(context, ride),
                  ),
                  _RideResults(
                    rides: rides,
                    onRideTap: (ride) => _openRide(context, ride),
                  ),
                  _CatalogResults(catalog: catalog),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSubmitted(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return;
    setState(() {
      _recentQueries.remove(trimmed);
      _recentQueries.insert(0, trimmed);
      if (_recentQueries.length > 6) {
        _recentQueries.removeLast();
      }
    });
  }

  void _openRide(BuildContext context, Ride ride) {
    Navigator.of(context).pushNamed(RouteNames.tripDetails, arguments: ride);
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.rides,
    required this.allRides,
    required this.catalog,
  });

  final List<Ride> rides;
  final List<Ride> allRides;
  final List<CatalogItem> catalog;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final shiftWindows = InsightUtils.shiftWindows(
        rides.isNotEmpty ? rides : allRides);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, 8)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.translate('search_summary'), style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  '${l10n.translate('rides_label')}: ${rides.length} • ${l10n.translate('catalog_label')}: ${catalog.length}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: shiftWindows.isEmpty
                ? [
                    Text(
                      l10n.translate('demand_calm'),
                      style: theme.textTheme.bodySmall,
                    )
                  ]
                : shiftWindows.take(1).map((window) {
                    final demand = _describeDemand(l10n, window.demandScore);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${l10n.translate('hotspot_window')}: ${window.window}',
                          style: theme.textTheme.bodySmall,
                        ),
                        Text(
                          '${l10n.translate('surge_multiplier_label')}: ${window.surge.toStringAsFixed(2)}x',
                          style: theme.textTheme.bodySmall,
                        ),
                        Text(
                          '${l10n.translate('demand_trend_label')}: $demand',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    );
                  }).toList(),
          ),
        ],
      ),
    );
  }

  String _describeDemand(AppLocalizations l10n, double score) {
    if (score >= 0.85) return l10n.translate('demand_peak');
    if (score >= 0.7) return l10n.translate('demand_balanced');
    return l10n.translate('demand_calm');
  }
}

class _StatusFilterChips extends StatelessWidget {
  const _StatusFilterChips({required this.activeStatus, required this.onStatusChanged});

  final String? activeStatus;
  final ValueChanged<String?> onStatusChanged;

  @override
  Widget build(BuildContext context) {
    final statuses = ['incoming', 'on_trip', 'completed'];
    return Wrap(
      spacing: 8,
      children: statuses
          .map(
            (status) => ChoiceChip(
              label: Text(status.replaceAll('_', ' ').toUpperCase()),
              selected: activeStatus == status,
              onSelected: (value) => onStatusChanged(value ? status : null),
            ),
          )
          .toList(),
    );
  }
}

class _RecentSearches extends StatelessWidget {
  const _RecentSearches({
    required this.recentQueries,
    required this.onSelect,
    required this.onClear,
  });

  final List<String> recentQueries;
  final ValueChanged<String> onSelect;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (recentQueries.isEmpty) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(l10n.translate('recent_searches'), style: Theme.of(context).textTheme.labelLarge),
          Text(l10n.translate('no_recent_searches'), style: Theme.of(context).textTheme.bodySmall),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l10n.translate('recent_searches'), style: Theme.of(context).textTheme.labelLarge),
            TextButton(onPressed: onClear, child: Text(l10n.translate('clear'))),
          ],
        ),
        Wrap(
          spacing: 8,
          children: recentQueries
              .map((query) => ActionChip(label: Text(query), onPressed: () => onSelect(query)))
              .toList(),
        ),
      ],
    );
  }
}

class _CombinedResults extends StatelessWidget {
  const _CombinedResults({
    required this.rides,
    required this.catalog,
    required this.onRideTap,
  });

  final List<Ride> rides;
  final List<CatalogItem> catalog;
  final ValueChanged<Ride> onRideTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        _SectionHeader(title: l10n.translate('rides_section'), count: rides.length),
        if (rides.isEmpty)
          _EmptyState(message: l10n.translate('no_rides_found'))
        else
          ...rides.map((ride) => _RideTile(ride: ride, onTap: () => onRideTap(ride))),
        const SizedBox(height: 16),
        _SectionHeader(title: l10n.translate('catalog_items'), count: catalog.length),
        if (catalog.isEmpty)
          _EmptyState(message: l10n.translate('no_catalog_found'))
        else
          ...catalog.map((item) => _CatalogTile(item: item)),
      ],
    );
  }
}

class _RideResults extends StatelessWidget {
  const _RideResults({required this.rides, required this.onRideTap});

  final List<Ride> rides;
  final ValueChanged<Ride> onRideTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (rides.isEmpty) {
      return _EmptyState(message: l10n.translate('no_rides_found'));
    }
    return ListView.separated(
      itemCount: rides.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, index) {
        final ride = rides[index];
        return _RideTile(ride: ride, onTap: () => onRideTap(ride));
      },
    );
  }
}

class _CatalogResults extends StatelessWidget {
  const _CatalogResults({required this.catalog});

  final List<CatalogItem> catalog;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (catalog.isEmpty) {
      return _EmptyState(message: l10n.translate('no_catalog_found'));
    }
    return ListView.separated(
      itemCount: catalog.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, index) {
        final item = catalog[index];
        final insights = InsightUtils.catalogInsights(context.l10n, item);
        return ListTile(
          title: Text(item.title),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.subtitle),
              if (insights.isNotEmpty)
                Text(
                  insights.first,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
          ),
          trailing: Text('\$${item.price.toStringAsFixed(2)}'),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.count});

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: theme.textTheme.titleMedium),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text('$count'),
          ),
        ],
      ),
    );
  }
}

class _RideTile extends StatelessWidget {
  const _RideTile({required this.ride, required this.onTap});

  final Ride ride;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final insights = InsightUtils.rideInsights(l10n, ride);
    return ListTile(
      leading: CircleAvatar(backgroundImage: NetworkImage(ride.passengerAvatarUrl)),
      title: Text(ride.passengerName),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${ride.pickupAddress} → ${ride.destinationAddress}'),
          if (insights.isNotEmpty)
            Text(
              insights.first,
              style: Theme.of(context).textTheme.bodySmall,
            ),
        ],
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}

class _CatalogTile extends StatelessWidget {
  const _CatalogTile({required this.item});

  final CatalogItem item;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(backgroundImage: NetworkImage(item.imageUrl)),
      title: Text(item.title),
      subtitle: Text(item.subtitle),
      trailing: Text('\$${item.price.toStringAsFixed(2)}'),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}
