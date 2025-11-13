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
  final Set<String> _selected = <String>{};

  void _toggleSelection(String rideId, bool selected) {
    setState(() {
      if (selected) {
        _selected.add(rideId);
      } else {
        _selected.remove(rideId);
      }
    });
  }

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
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${l10n.translate('selected_label')}: ${_selected.length}'),
                  if (_selected.length < 2)
                    Text(
                      l10n.translate('select_two_notice'),
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Theme.of(context).hintColor),
                    )
                  else
                    Text(
                      l10n.translate('ready_to_compare'),
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Theme.of(context).colorScheme.primary),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _controller.refreshRides,
                child: ListView.builder(
                  itemCount: rides.length,
                  itemBuilder: (_, index) {
                    final ride = rides[index];
                    final isSelected = _selected.contains(ride.id);
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: RideCard(
                        ride: ride,
                        showActions: false,
                        trailing: Checkbox(
                          value: isSelected,
                          onChanged: (value) =>
                              _toggleSelection(ride.id, value ?? false),
                        ),
                        footer: _RideFooter(ride: ride),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _selected.length >= 2
            ? () {
                final selectedRides = rides
                    .where((ride) => _selected.contains(ride.id))
                    .toList();
                Navigator.of(context)
                    .pushNamed(RouteNames.compare, arguments: selectedRides);
              }
            : null,
        icon: const Icon(Icons.compare_arrows),
        label: Text(l10n.translate('compare_items')),
      ),
    );
  }
}

class _RideFooter extends StatelessWidget {
  const _RideFooter({required this.ride});

  final Ride ride;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    Color statusColor;
    switch (ride.status) {
      case 'completed':
        statusColor = Colors.green;
        break;
      case 'incoming':
        statusColor = theme.colorScheme.primary;
        break;
      case 'cancelled':
        statusColor = Colors.redAccent;
        break;
      default:
        statusColor = theme.colorScheme.secondary;
    }
    final city = ride.meta['city'] as String? ?? '-';
    final window = ride.meta['hotspotWindow'] as String? ?? '-';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                ride.status.toUpperCase(),
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: statusColor, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '${l10n.translate('pickup')}: ${TimeOfDay.fromDateTime(ride.pickupTime).format(context)}',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '${l10n.translate('suggested_follow_up')}: $city • $window',
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}
