import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/utils/dummy_data.dart';
import '../core/utils/models.dart';

class HorizonController {
  HorizonController._();

  static final HorizonController instance = HorizonController._();

  final ValueNotifier<HorizonPulse> pulse =
      ValueNotifier<HorizonPulse>(defaultHorizonPulse);
  final ValueNotifier<List<HorizonScenario>> scenarios =
      ValueNotifier<List<HorizonScenario>>(<HorizonScenario>[]);
  final ValueNotifier<List<HorizonBlueprint>> blueprints =
      ValueNotifier<List<HorizonBlueprint>>(<HorizonBlueprint>[]);

  final StreamController<List<HorizonSignal>> _signalController =
      StreamController<List<HorizonSignal>>.broadcast();
  final StreamController<List<HorizonRunwayMarker>> _runwayController =
      StreamController<List<HorizonRunwayMarker>>.broadcast();

  Stream<List<HorizonSignal>> get signalStream => _signalController.stream;
  Stream<List<HorizonRunwayMarker>> get runwayStream =>
      _runwayController.stream;

  SharedPreferences? _prefs;
  bool _initialized = false;
  final Random _random = Random();

  List<HorizonScenario> _scenarioStore = <HorizonScenario>[];
  List<HorizonSignal> _signalStore = <HorizonSignal>[];
  List<HorizonRunwayMarker> _runwayStore = <HorizonRunwayMarker>[];
  List<HorizonBlueprint> _blueprintStore = <HorizonBlueprint>[];

  static const String _scenarioKey = 'horizon_scenarios';
  static const String _signalKey = 'horizon_signals';
  static const String _runwayKey = 'horizon_runway';
  static const String _alignmentKey = 'horizon_alignment';
  static const List<String> _blueprintStatuses = <String>[
    'Queued',
    'In review',
    'Activating',
    'Live',
  ];

  Future<void> init() async {
    if (_initialized) {
      _emit();
      return;
    }
    _prefs = await SharedPreferences.getInstance();
    final storedFocus = _prefs?.getStringList(_scenarioKey) ?? <String>[];
    final storedSignals = _prefs?.getStringList(_signalKey) ?? <String>[];
    final storedRunway = _prefs?.getStringList(_runwayKey) ?? <String>[];
    final storedAlignment =
        _prefs?.getDouble(_alignmentKey) ?? defaultHorizonPulse.alignment;

    final focusId = storedFocus.isNotEmpty ? storedFocus.first : null;
    _scenarioStore = dummyHorizonScenarios.map((scenario) {
      final isFocus = focusId == null
          ? scenario.isFocus
          : scenario.id == focusId;
      return scenario.copyWith(isFocus: isFocus);
    }).toList();

    _signalStore = dummyHorizonSignals.map((signal) {
      final flagged = storedSignals.contains(signal.id);
      return signal.copyWith(flagged: flagged);
    }).toList();

    _runwayStore = dummyHorizonRunway.map((marker) {
      final completed = storedRunway.contains(marker.id);
      return marker.copyWith(completed: completed);
    }).toList();

    _blueprintStore = List<HorizonBlueprint>.from(dummyHorizonBlueprints);

    pulse.value = defaultHorizonPulse.copyWith(
      alignment: storedAlignment,
      headline: _sampleHeadline(),
      guidingQuestion: _sampleQuestion(),
      signalHighlights: _currentHighlights(),
      focusThemes: _shuffleThemes(),
      nextWindow: _randomWindow(),
      confidence: _nudgeValue(defaultHorizonPulse.confidence),
    );
    scenarios.value = List<HorizonScenario>.from(_scenarioStore);
    blueprints.value = List<HorizonBlueprint>.from(_blueprintStore);
    _signalController.add(List<HorizonSignal>.from(_signalStore));
    _runwayController.add(List<HorizonRunwayMarker>.from(_runwayStore));
    _initialized = true;
  }

  void _emit() {
    scenarios.value = List<HorizonScenario>.from(_scenarioStore);
    blueprints.value = List<HorizonBlueprint>.from(_blueprintStore);
    _signalController.add(List<HorizonSignal>.from(_signalStore));
    _runwayController.add(List<HorizonRunwayMarker>.from(_runwayStore));
  }

  List<String> _currentHighlights() {
    final ordered = List<HorizonSignal>.from(_signalStore)
      ..sort((a, b) => b.momentum.compareTo(a.momentum));
    return ordered.take(3).map((signal) => signal.title).toList();
  }

