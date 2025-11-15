import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/utils/dummy_data.dart';
import '../core/utils/models.dart';

class MasteryController {
  MasteryController._();

  static final MasteryController instance = MasteryController._();

  final ValueNotifier<MasteryPulse> pulse =
      ValueNotifier<MasteryPulse>(defaultMasteryPulse);
  final ValueNotifier<List<MasteryModule>> modules =
      ValueNotifier<List<MasteryModule>>(<MasteryModule>[]);
  final ValueNotifier<List<MasteryBadge>> badges =
      ValueNotifier<List<MasteryBadge>>(<MasteryBadge>[]);
  final ValueNotifier<List<MasteryReflection>> reflections =
      ValueNotifier<List<MasteryReflection>>(<MasteryReflection>[]);

  final StreamController<List<MasteryWorkshop>> _workshopController =
      StreamController<List<MasteryWorkshop>>.broadcast();

  Stream<List<MasteryWorkshop>> get workshopStream =>
      _workshopController.stream;

  SharedPreferences? _prefs;
  bool _initialized = false;
  final Random _random = Random();

  List<MasteryModule> _moduleStore = <MasteryModule>[];
  List<MasteryBadge> _badgeStore = <MasteryBadge>[];
  List<MasteryWorkshop> _workshopStore = <MasteryWorkshop>[];
  List<MasteryReflection> _reflectionStore = <MasteryReflection>[];

  static const String _moduleKey = 'mastery_modules';
  static const String _badgeKey = 'mastery_badges';
  static const String _reflectionKey = 'mastery_reflections';
  static const String _energyKey = 'mastery_energy';

  Future<void> init() async {
    if (_initialized) {
      _emit();
      return;
    }
    _prefs = await SharedPreferences.getInstance();

    final storedModules = _prefs?.getStringList(_moduleKey) ?? <String>[];
    final storedBadges = _prefs?.getStringList(_badgeKey) ?? <String>[];
    final storedReflections = _prefs?.getStringList(_reflectionKey) ?? <String>[];
    final storedEnergy = _prefs?.getDouble(_energyKey);

    final moduleMap = <String, List<String>>{};
    for (final entry in storedModules) {
      final parts = entry.split('|');
      if (parts.length >= 4) {
        moduleMap[parts[0]] = parts;
      }
    }

    _moduleStore = dummyMasteryModules.map((module) {
      final stored = moduleMap[module.id];
      if (stored == null) {
        return module;
      }
      final completed = int.tryParse(stored[1]) ?? module.completedLessons;
      final progress = double.tryParse(stored[2]) ?? module.progress;
      final focus = stored[3] == '1';
      return module.copyWith(
        completedLessons: completed,
        progress: progress.clamp(0.0, 1.0),
        isFocus: focus,
      );
    }).toList();

    final badgeMap = <String, List<String>>{};
    for (final entry in storedBadges) {
      final parts = entry.split('|');
      if (parts.length >= 3) {
        badgeMap[parts[0]] = parts;
      }
    }

    _badgeStore = dummyMasteryBadges.map((badge) {
      final stored = badgeMap[badge.id];
      if (stored == null) {
        return badge;
      }
      final progress = double.tryParse(stored[1]) ?? badge.progress;
      final unlocked = stored[2] == '1';
      return badge.copyWith(
        progress: progress.clamp(0.0, 1.0),
        unlocked: unlocked,
      );
    }).toList();

    _workshopStore = List<MasteryWorkshop>.from(dummyMasteryWorkshops);

    _reflectionStore = storedReflections.map((entry) {
      final parts = entry.split('|');
      if (parts.length >= 4) {
        final timestamp =
            DateTime.fromMillisecondsSinceEpoch(int.tryParse(parts[3]) ?? 0);
        return MasteryReflection(
          id: parts[0],
          prompt: parts[1],
          response: parts[2],
          timestamp: timestamp,
        );
      }
      return null;
    }).whereType<MasteryReflection>().toList();

    if (_reflectionStore.isEmpty) {
      _reflectionStore = List<MasteryReflection>.from(dummyMasteryReflections);
    }

    final energy = storedEnergy ?? defaultMasteryPulse.energy;
    pulse.value = defaultMasteryPulse.copyWith(
      momentum: _averageMomentum(),
      energy: energy.clamp(0.0, 1.0),
      pathways: List<String>.from(defaultMasteryPulse.pathways),
      coachNote: defaultMasteryPulse.coachNote,
      focusTheme: _currentFocusTitle(),
    );

    modules.value = List<MasteryModule>.from(_moduleStore);
    badges.value = List<MasteryBadge>.from(_badgeStore);
    reflections.value = List<MasteryReflection>.from(_reflectionStore);
    _workshopController.add(List<MasteryWorkshop>.from(_workshopStore));

    _recalculateBadges();
    _initialized = true;
  }

  void _emit() {
    modules.value = List<MasteryModule>.from(_moduleStore);
    badges.value = List<MasteryBadge>.from(_badgeStore);
    reflections.value = List<MasteryReflection>.from(_reflectionStore);
    _workshopController.add(List<MasteryWorkshop>.from(_workshopStore));
    pulse.value = pulse.value.copyWith(
      momentum: _averageMomentum(),
      focusTheme: _currentFocusTitle(),
    );
  }

  Future<void> markLessonComplete(String id) async {
    await init();
    final index = _moduleStore.indexWhere((module) => module.id == id);
    if (index == -1) return;
    final current = _moduleStore[index];
    final completed = (current.completedLessons + 1)
        .clamp(0, current.lessons)
        .toInt();
    final progress = (completed / current.lessons).clamp(0.0, 1.0);
    final updated = current.copyWith(
      completedLessons: completed,
      progress: progress,
    );
    _moduleStore[index] = updated;
    modules.value = List<MasteryModule>.from(_moduleStore);
    _recalculateBadges();
    await _persist();
    _updatePulseAfterProgress();
  }

