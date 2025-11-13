import 'package:flutter/material.dart';

import '../../controllers/ride_controller.dart';
import '../../core/localization/localization_extensions.dart';
import '../../core/widgets/filter_chips_row.dart';
import '../../core/widgets/ride_card.dart';
import '../../core/routing/route_names.dart';

class MyRidesScreen extends StatefulWidget {
  const MyRidesScreen({super.key});

  @override
  State<MyRidesScreen> createState() => _MyRidesScreenState();
}

class _MyRidesScreenState extends State<MyRidesScreen> {
  final RideController _controller = RideController.instance;
  String? _status;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final rides = _controller.filterRides(_query, status: _status);
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.translate('my_rides'))),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: l10n.translate('search')),
              onChanged: (value) => setState(() => _query = value),
            ),
            const SizedBox(height: 12),
            FilterChipsRow(
              options: const ['incoming', 'on_trip', 'completed', 'cancelled'],
              active: _status,
              onSelected: (value) => setState(() => _status = value),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _controller.refreshRides,
                child: ListView.builder(
                  itemCount: rides.length,
                  itemBuilder: (_, index) {
                    final ride = rides[index];
                    return RideCard(ride: ride);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final selected = rides.take(2).toList();
          if (selected.length >= 2) {
            Navigator.of(context).pushNamed(RouteNames.compare, arguments: selected);
          }
        },
        icon: const Icon(Icons.compare_arrows),
        label: Text(l10n.translate('compare_items')),
      ),
    );
  }
}
