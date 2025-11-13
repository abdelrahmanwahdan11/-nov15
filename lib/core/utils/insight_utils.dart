import 'dart:math';

import '../localization/app_localizations.dart';
import 'models.dart';

class ShiftWindowData {
  ShiftWindowData({
    required this.window,
    required this.focusArea,
    required this.demandScore,
    required this.surge,
  });

  final String window;
  final String focusArea;
  final double demandScore;
  final double surge;
}

class InsightUtils {
  static final Random _random = Random();

  static List<String> rideInsights(AppLocalizations l10n, Ride ride) {
    final surge = (ride.meta['surge'] as double?) ?? 1.0;
    final demandIndex = (ride.meta['demandIndex'] as double?) ?? 0.6;
    final cancellationRisk = (ride.meta['cancellationRisk'] as double?) ?? 0.03;
    final earningTarget = (ride.meta['earningTarget'] as num?)?.toDouble() ??
        max(ride.price * surge, ride.price + 5);
    final city = ride.meta['city'] as String? ?? '';
    final window = ride.meta['hotspotWindow'] as String? ?? '';
    final projected = ride.price * surge;

    return [
      '${l10n.translate('projected_payout_label')}: \$${projected.toStringAsFixed(2)}',
      '${l10n.translate('surge_multiplier_label')}: ${surge.toStringAsFixed(2)}x ${city.isNotEmpty ? '• $city' : ''}'.trim(),
      '${l10n.translate('demand_trend_label')}: ${_demandLabel(l10n, demandIndex)}',
      '${l10n.translate('cancellation_risk_label')}: ${(cancellationRisk * 100).clamp(0, 99).toStringAsFixed(1)}%',
      '${l10n.translate('distance_hint_label')}: ${ride.distanceKm.toStringAsFixed(1)} km • ${ride.avgTimeMinutes} min',
      if (window.isNotEmpty)
        '${l10n.translate('suggested_follow_up')}: $window',
      '${l10n.translate('bundle_value_label')}: \$${earningTarget.toStringAsFixed(2)} • ${l10n.translate('planning_tip_label')}',
    ];
  }

  static List<String> catalogInsights(
      AppLocalizations l10n, CatalogItem item) {
    final distance = max(item.distanceKm, 1);
    final costPerKm = item.price / distance;
    final traffic = item.meta['traffic'] ?? '';
    final time = item.meta['time'] ?? '';

    return [
      '${l10n.translate('bundle_value_label')}: \$${costPerKm.toStringAsFixed(2)} / km',
      '${l10n.translate('rating_strength_label')}: ${item.rating.toStringAsFixed(1)} ⭐',
      '${l10n.translate('distance_hint_label')}: ${item.distanceKm.toStringAsFixed(1)} km • $time',
      if (traffic is String && traffic.isNotEmpty)
        '${l10n.translate('demand_trend_label')}: $traffic',
    ];
  }

  static List<ShiftWindowData> shiftWindows(List<Ride> rides) {
    final Map<String, List<Ride>> grouped = {};
    for (final ride in rides) {
      final window = (ride.meta['hotspotWindow'] as String?) ?? 'Anytime';
      grouped.putIfAbsent(window, () => []).add(ride);
    }

    return grouped.entries.map((entry) {
      final window = entry.key;
      final windowRides = entry.value;
      final avgDemand = windowRides
              .map((ride) => (ride.meta['demandIndex'] as double?) ?? 0.6)
              .fold<double>(0, (prev, value) => prev + value) /
          windowRides.length;
      final avgSurge = windowRides
              .map((ride) => (ride.meta['surge'] as double?) ?? 1.0)
              .fold<double>(0, (prev, value) => prev + value) /
          windowRides.length;
      final focusArea = windowRides
          .fold<Map<String, int>>({}, (map, ride) {
            final city = ride.meta['city'] as String? ?? 'City';
            map[city] = (map[city] ?? 0) + 1;
            return map;
          })
          .entries
          .reduce((a, b) => a.value >= b.value ? a : b)
          .key;
      return ShiftWindowData(
        window: window,
        focusArea: focusArea,
        demandScore: avgDemand,
        surge: avgSurge,
      );
    }).toList()
      ..sort((a, b) => b.demandScore.compareTo(a.demandScore));
  }

  static String _demandLabel(AppLocalizations l10n, double demandIndex) {
    if (demandIndex >= 0.85) {
      return l10n.translate('demand_peak');
    }
    if (demandIndex >= 0.7) {
      return l10n.translate('demand_balanced');
    }
    return l10n.translate('demand_calm');
  }

  static List<String> shuffleHighlights(List<String> highlights) {
    final copy = List<String>.from(highlights);
    copy.shuffle(_random);
    return copy.take(4).toList();
  }

  static String nextCommunityMessage(String current) {
    if (_communityMessages.isEmpty) {
      return current;
    }
    final index = _communityMessages.indexOf(current);
    if (index == -1) {
      return _communityMessages[_random.nextInt(_communityMessages.length)];
    }
    final nextIndex = (index + 1) % _communityMessages.length;
    return _communityMessages[nextIndex];
  }

  static const List<String> _communityMessages = <String>[
    'Crew sync window aligning — share your best quick wins.',
    'Momentum sparks rising in the harbor circle, drop a beacon.',
    'Fresh rider kudos landed. Pay it forward with a new tactic.',
    'New playlist vibes unlocked. Pair it with a twilight sprint.',
  ];
}
