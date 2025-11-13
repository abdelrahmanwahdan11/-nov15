import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/utils/dummy_data.dart';
import '../core/utils/models.dart';

class InnovationController {
  InnovationController._();

  static final InnovationController instance = InnovationController._();

  final ValueNotifier<InnovationPulse> pulse =
      ValueNotifier<InnovationPulse>(defaultInnovationPulse);
  final ValueNotifier<List<InnovationPrototype>> prototypes =
      ValueNotifier<List<InnovationPrototype>>(<InnovationPrototype>[]);
  final ValueNotifier<List<InnovationBlueprint>> blueprints =
      ValueNotifier<List<InnovationBlueprint>>(<InnovationBlueprint>[]);

  final StreamController<List<InnovationExperiment>> _experimentController =
      StreamController<List<InnovationExperiment>>.broadcast();

  Stream<List<InnovationExperiment>> get experimentStream =>
      _experimentController.stream;

  SharedPreferences? _prefs;
  bool _initialized = false;
  final Random _random = Random();

  List<InnovationPrototype> _prototypeStore = <InnovationPrototype>[];
  List<InnovationExperiment> _experiments = <InnovationExperiment>[];
  List<InnovationBlueprint> _blueprintStore = <InnovationBlueprint>[];
  List<String> _lanes = List<String>.from(innovationFocusLanes);
  List<String> _bursts = List<String>.from(dummyInnovationBursts);

  static const List<String> _stageOrder = <String>['discover', 'design', 'pilot', 'scale'];
  static const _prototypeKey = 'innovation_prototypes';
  static const _temperatureKey = 'innovation_temperature';

  Future<void> init() async {
    if (_initialized) {
      _emit();
      return;
    }
    _prefs = await SharedPreferences.getInstance();
    final storedEntries = _prefs?.getStringList(_prototypeKey) ?? <String>[];
    final storedTemperature =
        _prefs?.getDouble(_temperatureKey) ?? defaultInnovationPulse.temperature;

    final progressMap = <String, List<String>>{};
    for (final entry in storedEntries) {
      final parts = entry.split('|');
      if (parts.length >= 4) {
        progressMap[parts[0]] = parts;
      }
    }

    _prototypeStore = dummyInnovationPrototypes.map((prototype) {
      final parts = progressMap[prototype.id];
      if (parts == null) {
        return prototype;
      }
      final stage = parts[1];
      final progress = double.tryParse(parts[2]) ?? prototype.progress;
      final confidence = double.tryParse(parts[3]) ?? prototype.confidence;
      return prototype.copyWith(
        stage: stage,
        progress: progress,
        confidence: confidence,
      );
    }).toList();

    _experiments = List<InnovationExperiment>.from(dummyInnovationExperiments);
    _blueprintStore = List<InnovationBlueprint>.from(dummyInnovationBlueprints);
    _lanes = List<String>.from(innovationFocusLanes);
    _bursts = List<String>.from(dummyInnovationBursts);

    prototypes.value = List<InnovationPrototype>.from(_prototypeStore);
    blueprints.value = List<InnovationBlueprint>.from(_blueprintStore);
    pulse.value = defaultInnovationPulse.copyWith(
      readiness: _calculateReadiness(),
      temperature: storedTemperature,
      focusLanes: List<String>.from(_lanes),
      energyBursts: _bursts.take(3).toList(),
    );
    _experimentController.add(List<InnovationExperiment>.from(_experiments));
    _initialized = true;
  }

  void _emit() {
    prototypes.value = List<InnovationPrototype>.from(_prototypeStore);
    blueprints.value = List<InnovationBlueprint>.from(_blueprintStore);
    pulse.value = pulse.value.copyWith(
      focusLanes: List<String>.from(_lanes),
      energyBursts: _bursts.take(3).toList(),
    );
    _experimentController.add(List<InnovationExperiment>.from(_experiments));
  }

  double _calculateReadiness() {
    if (_prototypeStore.isEmpty) {
      return defaultInnovationPulse.readiness;
    }
    final total = _prototypeStore.fold<double>(
      0,
      (sum, prototype) => sum + prototype.progress,
    );
    return (total / _prototypeStore.length).clamp(0.0, 1.0);
  }

