import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/utils/dummy_data.dart';
import '../core/utils/models.dart';

class FusionController {
  FusionController._();

  static final FusionController instance = FusionController._();

  final ValueNotifier<FusionPulse> pulse =
      ValueNotifier<FusionPulse>(defaultFusionPulse);
  final ValueNotifier<List<FusionStrand>> strands =
      ValueNotifier<List<FusionStrand>>(<FusionStrand>[]);
  final ValueNotifier<List<FusionCanvas>> canvases =
      ValueNotifier<List<FusionCanvas>>(<FusionCanvas>[]);

  final StreamController<List<FusionExperiment>> _experimentController =
      StreamController<List<FusionExperiment>>.broadcast();
  final StreamController<List<FusionSignal>> _signalController =
      StreamController<List<FusionSignal>>.broadcast();

  Stream<List<FusionExperiment>> get experimentStream =>
      _experimentController.stream;
  Stream<List<FusionSignal>> get signalStream => _signalController.stream;

  bool _initialized = false;
  SharedPreferences? _prefs;
  final Random _random = Random();

  List<FusionStrand> _strandStore = <FusionStrand>[];
  List<FusionCanvas> _canvasStore = <FusionCanvas>[];
  List<FusionExperiment> _experimentStore = <FusionExperiment>[];
  List<FusionSignal> _signalStore = <FusionSignal>[];

  static const String _focusKey = 'fusion_focus_thread';
  static const String _activeKey = 'fusion_active_experiments';
  static const String _capturedKey = 'fusion_captured_signals';

  Future<void> init() async {
    if (_initialized) {
      _emit();
      return;
    }

    _prefs = await SharedPreferences.getInstance();
    final focusId = _prefs?.getString(_focusKey);
    final activeIds = _prefs?.getStringList(_activeKey) ?? <String>[];
    final capturedIds = _prefs?.getStringList(_capturedKey) ?? <String>[];

    _strandStore = dummyFusionStrands.map((strand) {
      final isFocus = focusId == null ? strand.isFocus : strand.id == focusId;
      return strand.copyWith(isFocus: isFocus);
    }).toList();

    _canvasStore = List<FusionCanvas>.from(dummyFusionCanvases);

    _experimentStore = dummyFusionExperiments.map((experiment) {
      final isActive = activeIds.contains(experiment.id);
      return experiment.copyWith(active: isActive);
    }).toList();

    _signalStore = dummyFusionSignals.map((signal) {
      final captured = capturedIds.contains(signal.id);
      return signal.copyWith(captured: captured);
    }).toList();

    pulse.value = defaultFusionPulse.copyWith(
      headline: _sampleHeadline(),
      focus: _sampleFocus(),
      nextSync: _sampleSync(),
      highlight: _sampleHighlight(),
      alignment: _nudge(defaultFusionPulse.alignment),
      cohesion: _nudge(defaultFusionPulse.cohesion),
    );

    strands.value = List<FusionStrand>.from(_strandStore);
    canvases.value = List<FusionCanvas>.from(_canvasStore);
    _experimentController.add(List<FusionExperiment>.from(_experimentStore));
    _signalController.add(List<FusionSignal>.from(_signalStore));

    _initialized = true;
  }

  void _emit() {
    strands.value = List<FusionStrand>.from(_strandStore);
    canvases.value = List<FusionCanvas>.from(_canvasStore);
    _experimentController.add(List<FusionExperiment>.from(_experimentStore));
    _signalController.add(List<FusionSignal>.from(_signalStore));
  }

