import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/utils/dummy_data.dart';
import '../core/utils/insight_utils.dart';
import '../core/utils/models.dart';
import 'ride_controller.dart';

class InsightController {
  InsightController._();

  static final InsightController instance = InsightController._();

  final ValueNotifier<int> weeklyGoal = ValueNotifier<int>(650);
  final ValueNotifier<int> weeklyProgress = ValueNotifier<int>(0);

  final StreamController<List<DemandPulse>> _pulsesController =
      StreamController<List<DemandPulse>>.broadcast();
  final StreamController<List<DemandHeatCell>> _heatmapController =
      StreamController<List<DemandHeatCell>>.broadcast();
  final StreamController<List<FocusAreaSnapshot>> _focusController =
      StreamController<List<FocusAreaSnapshot>>.broadcast();

  SharedPreferences? _prefs;
  StreamSubscription<List<Ride>>? _rideSubscription;
  bool _initialized = false;

  Stream<List<DemandPulse>> get pulsesStream => _pulsesController.stream;
  Stream<List<DemandHeatCell>> get heatmapStream => _heatmapController.stream;
  Stream<List<FocusAreaSnapshot>> get focusStream => _focusController.stream;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    _prefs = await SharedPreferences.getInstance();
    final storedGoal = _prefs?.getInt('weekly_goal');
    if (storedGoal != null) {
      weeklyGoal.value = storedGoal;
    }
    weeklyProgress.value = _calculateWeeklyProgress(RideController.instance.allRides);
    _pulsesController.add(List.of(dummyDemandPulses));
    _heatmapController.add(List.of(dummyDemandHeatCells));
    _emitFocusFromRides(RideController.instance.allRides);
    _rideSubscription = RideController.instance.ridesStream.listen((rides) {
      weeklyProgress.value = _calculateWeeklyProgress(rides);
      _emitFocusFromRides(rides);
    });
  }

  int _calculateWeeklyProgress(List<Ride> rides) {
    if (rides.isEmpty) {
      return 0;
    }
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final total = rides.where((ride) {
      return ride.status == 'completed' && ride.dropTime.isAfter(weekAgo);
    }).fold<double>(0, (previousValue, ride) => previousValue + ride.price);
    return total.round();
  }

  void _emitFocusFromRides(List<Ride> rides) {
    if (rides.isEmpty) {
      _focusController.add(List.of(dummyFocusSnapshots));
      return;
    }
    final windows = InsightUtils.shiftWindows(rides).take(4).toList();
    if (windows.isEmpty) {
      _focusController.add(List.of(dummyFocusSnapshots));
      return;
    }
    final snapshots = windows.map((window) {
      final rideCount = rides
          .where((ride) => ride.meta['hotspotWindow'] == window.window)
          .length;
      return FocusAreaSnapshot(
        area: window.focusArea,
        window: window.window,
        surge: window.surge,
        rideCount: rideCount,
        demandScore: window.demandScore,
      );
    }).toList();
    _focusController.add(snapshots);
  }

  Future<void> regenerateInsights() async {
    await init();
    final random = Random();
    await Future.delayed(const Duration(milliseconds: 420));
    final updatedPulses = dummyDemandPulses.map((pulse) {
      final variation = (random.nextDouble() * 0.18) - 0.09;
      final adjustedChange = (pulse.change + variation).clamp(-0.2, 0.32);
      final direction = adjustedChange > 0.05
          ? TrendDirection.up
          : adjustedChange < -0.05
              ? TrendDirection.down
              : TrendDirection.steady;
      final tripVariation = random.nextInt(3) - 1;
      final minuteVariation = random.nextInt(7) - 3;
      return pulse.copyWith(
        direction: direction,
        change: double.parse(adjustedChange.toStringAsFixed(2)),
        potentialTrips: ((pulse.potentialTrips + tripVariation).clamp(2, 14))
            .toInt(),
        focusMinutes:
            ((pulse.focusMinutes + minuteVariation).clamp(12, 44)).toInt(),
      );
    }).toList();
    final heatmap = dummyDemandHeatCells.map((cell) {
      final variation = (random.nextDouble() * 0.3) - 0.15;
      final tripsVariation = random.nextInt(5) - 2;
      return cell.copyWith(
        intensity: (cell.intensity + variation).clamp(0.25, 0.95),
        potentialTrips:
            ((cell.potentialTrips + tripsVariation).clamp(1, 15)).toInt(),
      );
    }).toList();
    _pulsesController.add(updatedPulses);
    _heatmapController.add(heatmap);
    weeklyProgress.value =
        _calculateWeeklyProgress(RideController.instance.allRides);
    _emitFocusFromRides(RideController.instance.allRides);
  }

  Future<void> updateWeeklyGoal(int goal) async {
    await init();
    weeklyGoal.value = goal;
    await _prefs?.setInt('weekly_goal', goal);
  }

  void dispose() {
    _rideSubscription?.cancel();
    _pulsesController.close();
    _heatmapController.close();
    _focusController.close();
  }
}
