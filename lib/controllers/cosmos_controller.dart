import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/utils/dummy_data.dart';
import '../core/utils/models.dart';

class CosmosController {
  CosmosController._();

  static final CosmosController instance = CosmosController._();

  final ValueNotifier<CosmosPulse> pulse =
      ValueNotifier<CosmosPulse>(defaultCosmosPulse);
  final ValueNotifier<List<CosmosConstellation>> constellations =
      ValueNotifier<List<CosmosConstellation>>(<CosmosConstellation>[]);
  final ValueNotifier<List<CosmosOrbit>> orbits =
      ValueNotifier<List<CosmosOrbit>>(<CosmosOrbit>[]);
  final ValueNotifier<List<CosmosArtifact>> artifacts =
      ValueNotifier<List<CosmosArtifact>>(<CosmosArtifact>[]);

  final StreamController<List<CosmosBeacon>> _beaconController =
      StreamController<List<CosmosBeacon>>.broadcast();
  final StreamController<List<CosmosExpedition>> _expeditionController =
      StreamController<List<CosmosExpedition>>.broadcast();

  Stream<List<CosmosBeacon>> get beaconStream => _beaconController.stream;
  Stream<List<CosmosExpedition>> get expeditionStream =>
      _expeditionController.stream;

  bool _initialized = false;
  SharedPreferences? _prefs;
  final Random _random = Random();

  List<CosmosConstellation> _constellationStore =
      <CosmosConstellation>[];
  List<CosmosBeacon> _beaconStore = <CosmosBeacon>[];
  List<CosmosExpedition> _expeditionStore = <CosmosExpedition>[];
  List<CosmosArtifact> _artifactStore = <CosmosArtifact>[];
  List<CosmosOrbit> _orbitStore = <CosmosOrbit>[];

  static const String _focusKey = 'cosmos_focus';
  static const String _beaconKey = 'cosmos_beacons';
  static const String _expeditionKey = 'cosmos_expeditions';
  static const String _artifactKey = 'cosmos_artifacts';

  Future<void> init() async {
    if (_initialized) {
      _emit();
      return;
    }
    _prefs = await SharedPreferences.getInstance();
    final focusId = _prefs?.getString(_focusKey);
    final boosted = _prefs?.getStringList(_beaconKey) ?? <String>[];
    final enrolled = _prefs?.getStringList(_expeditionKey) ?? <String>[];
    final saved = _prefs?.getStringList(_artifactKey) ?? <String>[];

    _constellationStore = dummyCosmosConstellations.map((constellation) {
      final isFocus = focusId == null
          ? constellation.isFocus
          : constellation.id == focusId;
      return constellation.copyWith(isFocus: isFocus);
    }).toList();

    _beaconStore = dummyCosmosBeacons.map((beacon) {
      final isBoosted = boosted.contains(beacon.id);
      return beacon.copyWith(boosted: isBoosted);
    }).toList();

    _expeditionStore = dummyCosmosExpeditions.map((expedition) {
      final isEnrolled = enrolled.contains(expedition.id);
      return expedition.copyWith(enrolled: isEnrolled);
    }).toList();

    _artifactStore = dummyCosmosArtifacts.map((artifact) {
      final isSaved = saved.contains(artifact.id);
      return artifact.copyWith(saved: isSaved);
    }).toList();

    _orbitStore = List<CosmosOrbit>.from(dummyCosmosOrbits);

    pulse.value = defaultCosmosPulse.copyWith(
      headline: _sampleHeadline(),
      highlight: _sampleHighlight(),
      focus: _sampleFocus(),
      nextTrajectory: _sampleTrajectory(),
      magnetism: _nudge(defaultCosmosPulse.magnetism),
      signalStrength: _nudge(defaultCosmosPulse.signalStrength),
      activeAlliances: _allianceCount(),
      window: _randomWindow(defaultCosmosPulse.window),
    );

    constellations.value = List<CosmosConstellation>.from(_constellationStore);
    orbits.value = List<CosmosOrbit>.from(_orbitStore);
    artifacts.value = List<CosmosArtifact>.from(_artifactStore);
    _beaconController.add(List<CosmosBeacon>.from(_beaconStore));
    _expeditionController.add(List<CosmosExpedition>.from(_expeditionStore));
    _initialized = true;
  }

  void _emit() {
    constellations.value = List<CosmosConstellation>.from(_constellationStore);
    orbits.value = List<CosmosOrbit>.from(_orbitStore);
    artifacts.value = List<CosmosArtifact>.from(_artifactStore);
    _beaconController.add(List<CosmosBeacon>.from(_beaconStore));
    _expeditionController.add(List<CosmosExpedition>.from(_expeditionStore));
  }