  Future<void> advancePrototype(String id) async {
    await init();
    final index = _prototypeStore.indexWhere((prototype) => prototype.id == id);
    if (index == -1) return;
    final current = _prototypeStore[index];
    final currentStageIndex = _stageOrder.indexOf(current.stage);
    final nextIndex = currentStageIndex == -1
        ? 0
        : (currentStageIndex + 1) % _stageOrder.length;
    final nextStage = _stageOrder[nextIndex];
    final resetCycle = currentStageIndex == _stageOrder.length - 1;
    final baseProgress =
        resetCycle ? 0.25 : (nextIndex + 1) / _stageOrder.length;
    final progressValue = resetCycle
        ? baseProgress
        : max(current.progress, baseProgress).clamp(0.0, 1.0);
    final updated = current.copyWith(
      stage: nextStage,
      progress: progressValue,
      confidence: min(1.0, current.confidence + 0.1),
      nextStep: innovationStageNextSteps[nextStage] ?? current.nextStep,
      lastNote: _sampleNote(),
    );
    _prototypeStore[index] = updated;
    prototypes.value = List<InnovationPrototype>.from(_prototypeStore);
    await _persist();
    _updatePulseAfterChange();
  }

  Future<void> rotateFocusLane() async {
    await init();
    if (_lanes.isEmpty) return;
    final first = _lanes.removeAt(0);
    _lanes.add(first);
    pulse.value = pulse.value.copyWith(focusLanes: List<String>.from(_lanes));
  }

  Future<void> refreshPulse() async {
    await init();
    _lanes.shuffle(_random);
    _experiments.shuffle(_random);
    _bursts.shuffle(_random);
    _experimentController.add(List<InnovationExperiment>.from(_experiments));
    pulse.value = pulse.value.copyWith(
      readiness: _calculateReadiness(),
      temperature: _nextTemperature(),
      headline: _sampleHeadline(),
      focusLanes: List<String>.from(_lanes),
      energyBursts: _bursts.take(3).toList(),
      nextReview: _nextReviewSlot(),
    );
    await _prefs?.setDouble(_temperatureKey, pulse.value.temperature);
  }

  Future<void> _persist() async {
    final entries = _prototypeStore.map((prototype) {
      final progress = prototype.progress.toStringAsFixed(3);
      final confidence = prototype.confidence.toStringAsFixed(3);
      return '${prototype.id}|${prototype.stage}|$progress|$confidence';
    }).toList();
    await _prefs?.setStringList(_prototypeKey, entries);
  }

  void _updatePulseAfterChange() {
    _bursts.shuffle(_random);
    pulse.value = pulse.value.copyWith(
      readiness: _calculateReadiness(),
      temperature: _nextTemperature(),
      headline: _sampleHeadline(),
      energyBursts: _bursts.take(3).toList(),
    );
    _prefs?.setDouble(_temperatureKey, pulse.value.temperature);
  }

  double _nextTemperature() {
    final delta = (_random.nextDouble() * 0.16) - 0.08;
    final composite =
        pulse.value.temperature + delta + (_calculateReadiness() - 0.5) * 0.08;
    return composite.clamp(0.3, 1.0);
  }

  String _sampleHeadline() {
    if (dummyInnovationHeadlines.isEmpty) {
      return pulse.value.headline;
    }
    return dummyInnovationHeadlines[_random.nextInt(dummyInnovationHeadlines.length)];
  }

  String _nextReviewSlot() {
    if (dummyInnovationReviewSlots.isEmpty) {
      return pulse.value.nextReview;
    }
    return dummyInnovationReviewSlots[_random.nextInt(dummyInnovationReviewSlots.length)];
  }

  String _sampleNote() {
    if (dummyInnovationNotes.isEmpty) {
      return pulse.value.headline;
    }
    return dummyInnovationNotes[_random.nextInt(dummyInnovationNotes.length)];
  }
}
