import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/utils/dummy_data.dart';
import '../core/utils/models.dart';

class ZenithController {
  ZenithController._();

  static final ZenithController instance = ZenithController._();

  final ValueNotifier<ZenithPulse> pulse =
      ValueNotifier<ZenithPulse>(defaultZenithPulse);
  final ValueNotifier<List<ZenithVector>> vectors =
      ValueNotifier<List<ZenithVector>>(List<ZenithVector>.from(dummyZenithVectors));
  final ValueNotifier<List<ZenithPath>> paths =
      ValueNotifier<List<ZenithPath>>(List<ZenithPath>.from(dummyZenithPaths));
  final ValueNotifier<ZenithVector?> focusVector =
      ValueNotifier<ZenithVector?>(dummyZenithVectors.first);
  final ValueNotifier<String> focusMode =
      ValueNotifier<String>(zenithModes.first);

  final StreamController<List<ZenithSignal>> _signalController =
      StreamController<List<ZenithSignal>>.broadcast();

  Stream<List<ZenithSignal>> get signalsStream => _signalController.stream;

  bool _initialized = false;
  SharedPreferences? _prefs;
  final Random _random = Random();
  List<ZenithSignal> _signals = List<ZenithSignal>.from(dummyZenithSignals);

  static const String _modeKey = 'zenith_mode';
  static const String _focusVectorKey = 'zenith_focus_vector';
  static const String _activePathsKey = 'zenith_active_paths';
  static const String _ackSignalsKey = 'zenith_ack_signals';

  Future<void> init() async {
    if (_initialized) {
      _emitSignals();
      return;
    }
    _prefs = await SharedPreferences.getInstance();

    final storedMode = _prefs?.getString(_modeKey);
    if (storedMode != null && zenithModes.contains(storedMode)) {
      focusMode.value = storedMode;
    }

    final storedVectorId = _prefs?.getString(_focusVectorKey);
    if (storedVectorId != null) {
      final found = dummyZenithVectors.firstWhere(
        (vector) => vector.id == storedVectorId,
        orElse: () => dummyZenithVectors.first,
      );
      focusVector.value = found;
    } else {
      focusVector.value = dummyZenithVectors.first;
    }

    final activePathIds = _prefs?.getStringList(_activePathsKey) ?? <String>[];
    final updatedPaths = dummyZenithPaths
        .map((path) => path.copyWith(active: activePathIds.contains(path.id)))
        .toList();
    paths.value = updatedPaths;

    final acknowledgedIds = _prefs?.getStringList(_ackSignalsKey) ?? <String>[];
    _signals = dummyZenithSignals
        .map((signal) =>
            signal.copyWith(acknowledged: acknowledgedIds.contains(signal.id)))
        .toList();

    vectors.value = List<ZenithVector>.from(dummyZenithVectors);
    pulse.value = defaultZenithPulse;

    _emitSignals();
    _initialized = true;
  }

  Future<void> setMode(String mode) async {
    await init();
    if (!zenithModes.contains(mode)) {
      return;
    }
    focusMode.value = mode;
    await _prefs?.setString(_modeKey, mode);
    _rebalanceVectors();
  }

  Future<void> setFocusVector(String id) async {
    await init();
    final updatedVectors = vectors.value.map((vector) {
      final isFocus = vector.id == id;
      return vector.copyWith(isFocus: isFocus);
    }).toList();
    vectors.value = updatedVectors;
    focusVector.value =
        updatedVectors.firstWhere((vector) => vector.id == id, orElse: () => updatedVectors.first);
    await _prefs?.setString(_focusVectorKey, id);
  }

  Future<void> togglePath(String id) async {
    await init();
    final updated = paths.value.map((path) {
      if (path.id == id) {
        final toggled = !path.active;
        final newProgress = toggled
            ? (path.progress + _random.nextDouble() * 0.2).clamp(0.0, 1.0)
            : path.progress;
        return path.copyWith(active: toggled, progress: newProgress);
      }
      return path;
    }).toList();
    paths.value = updated;
    final activeIds =
        updated.where((path) => path.active).map((path) => path.id).toList();
    await _prefs?.setStringList(_activePathsKey, activeIds);
  }

  Future<void> acknowledgeSignal(String id) async {
    await init();
    _signals = _signals.map((signal) {
      if (signal.id == id) {
        return signal.copyWith(acknowledged: true);
      }
      return signal;
    }).toList();
    _emitSignals();
    await _prefs?.setStringList(
      _ackSignalsKey,
      _signals.where((signal) => signal.acknowledged).map((signal) => signal.id).toList(),
    );
  }

  Future<void> refreshPulse() async {
    await init();
    final current = pulse.value;
    final clarity = (current.clarity + (_random.nextDouble() * 0.2 - 0.1)).clamp(0.2, 1.0);
    final acceleration =
        (current.acceleration + (_random.nextDouble() * 0.2 - 0.05)).clamp(0.1, 1.0);
    final altitude = (current.altitude + (_random.nextDouble() * 0.15 - 0.05)).clamp(0.1, 1.2);
    final momentum = (current.momentum + (_random.nextDouble() * 0.15 - 0.05)).clamp(0.1, 1.0);
    pulse.value = current.copyWith(
      clarity: clarity,
      acceleration: acceleration,
      altitude: altitude,
      momentum: momentum,
      window: zenithWindows[_random.nextInt(zenithWindows.length)],
      headline: zenithPulseHeadlines[_random.nextInt(zenithPulseHeadlines.length)],
    );
    _rebalanceVectors();
    _refreshSignals();
  }

  void _rebalanceVectors() {
    final mode = focusMode.value;
    final multiplier = mode == zenithModes.first
        ? 0.08
        : mode == zenithModes[1]
            ? 0.05
            : 0.03;
    final updated = vectors.value.map((vector) {
      final adjust = (vector.isFocus ? multiplier * 1.2 : multiplier) *
          (_random.nextDouble() * 2 - 1);
      final progress = (vector.momentum + adjust).clamp(0.05, 1.0);
      return vector.copyWith(momentum: progress);
    }).toList();
    vectors.value = updated;
  }

  void _refreshSignals() {
    final inactiveSignals = _signals.where((signal) => signal.acknowledged).toList();
    if (inactiveSignals.length == _signals.length) {
      final regenerated = dummyZenithSignals
          .map((signal) => signal.copyWith(acknowledged: false))
          .toList();
      _signals = regenerated;
    } else {
      _signals = _signals.map((signal) {
        if (signal.acknowledged && _random.nextBool()) {
          return signal.copyWith(
            acknowledged: false,
            detail: signal.detail,
          );
        }
        return signal;
      }).toList();
    }
    _emitSignals();
  }

  void _emitSignals() {
    if (!_signalController.isClosed) {
      _signalController.add(List<ZenithSignal>.from(_signals));
    }
  }
}