  Future<void> refreshPulse() async {
    await init();
    pulse.value = pulse.value.copyWith(
      headline: _sampleHeadline(),
      focus: _sampleFocus(),
      nextSync: _sampleSync(),
      highlight: _sampleHighlight(),
      alignment: _nudge(pulse.value.alignment),
      cohesion: _nudge(pulse.value.cohesion),
    );

    _strandStore = _strandStore.map((strand) {
      final alignment = _nudge(strand.alignment);
      final flow = _nudge(strand.flow);
      return strand.copyWith(alignment: alignment, flow: flow);
    }).toList();
    strands.value = List<FusionStrand>.from(_strandStore);

    _canvasStore = _canvasStore.map((canvas) {
      final heat = _nudge(canvas.heat);
      final cohesion = _nudge(canvas.cohesion);
      return canvas.copyWith(heat: heat, cohesion: cohesion);
    }).toList()
      ..shuffle(_random);
    canvases.value = List<FusionCanvas>.from(_canvasStore);

    _experimentStore = _experimentStore.map((experiment) {
      double confidence;
      if (experiment.active) {
        confidence =
            ((experiment.confidence + 0.06).clamp(0.0, 1.0)).toDouble();
      } else {
        confidence = _nudge(experiment.confidence);
      }
      return experiment.copyWith(confidence: confidence);
    }).toList();
    _experimentController.add(List<FusionExperiment>.from(_experimentStore));

    _signalStore = _signalStore.map((signal) {
      final base = signal.captured
          ? signal.urgency - 1
          : signal.urgency + 1;
      final urgency = base.clamp(1, 5).toInt();
      return signal.copyWith(urgency: urgency);
    }).toList();
    _signalController.add(List<FusionSignal>.from(_signalStore));
  }

  Future<void> focusStrand(String id) async {
    await init();
    _strandStore = _strandStore
        .map((strand) => strand.copyWith(isFocus: strand.id == id))
        .toList();
    strands.value = List<FusionStrand>.from(_strandStore);
    await _prefs?.setString(_focusKey, id);
  }

  Future<void> toggleExperiment(String id) async {
    await init();
    final index =
        _experimentStore.indexWhere((experiment) => experiment.id == id);
    if (index == -1) return;
    final current = _experimentStore[index];
    final baseConfidence = current.active
        ? ((current.confidence - 0.04).clamp(0.0, 1.0)).toDouble()
        : ((current.confidence + 0.08).clamp(0.0, 1.0)).toDouble();
    final updated = current.copyWith(
      active: !current.active,
      confidence: _nudge(baseConfidence),
    );
    _experimentStore[index] = updated;
    _experimentController.add(List<FusionExperiment>.from(_experimentStore));
    await _prefs?.setStringList(
      _activeKey,
      _experimentStore
          .where((experiment) => experiment.active)
          .map((experiment) => experiment.id)
          .toList(),
    );
  }

  Future<void> toggleSignalCapture(String id) async {
    await init();
    final index = _signalStore.indexWhere((signal) => signal.id == id);
    if (index == -1) return;
    final current = _signalStore[index];
    final base = current.captured ? current.urgency + 1 : current.urgency - 1;
    final urgency = base.clamp(1, 5).toInt();
    final updated = current.copyWith(
      captured: !current.captured,
      urgency: urgency,
    );
    _signalStore[index] = updated;
    _signalController.add(List<FusionSignal>.from(_signalStore));
    await _prefs?.setStringList(
      _capturedKey,
      _signalStore
          .where((signal) => signal.captured)
          .map((signal) => signal.id)
          .toList(),
    );
  }

  double _nudge(double value) {
    final delta = (_random.nextDouble() * 0.14) - 0.07;
    return (value + delta).clamp(0.0, 1.0);
  }

  String _sampleHeadline() =>
      dummyFusionHeadlines[_random.nextInt(dummyFusionHeadlines.length)];

  String _sampleHighlight() =>
      dummyFusionHighlights[_random.nextInt(dummyFusionHighlights.length)];

  String _sampleFocus() =>
      dummyFusionFocuses[_random.nextInt(dummyFusionFocuses.length)];

  String _sampleSync() =>
      dummyFusionSyncs[_random.nextInt(dummyFusionSyncs.length)];
}
