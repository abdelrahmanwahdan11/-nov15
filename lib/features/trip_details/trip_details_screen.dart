import 'package:flutter/material.dart';

import '../../core/utils/models.dart';
import '../../core/widgets/ai_info_button.dart';
import '../../core/localization/localization_extensions.dart';
import '../../core/widgets/map_placeholder.dart';

class TripDetailsScreen extends StatelessWidget {
  const TripDetailsScreen({super.key, this.ride});

  final Ride? ride;

  @override
  Widget build(BuildContext context) {
    final rideData = ride;
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.translate('trip_details'))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Hero(tag: 'map-hero', child: MapPlaceholder(height: 240)),
            const SizedBox(height: 24),
            if (rideData != null)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(rideData.passengerName, style: Theme.of(context).textTheme.titleMedium),
                        const AIInfoButton(),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text('Pickup: ${rideData.pickupAddress}'),
                    Text('Drop: ${rideData.destinationAddress}'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: Text('Distance: ${rideData.distanceKm.toStringAsFixed(1)} km')),
                        Expanded(child: Text('Time: ${rideData.avgTimeMinutes} mins')),
                        Expanded(child: Text('Fare: \$${rideData.price.toStringAsFixed(2)}')),
                      ],
                    ),
                  ],
                ),
              )
            else
              Text(l10n.translate('no_active_trip')),
          ],
        ),
      ),
    );
  }
}
