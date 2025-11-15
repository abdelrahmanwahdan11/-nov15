import 'package:flutter/material.dart';

import '../../core/localization/localization_extensions.dart';
import '../../core/utils/insight_utils.dart';
import '../../core/utils/models.dart';
import '../../core/widgets/ai_info_button.dart';
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
                        Expanded(
                          child: Text(
                            rideData.passengerName,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        AIInfoButton(
                          headlineKey: 'ride_insights',
                          insightsBuilder: (l10n) =>
                              InsightUtils.rideInsights(l10n, rideData),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text('${l10n.translate('pickup')}: ${rideData.pickupAddress}'),
                    Text(
                        '${l10n.translate('destination')}: ${rideData.destinationAddress}'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${l10n.translate('distance')}: ${rideData.distanceKm.toStringAsFixed(1)} km',
                          ),
                        ),
                        Expanded(
                          child: Text(
                            '${l10n.translate('time')}: ${rideData.avgTimeMinutes} mins',
                          ),
                        ),
                        Expanded(
                          child: Text(
                            '${l10n.translate('price')}: \$${rideData.price.toStringAsFixed(2)}',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (rideData.meta['hotspotWindow'] != null)
                          _InfoChip(
                            icon: Icons.access_time,
                            label:
                                '${l10n.translate('hotspot_window')}: ${rideData.meta['hotspotWindow']}',
                          ),
                        if (rideData.meta['city'] != null)
                          _InfoChip(
                            icon: Icons.location_on_outlined,
                            label: rideData.meta['city'] as String,
                          ),
                        _InfoChip(
                          icon: Icons.trending_up,
                          label:
                              '${l10n.translate('surge_multiplier_label')}: ${(rideData.meta['surge'] ?? 1.0).toStringAsFixed(2)}x',
                        ),
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

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(label, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}