  Future<void> toggleFocus(String id) async {
    await init();
    bool hasFocus = false;
    _moduleStore = _moduleStore.map((module) {
      if (module.id == id) {
        final newFocus = !module.isFocus;
        hasFocus = newFocus;
        return module.copyWith(isFocus: newFocus);
      }
      return module.copyWith(isFocus: false);
    }).toList();
    modules.value = List<MasteryModule>.from(_moduleStore);
    await _persist();
    pulse.value = pulse.value.copyWith(
      focusTheme: hasFocus ? _currentFocusTitle() : defaultMasteryPulse.focusTheme,
      pathways: hasFocus
          ? _buildPathwaysForFocus(id)
          : List<String>.from(defaultMasteryPulse.pathways),
    );
  }

  Future<void> toggleWorkshopEnrollment(String id) async {
    await init();
    final index =
        _workshopStore.indexWhere((workshop) => workshop.id == id);
    if (index == -1) return;
    final current = _workshopStore[index];
    _workshopStore[index] = current.copyWith(enrolled: !current.enrolled);
    _workshopController.add(List<MasteryWorkshop>.from(_workshopStore));
  }

  Future<void> logReflection(String message, {String? prompt}) async {
    await init();
    final trimmed = message.trim();
    if (trimmed.isEmpty) return;
    final reflection = MasteryReflection(
      id: 'reflection-${DateTime.now().millisecondsSinceEpoch}',
      prompt: prompt ?? pulse.value.focusTheme,
      response: trimmed,
      timestamp: DateTime.now(),
    );
    _reflectionStore.insert(0, reflection);
    if (_reflectionStore.length > 12) {
      _reflectionStore = _reflectionStore.sublist(0, 12);
    }
    reflections.value = List<MasteryReflection>.from(_reflectionStore);
    await _persist();
  }

  Future<void> refreshPulse() async {
    await init();
    final pathways = List<String>.from(dummyMasteryPathways)..shuffle(_random);
    final message = dummyMasteryCoachNotes[_random
            .nextInt(dummyMasteryCoachNotes.length)];
    final micro = dummyMasteryMicroPractices[_random
            .nextInt(dummyMasteryMicroPractices.length)];
    final energyDelta = (_random.nextDouble() * 0.1) - 0.05;
    final newEnergy = (pulse.value.energy + energyDelta).clamp(0.2, 0.95);
    pulse.value = pulse.value.copyWith(
      pathways: pathways.take(3).toList(),
      coachNote: message,
      microPractice: micro,
      energy: newEnergy,
      momentum: _averageMomentum(),
    );
    await _prefs?.setDouble(_energyKey, newEnergy);
  }

  double _averageMomentum() {
    if (_moduleStore.isEmpty) {
      return defaultMasteryPulse.momentum;
    }
    final total = _moduleStore.fold<double>(
      0,
      (sum, module) => sum + module.progress,
    );
    return (total / _moduleStore.length).clamp(0.0, 1.0);
  }

  String _currentFocusTitle() {
    final focusModule =
        _moduleStore.firstWhere((module) => module.isFocus, orElse: () {
      return _moduleStore.isEmpty ? dummyMasteryModules.first : _moduleStore.first;
    });
    return focusModule.title;
  }

  List<String> _buildPathwaysForFocus(String id) {
    final module =
        _moduleStore.firstWhere((element) => element.id == id, orElse: () {
      return _moduleStore.isEmpty ? dummyMasteryModules.first : _moduleStore.first;
    });
    return <String>[module.focusArea, module.microPractice, module.reflectionPrompt];
  }

  void _recalculateBadges() {
    _badgeStore = _badgeStore.map((badge) {
      final relatedProgress = badge.moduleIds.map((moduleId) {
        final module = _moduleStore.firstWhere(
          (element) => element.id == moduleId,
          orElse: () => dummyMasteryModules.first,
        );
        return module.progress;
      }).toList();
      final avg = relatedProgress.isEmpty
          ? badge.progress
          : relatedProgress.reduce((a, b) => a + b) / relatedProgress.length;
      final unlocked = avg >= badge.threshold;
      return badge.copyWith(
        progress: avg.clamp(0.0, 1.0),
        unlocked: unlocked,
      );
    }).toList();
    badges.value = List<MasteryBadge>.from(_badgeStore);
  }

  Future<void> _persist() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    final moduleEntries = _moduleStore
        .map((module) =>
            '${module.id}|${module.completedLessons}|${module.progress}|${module.isFocus ? 1 : 0}')
        .toList();
    final badgeEntries = _badgeStore
        .map((badge) =>
            '${badge.id}|${badge.progress}|${badge.unlocked ? 1 : 0}')
        .toList();
    final reflectionEntries = _reflectionStore
        .map((reflection) =>
            '${reflection.id}|${reflection.prompt}|${reflection.response}|${reflection.timestamp.millisecondsSinceEpoch}')
        .toList();
    await prefs.setStringList(_moduleKey, moduleEntries);
    await prefs.setStringList(_badgeKey, badgeEntries);
    await prefs.setStringList(_reflectionKey, reflectionEntries);
    await prefs.setDouble(_energyKey, pulse.value.energy);
  }

  void _updatePulseAfterProgress() {
    pulse.value = pulse.value.copyWith(
      momentum: _averageMomentum(),
      microPractice: dummyMasteryMicroPractices[_random
          .nextInt(dummyMasteryMicroPractices.length)],
    );
  }
}
