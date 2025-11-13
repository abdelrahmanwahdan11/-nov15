import 'package:flutter/material.dart';

import '../../controllers/ride_controller.dart';
import '../../core/localization/localization_extensions.dart';
import '../../core/utils/models.dart';
import '../../core/widgets/map_placeholder.dart';

class OnTripScreen extends StatelessWidget {
  const OnTripScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.translate('on_trip_title'))),
      body: ValueListenableBuilder<Ride?>(
        valueListenable: RideController.instance.currentRide,
        builder: (_, ride, __) {
          if (ride == null) {
            return Center(child: Text(l10n.translate('no_active_trip')));
          }
          return Column(
            children: [
              const MapPlaceholder(height: 260),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(24),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(backgroundImage: NetworkImage(ride.passengerAvatarUrl)),
                          const SizedBox(width: 12),
                          Text(ride.passengerName, style: Theme.of(context).textTheme.titleMedium),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text('Pickup: ${ride.pickupAddress}'),
                      Text('Drop: ${ride.destinationAddress}'),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: ElevatedButton(onPressed: () => _showSnack(context, l10n.translate('calling')), child: Text(l10n.translate('call')))),
                          const SizedBox(width: 12),
                          Expanded(child: OutlinedButton(onPressed: () => _showSnack(context, l10n.translate('message_sent')), child: Text(l10n.translate('message')))),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