  List<String> _shuffleThemes() {
    final themes = List<String>.from(defaultHorizonPulse.focusThemes);
    themes.shuffle(_random);
    return themes.take(3).toList();
  }

  String _sampleHeadline() {
    return dummyHorizonHeadlines[_random.nextInt(dummyHorizonHeadlines.length)];
  }

  String _sampleQuestion() {
    return dummyHorizonQuestions[_random.nextInt(dummyHorizonQuestions.length)];
  }

  String _randomWindow() {
    const windows = <String>['Thu 18:00', 'Sat 07:30', 'Sun 21:15', 'Mon 06:45'];
    return windows[_random.nextInt(windows.length)];
  }

  double _nudgeValue(double base) {
    final change = (_random.nextDouble() - 0.5) * 0.12;
    return (base + change).clamp(0.3, 0.95);
  }

  Future<void> refreshPulse() async {
    await init();
    _signalStore.shuffle(_random);
    pulse.value = pulse.value.copyWith(
      headline: _sampleHeadline(),
      guidingQuestion: _sampleQuestion(),
      alignment: _nudgeValue(pulse.value.alignment),
      confidence: _nudgeValue(pulse.value.confidence),
      signalHighlights: _currentHighlights(),
      focusThemes: _shuffleThemes(),
      nextWindow: _randomWindow(),
    );
    _signalController.add(List<HorizonSignal>.from(_signalStore));
    await _persistPulse();
  }

  Future<void> focusScenario(String id) async {
    await init();
    _scenarioStore = _scenarioStore
        .map((scenario) => scenario.copyWith(isFocus: scenario.id == id))
        .toList();
    scenarios.value = List<HorizonScenario>.from(_scenarioStore);
    await _prefs?.setStringList(
      _scenarioKey,
      _scenarioStore.where((scenario) => scenario.isFocus).map((s) => s.id).toList(),
    );
  }

  Future<void> toggleSignalFlag(String id) async {
    await init();
    final index = _signalStore.indexWhere((signal) => signal.id == id);
    if (index == -1) return;
    final current = _signalStore[index];
    final updated = current.copyWith(flagged: !current.flagged);
    _signalStore[index] = updated;
    _signalController.add(List<HorizonSignal>.from(_signalStore));
    await _prefs?.setStringList(
      _signalKey,
      _signalStore.where((signal) => signal.flagged).map((signal) => signal.id).toList(),
    );
  }

  Future<void> toggleRunway(String id) async {
    await init();
    final index = _runwayStore.indexWhere((marker) => marker.id == id);
    if (index == -1) return;
    final updated =
        _runwayStore[index].copyWith(completed: !_runwayStore[index].completed);
    _runwayStore[index] = updated;
    _runwayController.add(List<HorizonRunwayMarker>.from(_runwayStore));
    await _prefs?.setStringList(
      _runwayKey,
      _runwayStore
          .where((marker) => marker.completed)
          .map((marker) => marker.id)
          .toList(),
    );
  }

  Future<void> elevateAlignment() async {
    await init();
    final updated = (pulse.value.alignment + 0.05).clamp(0.0, 1.0);
    pulse.value = pulse.value.copyWith(alignment: updated);
    await _persistPulse();
  }

  Future<void> coolAlignment() async {
    await init();
    final updated = (pulse.value.alignment - 0.04).clamp(0.0, 1.0);
    pulse.value = pulse.value.copyWith(alignment: updated);
    await _persistPulse();
  }

  Future<void> advanceBlueprint(String id) async {
    await init();
    final index = _blueprintStore.indexWhere((blueprint) => blueprint.id == id);
    if (index == -1) return;
    final blueprint = _blueprintStore[index];
    final currentStage = _blueprintStatuses.indexOf(blueprint.status);
    final nextStage =
        _blueprintStatuses[(currentStage + 1) % _blueprintStatuses.length];
    final confidence = _nudgeValue(blueprint.confidence);
    final updated = blueprint.copyWith(status: nextStage, confidence: confidence);
    _blueprintStore[index] = updated;
    blueprints.value = List<HorizonBlueprint>.from(_blueprintStore);
  }

  Future<void> _persistPulse() async {
    await _prefs?.setDouble(_alignmentKey, pulse.value.alignment);
  }
}
