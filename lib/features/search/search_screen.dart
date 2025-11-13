
import 'package:flutter/material.dart';

import '../../controllers/catalog_controller.dart';
import '../../controllers/ride_controller.dart';
import '../../core/localization/localization_extensions.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final RideController _rideController = RideController.instance;
  final CatalogController _catalogController = CatalogController.instance;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _catalogController.load();
  }

  @override
  Widget build(BuildContext context) {
    final rides = _rideController.filterRides(_query);
    final catalog = _catalogController.items.where((item) {
      if (_query.isEmpty) return true;
      return item.title.toLowerCase().contains(_query.toLowerCase()) ||
          item.subtitle.toLowerCase().contains(_query.toLowerCase());
    }).toList();
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.translate('search'))),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: l10n.translate('search_data')),
              onChanged: (value) => setState(() => _query = value),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView(
                children: [
                  Text(l10n.translate('rides_section')),
                  if (rides.isEmpty)
                    ListTile(title: Text(l10n.translate('no_rides_found')))
                  else
                    ...rides.map((ride) => ListTile(
                          title: Text(ride.passengerName),
                          subtitle: Text('${ride.pickupAddress} → ${ride.destinationAddress}'),
                        )),
                  const SizedBox(height: 24),
                  Text(l10n.translate('catalog_items')),
                  if (catalog.isEmpty)
                    ListTile(title: Text(l10n.translate('no_catalog_found')))
                  else
                    ...catalog.map((item) => ListTile(
                          title: Text(item.title),
                          subtitle: Text(item.subtitle),
                        )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