  Future<void> refreshPulse() async {
    await init();
    pulse.value = pulse.value.copyWith(
      headline: _sampleHeadline(),
      highlight: _sampleHighlight(),
      focus: _sampleFocus(),
      nextTrajectory: _sampleTrajectory(),
      magnetism: _nudge(pulse.value.magnetism),
      signalStrength: _nudge(pulse.value.signalStrength),
      activeAlliances: _allianceCount(),
      window: _randomWindow(pulse.value.window),
    );

    _constellationStore = _constellationStore.map((constellation) {
      final resonance = _nudge(constellation.resonance);
      final window = _randomWindow(constellation.window);
      return constellation.copyWith(resonance: resonance, window: window);
    }).toList();
    constellations.value = List<CosmosConstellation>.from(_constellationStore);

    _orbitStore = _orbitStore.map((orbit) {
      final magnetic = _nudge(orbit.magnetic);
      final trajectory = _nudgeTrajectory(orbit.trajectory);
      final window = _randomWindow(orbit.window);
      return orbit.copyWith(
        magnetic: magnetic,
        trajectory: trajectory,
        window: window,
      );
    }).toList()
      ..shuffle(_random);
    orbits.value = List<CosmosOrbit>.from(_orbitStore);

    _beaconStore = _beaconStore.map((beacon) {
      final energy = _nudge(beacon.energy);
      final urgencyValue = (beacon.boosted ? beacon.urgency + 1 : beacon.urgency)
          .clamp(1, 5);
      return beacon.copyWith(
        energy: energy,
        urgency: urgencyValue is int ? urgencyValue : urgencyValue.toInt(),
      );
    }).toList();
    _beaconController.add(List<CosmosBeacon>.from(_beaconStore));

    _expeditionStore = _expeditionStore.map((expedition) {
      final progress = expedition.enrolled
          ? (expedition.progress + 0.08).clamp(0.0, 1.0)
          : expedition.progress;
      return expedition.copyWith(progress: progress);
    }).toList();
    _expeditionController
        .add(List<CosmosExpedition>.from(_expeditionStore));

    artifacts.value = List<CosmosArtifact>.from(_artifactStore);
  }

  Future<void> focusConstellation(String id) async {
    await init();
    _constellationStore = _constellationStore
        .map((constellation) =>
            constellation.copyWith(isFocus: constellation.id == id))
        .toList();
    constellations.value = List<CosmosConstellation>.from(_constellationStore);
    await _prefs?.setString(_focusKey, id);
  }

  Future<void> toggleBeaconBoost(String id) async {
    await init();
    final index = _beaconStore.indexWhere((beacon) => beacon.id == id);
    if (index == -1) return;
    final current = _beaconStore[index];
    final updated = current.copyWith(
      boosted: !current.boosted,
      energy: _nudge(current.energy + (current.boosted ? -0.05 : 0.07)),
    );
    _beaconStore[index] = updated;
    _beaconController.add(List<CosmosBeacon>.from(_beaconStore));
    await _prefs?.setStringList(
      _beaconKey,
      _beaconStore
          .where((beacon) => beacon.boosted)
          .map((beacon) => beacon.id)
          .toList(),
    );
  }

  Future<void> toggleExpedition(String id) async {
    await init();
    final index =
        _expeditionStore.indexWhere((expedition) => expedition.id == id);
    if (index == -1) return;
    final current = _expeditionStore[index];
    final updated = current.copyWith(
      enrolled: !current.enrolled,
      progress: current.enrolled
          ? (current.progress - 0.05).clamp(0.0, 1.0)
          : (current.progress + 0.12).clamp(0.0, 1.0),
    );
    _expeditionStore[index] = updated;
    _expeditionController
        .add(List<CosmosExpedition>.from(_expeditionStore));
    await _prefs?.setStringList(
      _expeditionKey,
      _expeditionStore
          .where((expedition) => expedition.enrolled)
          .map((expedition) => expedition.id)
          .toList(),
    );
  }

  Future<void> toggleArtifactSaved(String id) async {
    await init();
    final index =
        _artifactStore.indexWhere((artifact) => artifact.id == id);
    if (index == -1) return;
    final current = _artifactStore[index];
    final updated = current.copyWith(saved: !current.saved);
    _artifactStore[index] = updated;
    artifacts.value = List<CosmosArtifact>.from(_artifactStore);
    await _prefs?.setStringList(
      _artifactKey,
      _artifactStore
          .where((artifact) => artifact.saved)
          .map((artifact) => artifact.id)
          .toList(),
    );
  }

  double _nudge(double value) {
    final change = (_random.nextDouble() - 0.5) * 0.14;
    return (value + change).clamp(0.35, 0.95);
  }

  double _nudgeTrajectory(double value) {
    final change = (_random.nextDouble() - 0.5) * 0.18;
    return (value + change).clamp(-0.35, 0.35);
  }

  int _allianceCount() {
    final engaged =
        _constellationStore.where((c) => c.resonance >= 0.6).length;
    return max(2, min(6, engaged + 1));
  }

  String _sampleHeadline() {
    return dummyCosmosHeadlines[_random.nextInt(dummyCosmosHeadlines.length)];
  }

  String _sampleHighlight() {
    return dummyCosmosHighlights[_random.nextInt(dummyCosmosHighlights.length)];
  }

  String _sampleFocus() {
    return dummyCosmosFocuses[_random.nextInt(dummyCosmosFocuses.length)];
  }

  String _sampleTrajectory() {
    return dummyCosmosTrajectories[
        _random.nextInt(dummyCosmosTrajectories.length)];
  }

  String _randomWindow(String current) {
    const windows = <String>[
      '05:10 - 07:05',
      '11:20 - 13:45',
      '18:30 - 21:10',
      '22:15 - 00:40',
      '00:50 - 02:30',
    ];
    final filtered = windows.where((window) => window != current).toList();
    if (filtered.isEmpty) {
      return current;
    }
    return filtered[_random.nextInt(filtered.length)];
  }
}
