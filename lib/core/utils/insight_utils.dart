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

  static List<String> reshuffleImpactHighlights(List<String> current) {
    final pool = <String>{
      ...current,
      ..._impactHighlightPool,
    }.toList();
    if (pool.isEmpty) {
      return current;
    }
    pool.shuffle(_random);
    return pool.take(4).toList();
  }

  static String nextImpactMessage(String current) {
    if (_impactMessages.isEmpty) {
      return current;
    }
    final index = _impactMessages.indexOf(current);
    if (index == -1) {
      return _impactMessages[_random.nextInt(_impactMessages.length)];
    }
    final nextIndex = (index + 1) % _impactMessages.length;
    return _impactMessages[nextIndex];
  }

  static const List<String> _impactMessages = <String>[
    'Regenerative loop engaged — keep smooth coasts through downtown.',
    'Solar buffer topped up. Shift charges to off-peak for extra credit.',
    'City pledge streak alive — capture one more rider story tonight.',
    'Green lane express is surging. Align your window to ride the wave.',
  ];

  static const List<String> _impactHighlightPool = <String>[
    'Two-minute idle scan unlocked a new saved hotspot',
    'Riders shared 5 eco kudos in the last hour',
    'Clean kilometres passed the weekly baseline',
    'Charging queue trimmed by syncing with planner auto-slot',
    'Metro partnership trial opened a temporary green lane',
    'Hydration reminder triggered alongside wellness check-in',
  ];

  static List<String> masteryNudges(
    AppLocalizations l10n,
    MasteryPulse pulse,
    MasteryModule? module,
  ) {
    final moduleTitle = module?.title ?? pulse.focusTheme;
    final progress = module != null
        ? '${(module.progress * 100).clamp(0, 100).toStringAsFixed(0)}%'
        : '${(pulse.momentum * 100).toStringAsFixed(0)}%';
    final focus = module?.focusArea ?? moduleTitle;
    final cues = <String>[
      '${l10n.translate('mastery_micro_practice')}: ${pulse.microPractice}',
      '${l10n.translate('mastery_module_progress_label')}: $progress',
      '${l10n.translate('mastery_focus_pathways')}: ${pulse.pathways.take(2).join(' • ')}',
      '${l10n.translate('mastery_coach_message')}: ${pulse.coachNote}',
    ];
    if (module != null) {
      cues.add(
        '${l10n.translate('mastery_next_action')}: ${module.reflectionPrompt}',
      );
      cues.add(
        '${l10n.translate('mastery_focus_label')}: $focus',
      );
    }
    return cues;
  }
}
