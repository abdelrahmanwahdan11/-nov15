import 'package:flutter/material.dart';

import '../../controllers/ride_controller.dart';
import '../localization/localization_extensions.dart';
import '../utils/models.dart';
import 'ai_info_button.dart';

class RideCard extends StatelessWidget {
  const RideCard({super.key, required this.ride, this.onTap});

  final Ride ride;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 16, offset: Offset(0, 12)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(backgroundImage: NetworkImage(ride.passengerAvatarUrl)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(ride.passengerName, style: Theme.of(context).textTheme.titleMedium),
                      Text('${ride.distanceKm.toStringAsFixed(1)} km • \$${ride.price.toStringAsFixed(2)}'),
                    ],
                  ),
                ),
                AIInfoButton(key: ValueKey('ai-${ride.id}')),
              ],
            ),
            const SizedBox(height: 12),
            _RidePoint(label: l10n.translate('pickup'), value: ride.pickupAddress),
            const SizedBox(height: 8),
            _RidePoint(label: l10n.translate('destination'), value: ride.destinationAddress),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    child: Text(l10n.translate('decline')),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      RideController.instance.currentRide.value = ride;
                    },
                    child: Text(l10n.translate('accept')),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _RidePoint extends StatelessWidget {
  const _RidePoint({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(height: 4),
        Text(value, style: Theme.of(context).textTheme.bodyLarge),
      ],
    );
  }
}
