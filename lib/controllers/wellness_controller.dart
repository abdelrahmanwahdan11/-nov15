import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/utils/dummy_data.dart';
import '../core/utils/models.dart';

class WellnessController {
  WellnessController._();

  static final WellnessController instance = WellnessController._();

  final ValueNotifier<List<MindfulRitual>> rituals =
      ValueNotifier<List<MindfulRitual>>(<MindfulRitual>[]);
  final ValueNotifier<MindfulRitual?> spotlight =
      ValueNotifier<MindfulRitual?>(null);
  final ValueNotifier<WellnessSnapshot> snapshot =
      ValueNotifier<WellnessSnapshot>(defaultWellnessSnapshot);
  final ValueNotifier<String> vibe = ValueNotifier<String>('calm');

  final StreamController<List<BreathGuide>> _breathController =
      StreamController<List<BreathGuide>>.broadcast();
  final StreamController<List<RecoveryMoment>> _momentController =
      StreamController<List<RecoveryMoment>>.broadcast();

  Stream<List<BreathGuide>> get breathStream => _breathController.stream;
  Stream<List<RecoveryMoment>> get momentsStream => _momentController.stream;
  List<BreathGuide> get currentBreaths =>
      List<BreathGuide>.unmodifiable(_currentBreaths);
  List<RecoveryMoment> get currentMoments =>
      List<RecoveryMoment>.unmodifiable(_currentMoments);

  SharedPreferences? _prefs;
  bool _initialized = false;
  Set<String> _completed = <String>{};
  final Random _random = Random();
  List<BreathGuide> _currentBreaths = <BreathGuide>[];
  List<RecoveryMoment> _currentMoments = <RecoveryMoment>[];

  static const Map<String, String> _vibeMessages = {
    'calm': 'Centered and ready for adaptive driving.',
    'focus': 'Dialed-in for precision and confident pivots.',
    'energize': 'Charged to surf demand waves with stamina.',
  };

  Future<void> init() async {
    if (_initialized) {
      _emitBreaths();
      _emitMoments();
      return;
    }
    _initialized = true;
    _prefs = await SharedPreferences.getInstance();
    final storedCompleted = _prefs?.getStringList('wellness_completed') ?? <String>[];
    _completed = storedCompleted.toSet();
    final storedVibe = _prefs?.getString('wellness_vibe');
    if (storedVibe != null && storedVibe.isNotEmpty) {
      vibe.value = storedVibe;
    }
    final storedEnergy = _prefs?.getDouble('wellness_energy');
    final storedFocus = _prefs?.getDouble('wellness_focus');

    _rebuildRituals();
    _emitBreaths();
    _emitMoments();

    snapshot.value = defaultWellnessSnapshot.copyWith(
      energyScore: storedEnergy ?? defaultWellnessSnapshot.energyScore,
      focusScore: storedFocus ?? defaultWellnessSnapshot.focusScore,
      message: _vibeMessages[vibe.value] ?? defaultWellnessSnapshot.message,
      vibe: vibe.value,
    );
    _updateSnapshot();
  }

  Future<void> toggleCompletion(String id) async {
    await init();
    if (_completed.contains(id)) {
      _completed.remove(id);
    } else {
      _completed.add(id);
    }
    await _prefs?.setStringList('wellness_completed', _completed.toList());
    _rebuildRituals();
    _updateSnapshot();
  }

  Future<void> selectVibe(String value) async {
    await init();
    vibe.value = value;
    await _prefs?.setString('wellness_vibe', value);
    _rebuildRituals();
    _emitBreaths();
    _emitMoments();
    _updateSnapshot(message: _vibeMessages[value]);
  }

  Future<void> updateEnergy(double energy) async {
    await init();
    final normalized = energy.clamp(0.2, 1.0);
    await _prefs?.setDouble('wellness_energy', normalized);
    _updateSnapshot(energy: normalized);
  }

  Future<void> updateFocus(double focus) async {
    await init();
    final normalized = focus.clamp(0.2, 1.0);
    await _prefs?.setDouble('wellness_focus', normalized);
    _updateSnapshot(focus: normalized);
  }

