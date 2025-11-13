import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/utils/dummy_data.dart';
import '../core/utils/models.dart';

class PlannerController {
  PlannerController._();

  static final PlannerController instance = PlannerController._();

  final ValueNotifier<List<ShiftScenario>> scenarios =
      ValueNotifier<List<ShiftScenario>>(<ShiftScenario>[]);
  final ValueNotifier<ShiftScenario?> activeScenario =
      ValueNotifier<ShiftScenario?>(null);
  final ValueNotifier<int> focusMinutes = ValueNotifier<int>(180);
  final ValueNotifier<bool> autonomousBoost = ValueNotifier<bool>(false);

  final StreamController<List<ShiftSegmentPlan>> _timelineController =
      StreamController<List<ShiftSegmentPlan>>.broadcast();
  final StreamController<List<MomentumAction>> _actionsController =
      StreamController<List<MomentumAction>>.broadcast();
  final StreamController<PlannerSummary> _summaryController =
      StreamController<PlannerSummary>.broadcast();

  SharedPreferences? _prefs;
  bool _initialized = false;
  late List<ShiftScenario> _baseScenarios;

  Stream<List<ShiftSegmentPlan>> get timelineStream =>
      _timelineController.stream;
  Stream<List<MomentumAction>> get actionsStream =>
      _actionsController.stream;
  Stream<PlannerSummary> get summaryStream => _summaryController.stream;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    _prefs = await SharedPreferences.getInstance();
    _baseScenarios = List<ShiftScenario>.from(dummyShiftScenarios);
    scenarios.value = List<ShiftScenario>.from(_baseScenarios);

    final storedMinutes = _prefs?.getInt('planner_focus_minutes');
    final storedBoost = _prefs?.getBool('planner_autonomous');
    final storedScenarioId = _prefs?.getString('planner_scenario');

    if (storedMinutes != null) {
      focusMinutes.value = storedMinutes.clamp(90, 420);
    }
    if (storedBoost != null) {
      autonomousBoost.value = storedBoost;
    }

    ShiftScenario scenario = _baseScenarios.first;
    if (storedScenarioId != null) {
      try {
        scenario = _baseScenarios
            .firstWhere((element) => element.id == storedScenarioId);
      } catch (_) {
        scenario = _baseScenarios.first;
      }
    }

    _emitScenario(scenario);
  }

  void selectScenario(String id) {
    ShiftScenario scenario = _baseScenarios.first;
    try {
      scenario = _baseScenarios.firstWhere((element) => element.id == id);
    } catch (_) {
      scenario = _baseScenarios.first;
    }
    _emitScenario(scenario);
  }

  Future<void> updateFocusMinutes(int minutes) async {
    await init();
    focusMinutes.value = minutes.clamp(90, 420);
    await _prefs?.setInt('planner_focus_minutes', focusMinutes.value);
    final current = activeScenario.value ?? _baseScenarios.first;
    _emitScenario(current, persistSelection: false);
  }

  Future<void> toggleAutonomous(bool value) async {
    await init();
    autonomousBoost.value = value;
    await _prefs?.setBool('planner_autonomous', value);
    final current = activeScenario.value ?? _baseScenarios.first;
    _emitScenario(current, persistSelection: false);
  }

  Future<void> regeneratePlan() async {
    await init();
    final currentId = activeScenario.value?.id ?? _baseScenarios.first.id;
    ShiftScenario base;
    try {
      base = _baseScenarios.firstWhere((scenario) => scenario.id == currentId);
    } catch (_) {
      base = _baseScenarios.first;
    }
    final random = Random();
    final mutatedTimeline = base.timeline.map((segment) {
      final demandVariation = (random.nextDouble() * 0.24) - 0.12;
      final adjustedDemand =
          (segment.demandScore + demandVariation).clamp(0.35, 0.96);
      final tripVariation = random.nextInt(3) - 1;
      return segment.copyWith(
        demandScore: double.parse(adjustedDemand.toStringAsFixed(2)),
        expectedTrips: max(1, segment.expectedTrips + tripVariation),
      );
    }).toList();
    final mutatedActions = base.actions.map((action) {
      if (!autonomousBoost.value && random.nextBool()) {
        return action;
      }
      final inflection = random.nextBool() ? '↑' : '⚡';
      return action.copyWith(impact: '${action.impact} $inflection');
    }).toList();
    final mutated = base.copyWith(
      timeline: mutatedTimeline,
      actions: mutatedActions,
    );
    _emitScenario(mutated, persistSelection: false);
  }

  void _emitScenario(ShiftScenario scenario, {bool persistSelection = true}) {
    activeScenario.value = scenario;
    if (persistSelection) {
      _prefs?.setString('planner_scenario', scenario.id);
    }
    final double factor = focusMinutes.value / 180;
    final double boost = autonomousBoost.value ? 1.08 : 1.0;
    final timeline = scenario.timeline.map((segment) {
      final demand = (segment.demandScore * boost).clamp(0.35, 1.0);
      final trips = max(1, (segment.expectedTrips * factor).round());
      return segment.copyWith(
        demandScore: double.parse(demand.toStringAsFixed(2)),
        expectedTrips: trips,
      );
    }).toList();
    _timelineController.add(timeline);

    final actions = scenario.actions.map((action) {
      if (!autonomousBoost.value) {
        return action;
      }
      final enhanced = action.impact.contains('+')
          ? '${action.impact} ⚡'
          : '${action.impact}+';
      return action.copyWith(impact: enhanced);
    }).toList();
    _actionsController.add(actions);

    final totalTrips = timeline.fold<int>(0, (sum, seg) => sum + seg.expectedTrips);
    final avgDemand = timeline.isEmpty
        ? 0.0
        : timeline.fold<double>(0.0, (sum, seg) => sum + seg.demandScore) /
            timeline.length;
    final projectedEarnings = scenario.earningTarget * factor * boost;
    final confidence =
        ((1 - scenario.riskLevel) * (autonomousBoost.value ? 1.04 : 1.0))
            .clamp(0.3, 1.0);

    _summaryController.add(
      PlannerSummary(
        projectedEarnings: projectedEarnings,
        expectedTrips: totalTrips,
        averageDemand: avgDemand,
        confidence: confidence,
      ),
    );
  }

  void dispose() {
    _timelineController.close();
    _actionsController.close();
    _summaryController.close();
  }
}
