import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/utils/dummy_data.dart';
import '../core/utils/models.dart';

class OdysseyController {
  OdysseyController._();

  static final OdysseyController instance = OdysseyController._();

  final ValueNotifier<OdysseyPulse> pulse =
      ValueNotifier<OdysseyPulse>(defaultOdysseyPulse);
  final ValueNotifier<List<OdysseyChapter>> chapters =
      ValueNotifier<List<OdysseyChapter>>(<OdysseyChapter>[]);
  final ValueNotifier<OdysseyChapter?> focusChapter =
      ValueNotifier<OdysseyChapter?>(null);
  final ValueNotifier<List<OdysseyReflection>> reflections =
      ValueNotifier<List<OdysseyReflection>>(<OdysseyReflection>[]);

  final StreamController<List<OdysseyRoute>> _routeController =
      StreamController<List<OdysseyRoute>>.broadcast();
  final StreamController<List<OdysseyBeacon>> _beaconController =
      StreamController<List<OdysseyBeacon>>.broadcast();

  Stream<List<OdysseyRoute>> get routeStream => _routeController.stream;
  Stream<List<OdysseyBeacon>> get beaconStream => _beaconController.stream;

  bool _initialized = false;
  SharedPreferences? _prefs;
  final Random _random = Random();

  List<OdysseyChapter> _chapterStore = <OdysseyChapter>[];
  List<OdysseyRoute> _routeStore = <OdysseyRoute>[];
  List<OdysseyBeacon> _beaconStore = <OdysseyBeacon>[];
  List<OdysseyReflection> _reflectionStore = <OdysseyReflection>[];

  static const String _focusKey = 'odyssey_focus_chapter';
  static const String _routesKey = 'odyssey_tracked_routes';
  static const String _beaconsKey = 'odyssey_boosted_beacons';
  static const String _reflectionEntryPrefix = 'odyssey_reflection_entry_';
  static const String _reflectionEnergyPrefix = 'odyssey_reflection_energy_';
  static const String _reflectionSentimentPrefix =
      'odyssey_reflection_sentiment_';

  Future<void> init() async {
    if (_initialized) {
      _emit();
      return;
    }

    _prefs = await SharedPreferences.getInstance();
    final focusId = _prefs?.getString(_focusKey);
    final trackedIds = _prefs?.getStringList(_routesKey) ?? <String>[];
    final boostedIds = _prefs?.getStringList(_beaconsKey) ?? <String>[];

    _chapterStore = dummyOdysseyChapters.map((chapter) {
      final isFocus = focusId == null ? chapter.isFocus : chapter.id == focusId;
      return chapter.copyWith(isFocus: isFocus);
    }).toList();

    _routeStore = dummyOdysseyRoutes.map((route) {
      final tracking = trackedIds.contains(route.id);
      return route.copyWith(tracking: tracking);
    }).toList();

    _beaconStore = dummyOdysseyBeacons.map((beacon) {
      final boosted = boostedIds.contains(beacon.id);
      return beacon.copyWith(boosted: boosted);
    }).toList();

    _reflectionStore = dummyOdysseyReflections.map((reflection) {
      final entry =
          _prefs?.getString('$_reflectionEntryPrefix${reflection.id}');
      final energy =
          _prefs?.getDouble('$_reflectionEnergyPrefix${reflection.id}');
      final sentiment =
          _prefs?.getString('$_reflectionSentimentPrefix${reflection.id}');
      return reflection.copyWith(
        lastEntry: entry,
        energy: energy,
        sentiment: sentiment,
      );
    }).toList();

    pulse.value = defaultOdysseyPulse.copyWith(
      focus: _sampleFocus(),
      window: _sampleWindow(),
      nextMilestone: _sampleMilestone(),
      storyBeat: _sampleBeat(),
      rhythm: _nudge(defaultOdysseyPulse.rhythm),
      momentum: _nudge(defaultOdysseyPulse.momentum),
    );

    chapters.value = List<OdysseyChapter>.from(_chapterStore);
    focusChapter.value = _resolveFocus();
    _routeController.add(List<OdysseyRoute>.from(_routeStore));
    _beaconController.add(List<OdysseyBeacon>.from(_beaconStore));
    reflections.value = List<OdysseyReflection>.from(_reflectionStore);

    _initialized = true;
  }

  void _emit() {
    chapters.value = List<OdysseyChapter>.from(_chapterStore);
    focusChapter.value = _resolveFocus();
    _routeController.add(List<OdysseyRoute>.from(_routeStore));
    _beaconController.add(List<OdysseyBeacon>.from(_beaconStore));
    reflections.value = List<OdysseyReflection>.from(_reflectionStore);
  }

