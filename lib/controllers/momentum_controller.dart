import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/utils/dummy_data.dart';
import '../core/utils/models.dart';

class MomentumController {
  MomentumController._();

  static final MomentumController instance = MomentumController._();

  final ValueNotifier<List<SkillTrack>> tracks =
      ValueNotifier<List<SkillTrack>>(<SkillTrack>[]);
  final ValueNotifier<SkillTrack?> focusTrack =
      ValueNotifier<SkillTrack?>(null);
  final ValueNotifier<MomentumPulse> pulse =
      ValueNotifier<MomentumPulse>(defaultMomentumPulse);
  final ValueNotifier<List<CoachSignal>> signals =
      ValueNotifier<List<CoachSignal>>(<CoachSignal>[]);

  final StreamController<List<MomentumChallenge>> _challengeController =
      StreamController<List<MomentumChallenge>>.broadcast();

  Stream<List<MomentumChallenge>> get challengeStream =>
      _challengeController.stream;
  List<MomentumChallenge> get currentChallenges =>
      List<MomentumChallenge>.unmodifiable(_challenges);

  SharedPreferences? _prefs;
  bool _initialized = false;
  final Random _random = Random();
  List<SkillTrack> _tracks = <SkillTrack>[];
  List<MomentumChallenge> _challenges = <MomentumChallenge>[];
  List<CoachSignal> _signals = <CoachSignal>[];

  static const _trackKey = 'momentum_selected_track';
  static const _milestoneKey = 'momentum_milestones';
  static const _challengeKey = 'momentum_challenges';
  static const _levelKey = 'momentum_level';
  static const _xpKey = 'momentum_xp';
  static const _thresholdKey = 'momentum_next_threshold';
  static const _streakKey = 'momentum_streak';
  static const _highlightsKey = 'momentum_highlights';
  static const _messageKey = 'momentum_message';

  static const List<String> _pulseMessages = <String>[
    'Momentum wave rising — align with your precision craft.',
    'Micro-wins stacking, keep the acceptance streak alive.',
    'Focus radar ping: Harbor Front surge crest approaching.',
    'You unlocked a new rhythm — check the community ally cues.',
  ];

  Future<void> init() async {
    if (_initialized) {
      _emit();
      return;
    }
    _prefs = await SharedPreferences.getInstance();
    final selectedTrackId = _prefs?.getString(_trackKey);
    final milestoneEntries =
        _prefs?.getStringList(_milestoneKey) ?? <String>[];
    final challengeEntries =
        _prefs?.getStringList(_challengeKey) ?? <String>[];
    final level = _prefs?.getInt(_levelKey) ?? defaultMomentumPulse.level;
    final xp = _prefs?.getInt(_xpKey) ?? defaultMomentumPulse.xp;
    final xpToNext =
        _prefs?.getInt(_thresholdKey) ?? defaultMomentumPulse.xpToNext;
    final streak = _prefs?.getInt(_streakKey) ?? defaultMomentumPulse.streakDays;
    final storedHighlights =
        _prefs?.getStringList(_highlightsKey) ?? defaultMomentumPulse.highlights;
    final storedMessage =
        _prefs?.getString(_messageKey) ?? defaultMomentumPulse.message;

    final milestoneProgress = <String, int>{};
    for (final entry in milestoneEntries) {
      final parts = entry.split('|');
      if (parts.length == 3) {
        final steps = int.tryParse(parts[2]) ?? 0;
        milestoneProgress['${parts[0]}|${parts[1]}'] = steps;
      }
    }

    final challengeProgress = <String, int>{};
    for (final entry in challengeEntries) {
      final parts = entry.split('|');
      if (parts.length == 2) {
        final progress = int.tryParse(parts[1]) ?? 0;
        challengeProgress[parts[0]] = progress;
      }
    }

    _tracks = dummySkillTracks.map((track) {
      final updatedMilestones = track.milestones.map((milestone) {
        final key = '${track.id}|${milestone.id}';
        final stored = milestoneProgress[key];
        if (stored == null) {
          return milestone;
        }
        return milestone.copyWith(completedSteps: stored);
      }).toList();
      final progress = _calculateTrackProgress(updatedMilestones);
      return track.copyWith(milestones: updatedMilestones, progress: progress);
    }).toList();

    _challenges = dummyMomentumChallenges.map((challenge) {
      final progress = challengeProgress[challenge.id];
      return progress == null
          ? challenge
          : challenge.copyWith(progress: progress);
    }).toList();

    _signals = List<CoachSignal>.from(dummyCoachSignals);
    tracks.value = List<SkillTrack>.from(_tracks);
    SkillTrack? selected;
    if (selectedTrackId != null) {
      for (final track in _tracks) {
        if (track.id == selectedTrackId) {
          selected = track;
          break;
        }
      }
    }
    selected ??= _tracks.isNotEmpty ? _tracks.first : null;
    focusTrack.value = selected;
    pulse.value = defaultMomentumPulse.copyWith(
      level: level,
      xp: xp,
      xpToNext: xpToNext,
      streakDays: streak,
      message: storedMessage,
      highlights: List<String>.from(storedHighlights),
    );
    signals.value = List<CoachSignal>.from(_signals);
    _challengeController.add(List<MomentumChallenge>.from(_challenges));
    _initialized = true;
  }

  Future<void> selectTrack(String id) async {
    await init();
    SkillTrack? selected;
    for (final track in _tracks) {
      if (track.id == id) {
        selected = track;
        break;
      }
    }
    selected ??= _tracks.isNotEmpty ? _tracks.first : null;
    focusTrack.value = selected;
    if (selected != null) {
      await _prefs?.setString(_trackKey, selected.id);
    }
  }