  Future<void> refreshRhythm() async {
    await init();
    _emitBreaths(forceShuffle: true);
    _emitMoments(forceShuffle: true);
    _updateSnapshot(message: _vibeMessages[vibe.value]);
  }

  void _rebuildRituals() {
    final ordered = dummyMindfulRituals
        .map((ritual) => ritual.copyWith(
              completed: _completed.contains(ritual.id),
            ))
        .toList();
    ordered.sort((a, b) {
      final aVibe = a.focusTag == vibe.value;
      final bVibe = b.focusTag == vibe.value;
      if (aVibe != bVibe) {
        return aVibe ? -1 : 1;
      }
      if (a.completed != b.completed) {
        return a.completed ? 1 : -1;
      }
      return a.title.compareTo(b.title);
    });
    rituals.value = ordered;
    if (ordered.isEmpty) {
      spotlight.value = null;
      return;
    }
    try {
      spotlight.value = ordered.firstWhere(
        (ritual) => ritual.focusTag == vibe.value && !ritual.completed,
      );
    } catch (_) {
      spotlight.value = ordered.first;
    }
  }

  void _emitBreaths({bool forceShuffle = false}) {
    final focusMatches = dummyBreathGuides
        .where((guide) => guide.focusTag == vibe.value)
        .toList();
    final others = dummyBreathGuides
        .where((guide) => guide.focusTag != vibe.value)
        .toList();
    if (forceShuffle || !_initialized) {
      focusMatches.shuffle(_random);
      others.shuffle(_random);
    }
    final selection = <BreathGuide>[];
    selection.addAll(focusMatches.take(2));
    selection.addAll(others.take(2));
    if (selection.isEmpty && dummyBreathGuides.isNotEmpty) {
      selection.add(dummyBreathGuides.first);
    }
    _currentBreaths = selection;
    _breathController.add(selection);
  }

  void _emitMoments({bool forceShuffle = false}) {
    final matches = dummyRecoveryMoments
        .where((moment) => moment.vibes.contains(vibe.value))
        .toList();
    final alternates = dummyRecoveryMoments
        .where((moment) => !moment.vibes.contains(vibe.value))
        .toList();
    if (forceShuffle || !_initialized) {
      matches.shuffle(_random);
      alternates.shuffle(_random);
    }
    final selection = <RecoveryMoment>[];
    selection.addAll(matches.take(3));
    selection.addAll(alternates.take(2));
    if (selection.isEmpty && dummyRecoveryMoments.isNotEmpty) {
      selection.add(dummyRecoveryMoments.first);
    }
    _currentMoments = selection;
    _momentController.add(selection);
  }

  void _updateSnapshot({double? energy, double? focus, String? message}) {
    final ratio = rituals.value.isEmpty
        ? 0.0
        : _completed.length / rituals.value.length;
    final base = snapshot.value;
    final alignment = (0.48 + ratio * 0.42).clamp(0.35, 1.0);
    final noteSet = <String>{
      '${(ratio * 100).round()}% rituals tuned',
      'Vibe • ${vibe.value}',
      if (_currentBreaths.isNotEmpty)
        '${_currentBreaths.first.title} ready',
      if (_currentMoments.isNotEmpty)
        '${_currentMoments.first.title} next',
    }..removeWhere((element) => element.isEmpty);
    snapshot.value = base.copyWith(
      alignmentScore:
          double.parse(alignment.toStringAsFixed(2)),
      energyScore: energy != null
          ? double.parse(energy.clamp(0.2, 1.0).toStringAsFixed(2))
          : base.energyScore,
      focusScore: focus != null
          ? double.parse(focus.clamp(0.2, 1.0).toStringAsFixed(2))
          : base.focusScore,
      message: message ?? base.message,
      anchorNotes: noteSet.take(3).toList(),
      vibe: vibe.value,
    );
  }

  void dispose() {
    _breathController.close();
    _momentController.close();
  }
}