  Future<void> refreshPulse() async {
    await init();
    pulse.value = pulse.value.copyWith(
      rhythm: _nudge(pulse.value.rhythm),
      momentum: _nudge(pulse.value.momentum),
      focus: _sampleFocus(),
      window: _sampleWindow(),
      nextMilestone: _sampleMilestone(),
      storyBeat: _sampleBeat(),
    );

    _chapterStore = _chapterStore.map((chapter) {
      final progress = _nudge(chapter.progress);
      final spotlight = _sampleBeat();
      return chapter.copyWith(progress: progress, spotlight: spotlight);
    }).toList();

    _routeStore = _routeStore.map((route) {
      final readiness = _nudge(route.readiness);
      final stage = _random.nextBool() ? route.stage : _sampleStage(route.stage);
      return route.copyWith(readiness: readiness, stage: stage);
    }).toList();

    _beaconStore = _beaconStore.map((beacon) {
      final energy = _nudge(beacon.energy);
      final eta = _sampleMilestone();
      return beacon.copyWith(energy: energy, eta: eta);
    }).toList();

    _emit();
  }

  Future<void> focusOnChapter(String id) async {
    await init();
    if (_chapterStore.isEmpty) {
      return;
    }
    _chapterStore = _chapterStore
        .map((chapter) => chapter.copyWith(isFocus: chapter.id == id))
        .toList();
    final focus = _chapterStore.firstWhere(
      (chapter) => chapter.id == id,
      orElse: () => _chapterStore.first,
    );
    pulse.value = pulse.value.copyWith(focus: focus.title);
    await _prefs?.setString(_focusKey, id);
    _emit();
  }

  Future<void> toggleRoute(String id) async {
    await init();
    final index = _routeStore.indexWhere((route) => route.id == id);
    if (index == -1) return;
    final current = _routeStore[index];
    final updated = current.copyWith(tracking: !current.tracking);
    _routeStore[index] = updated;
    await _prefs?.setStringList(
      _routesKey,
      _routeStore.where((route) => route.tracking).map((e) => e.id).toList(),
    );
    _emit();
  }

  Future<void> toggleBeacon(String id) async {
    await init();
    final index = _beaconStore.indexWhere((beacon) => beacon.id == id);
    if (index == -1) return;
    final current = _beaconStore[index];
    final updated = current.copyWith(boosted: !current.boosted);
    _beaconStore[index] = updated;
    await _prefs?.setStringList(
      _beaconsKey,
      _beaconStore.where((beacon) => beacon.boosted).map((e) => e.id).toList(),
    );
    _emit();
  }

  Future<void> logReflection({
    required String id,
    required String entry,
    required double energy,
    required String sentiment,
  }) async {
    await init();
    final index = _reflectionStore.indexWhere((reflection) => reflection.id == id);
    if (index == -1) return;
    final updated = _reflectionStore[index]
        .copyWith(lastEntry: entry, energy: energy, sentiment: sentiment);
    _reflectionStore[index] = updated;
    await _prefs?.setString('$_reflectionEntryPrefix$id', entry);
    await _prefs?.setDouble('$_reflectionEnergyPrefix$id', energy);
    await _prefs?.setString('$_reflectionSentimentPrefix$id', sentiment);
    _emit();
  }

  String _sampleFocus() =>
      dummyOdysseyFocuses[_random.nextInt(dummyOdysseyFocuses.length)];

  String _sampleWindow() =>
      dummyOdysseyWindows[_random.nextInt(dummyOdysseyWindows.length)];

  String _sampleMilestone() =>
      dummyOdysseyMilestones[_random.nextInt(dummyOdysseyMilestones.length)];

  String _sampleBeat() =>
      dummyOdysseyBeats[_random.nextInt(dummyOdysseyBeats.length)];

  String _sampleStage(String current) {
    const stages = ['Explore', 'Sculpt', 'Prototype', 'Launch'];
    final filtered = stages.where((stage) => stage != current).toList();
    return filtered[_random.nextInt(filtered.length)];
  }

  double _nudge(double value) {
    final delta = (_random.nextDouble() * 0.12) - 0.06;
    final result = (value + delta).clamp(0.0, 1.0);
    return double.parse(result.toStringAsFixed(2));
  }

  OdysseyChapter? _resolveFocus() {
    if (_chapterStore.isEmpty) {
      return null;
    }
    return _chapterStore.firstWhere(
      (chapter) => chapter.isFocus,
      orElse: () => _chapterStore.first,
    );
  }
}
