import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/utils/dummy_data.dart';
import '../core/utils/insight_utils.dart';
import '../core/utils/models.dart';

class ImpactController {
  ImpactController._();

  static final ImpactController instance = ImpactController._();

  final ValueNotifier<ImpactPulse> pulse =
      ValueNotifier<ImpactPulse>(defaultImpactPulse);
  final ValueNotifier<List<ImpactGoal>> goals =
      ValueNotifier<List<ImpactGoal>>(<ImpactGoal>[]);
  final ValueNotifier<List<ImpactInitiative>> initiatives =
      ValueNotifier<List<ImpactInitiative>>(<ImpactInitiative>[]);
  final ValueNotifier<List<ImpactRipple>> ripples =
      ValueNotifier<List<ImpactRipple>>(<ImpactRipple>[]);
  final ValueNotifier<String> focusMode =
      ValueNotifier<String>(impactFocusModes.first);

  final StreamController<List<ImpactAction>> _actionController =
      StreamController<List<ImpactAction>>.broadcast();

  Stream<List<ImpactAction>> get actionsStream => _actionController.stream;
  List<ImpactAction> get currentActions =>
      List<ImpactAction>.unmodifiable(_actions);

  SharedPreferences? _prefs;
  bool _initialized = false;
  final Random _random = Random();
  List<ImpactAction> _actions = <ImpactAction>[];

  static const _focusKey = 'impact_focus_mode';
  static const _joinedKey = 'impact_joined_initiatives';
  static const _completedActionsKey = 'impact_completed_actions';
  static const _goalPrefix = 'impact_goal_';

  List<String> get focusModes =>
      List<String>.unmodifiable(impactFocusModes);

  Future<void> init() async {
    if (_initialized) {
      _emitActions();
      return;
    }
    _prefs = await SharedPreferences.getInstance();
    final storedFocus = _prefs?.getString(_focusKey);
    if (storedFocus != null && impactFocusModes.contains(storedFocus)) {
      focusMode.value = storedFocus;
    }

    final joinedIds =
        _prefs?.getStringList(_joinedKey) ?? <String>[];
    final completedIds =
        _prefs?.getStringList(_completedActionsKey) ?? <String>[];

    final loadedGoals = dummyImpactGoals.map((goal) {
      final stored = _prefs?.getDouble('$_goalPrefix${goal.id}');
      if (stored == null) {
        return goal;
      }
      final delta = stored - goal.current;
      TrendDirection direction = goal.direction;
      if (delta > 0.5) {
        direction = TrendDirection.up;
      } else if (delta < -0.5) {
        direction = TrendDirection.down;
      } else {
        direction = TrendDirection.steady;
      }
      final adjustedTrend = (goal.trend +
              (delta / (goal.target == 0 ? 1 : goal.target)))
          .clamp(-1.0, 1.0);
      return goal.copyWith(
        current: stored.clamp(0, goal.target),
        trend: adjustedTrend,
        direction: direction,
      );
    }).toList();

    final loadedInitiatives = dummyImpactInitiatives
        .map((initiative) => initiative.copyWith(
              joined: joinedIds.contains(initiative.id),
            ))
        .toList();

    _actions = dummyImpactActions
        .map((action) => action.copyWith(
              completed: completedIds.contains(action.id),
            ))
        .toList();

    goals.value = loadedGoals;
    initiatives.value = loadedInitiatives;
    ripples.value = List<ImpactRipple>.from(dummyImpactRipples);
    pulse.value = defaultImpactPulse;

    _sortActions();
    _initialized = true;
  }

  Future<void> setFocus(String mode) async {
    await init();
    if (!impactFocusModes.contains(mode)) {
      return;
    }
    focusMode.value = mode;
    await _prefs?.setString(_focusKey, mode);
    _sortActions();
  }

  Future<void> toggleInitiative(String id) async {
    await init();
    final updated = initiatives.value.map((initiative) {
      if (initiative.id == id) {
        final joined = !initiative.joined;
        final modifier = joined ? 0.04 : -0.03;
        final adjustedScore =
            (initiative.impactScore + modifier).clamp(0.1, 1.0);
        return initiative.copyWith(
          joined: joined,
          impactScore: adjustedScore,
        );
      }
      return initiative;
    }).toList();
    initiatives.value = updated;
    final joinedIds =
        updated.where((initiative) => initiative.joined).map((e) => e.id).toList();
    await _prefs?.setStringList(_joinedKey, joinedIds);
  }

