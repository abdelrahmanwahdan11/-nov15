import 'package:flutter/material.dart';

import '../../controllers/ride_controller.dart';
import '../../core/localization/localization_extensions.dart';
import '../../core/utils/models.dart';
import '../../core/widgets/primary_button.dart';

class ArrivedRatingScreen extends StatefulWidget {
  const ArrivedRatingScreen({super.key});

  @override
  State<ArrivedRatingScreen> createState() => _ArrivedRatingScreenState();
}

class _ArrivedRatingScreenState extends State<ArrivedRatingScreen>
    with SingleTickerProviderStateMixin {
  double _rating = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.translate('rate_trip'))),
      body: ValueListenableBuilder<Ride?>(
        valueListenable: RideController.instance.currentRide,
        builder: (_, ride, __) {
          if (ride == null) {
            return Center(child: Text(l10n.translate('no_completed_trip')));
          }
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l10n.translate('how_was_trip'), style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                Text('Passenger: ${ride.passengerName}'),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final selected = index < _rating;
                    return AnimatedScale(
                      scale: selected ? 1.2 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: IconButton(
                        icon: Icon(
                          Icons.star,
                          color: selected ? Colors.orange : Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _rating = index + 1;
                          });
                        },
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  label: l10n.translate('submit'),
                  onPressed: () {
                    RideController.instance.updateRideRating(ride.id, _rating);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Thanks for rating ${ride.passengerName}!')),
                    );
                  },
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.translate('cancel')),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