  Future<void> advanceMilestone(String trackId, String milestoneId) async {
    await init();
    final trackIndex = _tracks.indexWhere((track) => track.id == trackId);
    if (trackIndex == -1) return;
    final track = _tracks[trackIndex];
    final milestoneIndex =
        track.milestones.indexWhere((milestone) => milestone.id == milestoneId);
    if (milestoneIndex == -1) return;
    final milestone = track.milestones[milestoneIndex];
    if (milestone.isComplete) return;

    final updatedMilestone = milestone.copyWith(
      completedSteps: min(milestone.totalSteps, milestone.completedSteps + 1),
    );
    final updatedMilestones = List<SkillMilestone>.from(track.milestones);
    updatedMilestones[milestoneIndex] = updatedMilestone;
    final updatedTrack = track.copyWith(
      milestones: updatedMilestones,
      progress: _calculateTrackProgress(updatedMilestones),
    );
    _tracks[trackIndex] = updatedTrack;
    tracks.value = List<SkillTrack>.from(_tracks);
    if (focusTrack.value?.id == trackId) {
      focusTrack.value = updatedTrack;
    }
    await _persistMilestones();
    final xpGain = updatedMilestone.isComplete && !milestone.isComplete
        ? milestone.xpReward
        : 0;
    await _recalculatePulse(
      xpGain: xpGain,
      highlight: xpGain > 0 ? updatedTrack.highlight : null,
    );
  }

  Future<void> logChallengeProgress(String id) async {
    await init();
    final index = _challenges.indexWhere((element) => element.id == id);
    if (index == -1) return;
    final challenge = _challenges[index];
    if (challenge.isComplete) return;
    final updated = challenge.copyWith(
      progress: min(challenge.target, challenge.progress + 1),
    );
    _challenges[index] = updated;
    _challengeController.add(List<MomentumChallenge>.from(_challenges));
    await _persistChallenges();
    if (updated.isComplete) {
      await _recalculatePulse(
        xpGain: challenge.rewardXp,
        highlight: challenge.title,
      );
    }
  }

  Future<void> refreshMomentum() async {
    await init();
    _signals.shuffle(_random);
    signals.value = List<CoachSignal>.from(_signals);

    bool anyProgressed = false;
    final refreshed = _challenges.map((challenge) {
      if (challenge.isComplete) return challenge;
      if (_random.nextBool()) {
        anyProgressed = true;
        final steps = min(challenge.target, challenge.progress + 1);
        return challenge.copyWith(progress: steps);
      }
      return challenge;
    }).toList();
    _challenges = refreshed;
    _challengeController.add(List<MomentumChallenge>.from(_challenges));
    await _persistChallenges();
    await _recalculatePulse(
      bumpStreak: true,
      highlight:
          anyProgressed && _signals.isNotEmpty ? _signals.first.title : null,
    );
  }

  double _calculateTrackProgress(List<SkillMilestone> milestones) {
    if (milestones.isEmpty) {
      return 0;
    }
    final total = milestones.fold<double>(0, (value, milestone) {
      return value + milestone.progress;
    });
    return (total / milestones.length).clamp(0.0, 1.0);
  }

  Future<void> _persistMilestones() async {
    final entries = <String>[];
    for (final track in _tracks) {
      for (final milestone in track.milestones) {
        entries.add('${track.id}|${milestone.id}|${milestone.completedSteps}');
      }
    }
    await _prefs?.setStringList(_milestoneKey, entries);
  }

  Future<void> _persistChallenges() async {
    final entries = _challenges
        .map((challenge) => '${challenge.id}|${challenge.progress}')
        .toList();
    await _prefs?.setStringList(_challengeKey, entries);
  }

  Future<void> _recalculatePulse({
    int xpGain = 0,
    bool bumpStreak = false,
    String? highlight,
  }) async {
    final current = pulse.value;
    var nextXp = current.xp + xpGain;
    var level = current.level;
    var threshold = current.xpToNext;
    while (threshold > 0 && nextXp >= threshold) {
      nextXp -= threshold;
      level += 1;
      threshold = (threshold * 1.2).round();
    }
    final streak = bumpStreak ? current.streakDays + 1 : current.streakDays;
    final highlights = List<String>.from(current.highlights);
    if (highlight != null && highlight.isNotEmpty) {
      if (highlights.length >= 3) {
        highlights.removeAt(0);
      }
      highlights.add(highlight);
    }
    final message = xpGain > 0 || bumpStreak
        ? _pulseMessages[_random.nextInt(_pulseMessages.length)]
        : current.message;
    final updated = current.copyWith(
      level: level,
      xp: nextXp,
      xpToNext: threshold,
      streakDays: streak,
      highlights: highlights,
      message: message,
    );
    pulse.value = updated;
    await _prefs?.setInt(_levelKey, updated.level);
    await _prefs?.setInt(_xpKey, updated.xp);
    await _prefs?.setInt(_thresholdKey, updated.xpToNext);
    await _prefs?.setInt(_streakKey, updated.streakDays);
    await _prefs?.setStringList(_highlightsKey, updated.highlights);
    await _prefs?.setString(_messageKey, updated.message);
  }

  void _emit() {
    tracks.value = List<SkillTrack>.from(_tracks);
    signals.value = List<CoachSignal>.from(_signals);
    if (_tracks.isNotEmpty &&
        (focusTrack.value == null ||
            !_tracks.any((track) => track.id == focusTrack.value?.id))) {
      focusTrack.value = _tracks.first;
    }
    _challengeController.add(List<MomentumChallenge>.from(_challenges));
  }
}