  Future<void> toggleAction(String id) async {
    await init();
    _actions = _actions.map((action) {
      if (action.id == id) {
        return action.copyWith(completed: !action.completed);
      }
      return action;
    }).toList();
    await _prefs?.setStringList(
      _completedActionsKey,
      _actions.where((action) => action.completed).map((e) => e.id).toList(),
    );
    _sortActions();
  }

  Future<void> setGoalProgress(String id, double value) async {
    await init();
    final updated = List<ImpactGoal>.from(goals.value);
    for (var i = 0; i < updated.length; i++) {
      final goal = updated[i];
      if (goal.id == id) {
        final capped = value.clamp(0, goal.target);
        final delta = capped - goal.current;
        TrendDirection direction = goal.direction;
        if (delta > 0.5) {
          direction = TrendDirection.up;
        } else if (delta < -0.5) {
          direction = TrendDirection.down;
        } else {
          direction = TrendDirection.steady;
        }
        final trendDelta =
            (delta / (goal.target == 0 ? 1 : goal.target)).clamp(-1.0, 1.0);
        updated[i] = goal.copyWith(
          current: capped,
          trend: (goal.trend + trendDelta).clamp(-1.0, 1.0),
          direction: direction,
        );
        await _prefs?.setDouble('$_goalPrefix$id', capped);
        break;
      }
    }
    goals.value = updated;
  }

  Future<void> refreshPulse() async {
    await init();
    final current = pulse.value;
    final co2Delta = (_random.nextDouble() * 4) - 1.8;
    final cleanDelta = (_random.nextDouble() * 14) - 3;
    final renewableDelta = (_random.nextDouble() * 0.06) - 0.02;
    final streakUp = _random.nextBool();
    pulse.value = current.copyWith(
      co2Saved: (current.co2Saved + co2Delta).clamp(12.0, 160.0),
      cleanKm: (current.cleanKm + cleanDelta).clamp(48.0, 320.0),
      renewableShare:
          (current.renewableShare + renewableDelta).clamp(0.25, 0.95),
      streakDays: streakUp ? current.streakDays + 1 : current.streakDays,
      message: InsightUtils.nextImpactMessage(current.message),
      highlights: InsightUtils.reshuffleImpactHighlights(current.highlights),
    );
    _refreshRipplesInternal();
  }

  Future<void> refreshRipples() async {
    await init();
    _refreshRipplesInternal();
  }

  void _refreshRipplesInternal() {
    final base = ripples.value.isEmpty ? dummyImpactRipples : ripples.value;
    final updated = base.map((ripple) {
      final jitter = (_random.nextDouble() * 0.08) - 0.04;
      final newValue = (ripple.value + ripple.value * jitter).clamp(0.0, 200.0);
      final newChange = (ripple.change + jitter).clamp(-1.0, 1.0);
      TrendDirection direction = ripple.direction;
      if (newChange > 0.02) {
        direction = TrendDirection.up;
      } else if (newChange < -0.02) {
        direction = TrendDirection.down;
      } else {
        direction = TrendDirection.steady;
      }
      return ripple.copyWith(
        value: double.parse(newValue.toStringAsFixed(2)),
        change: double.parse(newChange.toStringAsFixed(2)),
        direction: direction,
      );
    }).toList();
    ripples.value = updated;
  }

  void _sortActions() {
    final selected = focusMode.value;
    _actions.sort((a, b) {
      if (a.completed != b.completed) {
        return a.completed ? 1 : -1;
      }
      final aFocus = a.tag == selected;
      final bFocus = b.tag == selected;
      if (aFocus != bFocus) {
        return aFocus ? -1 : 1;
      }
      return b.impactValue.compareTo(a.impactValue);
    });
    _emitActions();
  }

  void _emitActions() {
    _actionController.add(List<ImpactAction>.from(_actions));
  }
}
