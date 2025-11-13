import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/utils/dummy_data.dart';
import '../core/utils/insight_utils.dart';
import '../core/utils/models.dart';

class CommunityController {
  CommunityController._();

  static final CommunityController instance = CommunityController._();

  final ValueNotifier<List<CrewCircle>> circles =
      ValueNotifier<List<CrewCircle>>(<CrewCircle>[]);
  final ValueNotifier<CrewCircle?> activeCircle =
      ValueNotifier<CrewCircle?>(null);
  final ValueNotifier<CirclePulse> pulse =
      ValueNotifier<CirclePulse>(defaultCirclePulse);
  final ValueNotifier<List<CommunityResource>> resources =
      ValueNotifier<List<CommunityResource>>(<CommunityResource>[]);

  final StreamController<List<PeerBeacon>> _beaconController =
      StreamController<List<PeerBeacon>>.broadcast();
  final StreamController<List<CommunitySprint>> _sprintController =
      StreamController<List<CommunitySprint>>.broadcast();

  Stream<List<PeerBeacon>> get beaconStream => _beaconController.stream;
  Stream<List<CommunitySprint>> get sprintStream => _sprintController.stream;

  SharedPreferences? _prefs;
  bool _initialized = false;
  final Random _random = Random();
  List<CrewCircle> _circles = <CrewCircle>[];
  List<PeerBeacon> _beacons = <PeerBeacon>[];
  List<CommunitySprint> _sprints = <CommunitySprint>[];
  List<CommunityResource> _resources = <CommunityResource>[];

  static const _circleKey = 'community_selected_circle';
  static const _savedResourcesKey = 'community_saved_resources';
  static const _joinedSprintsKey = 'community_joined_sprints';
  static const _boostedBeaconsKey = 'community_boosted_beacons';

  Future<void> init() async {
    if (_initialized) {
      _emit();
      return;
    }
    _prefs = await SharedPreferences.getInstance();
    final selectedCircleId = _prefs?.getString(_circleKey);
    final savedResourceIds =
        _prefs?.getStringList(_savedResourcesKey) ?? <String>[];
    final joinedSprintIds =
        _prefs?.getStringList(_joinedSprintsKey) ?? <String>[];
    final boostedBeaconIds =
        _prefs?.getStringList(_boostedBeaconsKey) ?? <String>[];

    _circles = dummyCrewCircles
        .map((circle) => circle.copyWith(joined: circle.id == selectedCircleId))
        .toList();
    _beacons = dummyPeerBeacons
        .map((beacon) => beacon.copyWith(
              isBoosted: boostedBeaconIds.contains(beacon.id),
            ))
        .toList();
    _sprints = dummyCommunitySprints
        .map((sprint) => sprint.copyWith(
              joined: joinedSprintIds.contains(sprint.id),
            ))
        .toList();
    _resources = dummyCommunityResources
        .map((resource) => resource.copyWith(
              isSaved: savedResourceIds.contains(resource.id),
            ))
        .toList();

    circles.value = List<CrewCircle>.from(_circles);
    resources.value = List<CommunityResource>.from(_resources);
    activeCircle.value = _circles.firstWhere(
      (circle) => circle.id == selectedCircleId,
      orElse: () => _circles.isNotEmpty ? _circles.first : null,
    );
    final active = activeCircle.value;
    if (active != null && !active.joined) {
      _circles = _circles
          .map((circle) =>
              circle.id == active.id ? circle.copyWith(joined: true) : circle)
          .toList();
      circles.value = List<CrewCircle>.from(_circles);
      await _prefs?.setString(_circleKey, active.id);
    }
    pulse.value = defaultCirclePulse;
    _emit();
    _initialized = true;
  }

  Future<void> selectCircle(String id) async {
    await init();
    _circles = _circles
        .map((circle) => circle.copyWith(joined: circle.id == id))
        .toList();
    circles.value = List<CrewCircle>.from(_circles);
    activeCircle.value =
        _circles.firstWhere((circle) => circle.id == id, orElse: () => null);
    await _prefs?.setString(_circleKey, id);
    _emit();
  }

  Future<void> toggleSprint(String id) async {
    await init();
    _sprints = _sprints.map((sprint) {
      if (sprint.id == id) {
        return sprint.copyWith(joined: !sprint.joined);
      }
      return sprint;
    }).toList();
    await _persistSprints();
  }

  Future<void> toggleResourceSave(String id) async {
    await init();
    _resources = _resources.map((resource) {
      if (resource.id == id) {
        return resource.copyWith(isSaved: !resource.isSaved);
      }
      return resource;
    }).toList();
    resources.value = List<CommunityResource>.from(_resources);
    final savedIds =
        _resources.where((resource) => resource.isSaved).map((e) => e.id).toList();
    await _prefs?.setStringList(_savedResourcesKey, savedIds);
  }

  Future<void> boostBeacon(String id) async {
    await init();
    _beacons = _beacons.map((beacon) {
      if (beacon.id == id) {
        final boosted = !beacon.isBoosted;
        final delta = boosted ? 1 : -1;
        return beacon.copyWith(
          isBoosted: boosted,
          boosts: max(0, beacon.boosts + delta),
        );
      }
      return beacon;
    }).toList();
    await _persistBoosts();
  }

  Future<void> refreshPulse() async {
    await init();
    final current = pulse.value;
    final modifier = (_random.nextDouble() * 0.08) - 0.04;
    pulse.value = current.copyWith(
      collaborationIndex: (current.collaborationIndex + modifier).clamp(0.0, 1.0),
      shareRate: (current.shareRate + (_random.nextDouble() * 0.06) - 0.03)
          .clamp(0.0, 1.0),
      assistRate: (current.assistRate + (_random.nextDouble() * 0.06) - 0.03)
          .clamp(0.0, 1.0),
      highlights: InsightUtils.shuffleHighlights(current.highlights),
      message: InsightUtils.nextCommunityMessage(current.message),
    );
  }

  void _emit() {
    _beaconController.add(List<PeerBeacon>.from(_beacons));
    _sprintController.add(List<CommunitySprint>.from(_sprints));
  }

  Future<void> _persistSprints() async {
    final joined = _sprints.where((sprint) => sprint.joined).map((e) => e.id).toList();
    await _prefs?.setStringList(_joinedSprintsKey, joined);
    _emit();
  }

  Future<void> _persistBoosts() async {
    final boosted =
        _beacons.where((beacon) => beacon.isBoosted).map((e) => e.id).toList();
    await _prefs?.setStringList(_boostedBeaconsKey, boosted);
    _emit();
  }
}
