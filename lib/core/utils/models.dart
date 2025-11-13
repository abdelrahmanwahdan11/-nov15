import 'package:flutter/material.dart';

class User {
  User({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.phone,
    required this.rating,
    required this.totalTrips,
    required this.carModel,
    required this.carPlate,
  });

  final String id;
  String name;
  String avatarUrl;
  String phone;
  double rating;
  int totalTrips;
  String carModel;
  String carPlate;
}

class Ride {
  Ride({
    required this.id,
    required this.pickupAddress,
    required this.destinationAddress,
    required this.pickupTime,
    required this.dropTime,
    required this.price,
    required this.distanceKm,
    required this.avgTimeMinutes,
    required this.status,
    required this.passengerName,
    required this.passengerAvatarUrl,
    required this.carImageUrl,
    this.rating,
    Map<String, dynamic>? meta,
  }) : meta = meta ?? {};

  final String id;
  final String pickupAddress;
  final String destinationAddress;
  final DateTime pickupTime;
  final DateTime dropTime;
  final double price;
  final double distanceKm;
  final int avgTimeMinutes;
  String status;
  final String passengerName;
  final String passengerAvatarUrl;
  final String carImageUrl;
  double? rating;
  final Map<String, dynamic> meta;
}

class TransactionItem {
  TransactionItem({
    required this.id,
    required this.rideId,
    required this.dateTime,
    required this.amount,
    required this.location,
  });

  final String id;
  final String rideId;
  final DateTime dateTime;
  final double amount;
  final String location;
}

class CatalogItem {
  CatalogItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.category,
    required this.tags,
    required this.rating,
    required this.price,
    required this.distanceKm,
    required this.meta,
  });

  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String category;
  final List<String> tags;
  final double rating;
  final double price;
  final double distanceKm;
  final Map<String, String> meta;
}

class ComparisonItem {
  ComparisonItem({
    required this.id,
    required this.itemAId,
    required this.itemBId,
    required this.metrics,
  });

  final String id;
  final String itemAId;
  final String itemBId;
  final Map<String, double> metrics;
}

class NotificationItem {
  NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.dateTime,
    required this.type,
  });

  final String id;
  final String title;
  final String body;
  final DateTime dateTime;
  final String type;
}

enum TrendDirection { up, down, steady }

class DemandPulse {
  DemandPulse({
    required this.area,
    required this.window,
    required this.direction,
    required this.change,
    required this.potentialTrips,
    required this.focusMinutes,
  });

  final String area;
  final String window;
  final TrendDirection direction;
  final double change;
  final int potentialTrips;
  final int focusMinutes;

  DemandPulse copyWith({
    TrendDirection? direction,
    double? change,
    int? potentialTrips,
    int? focusMinutes,
  }) {
    return DemandPulse(
      area: area,
      window: window,
      direction: direction ?? this.direction,
      change: change ?? this.change,
      potentialTrips: potentialTrips ?? this.potentialTrips,
      focusMinutes: focusMinutes ?? this.focusMinutes,
    );
  }
}

class DemandHeatCell {
  DemandHeatCell({
    required this.dayIndex,
    required this.slotKey,
    required this.intensity,
    required this.potentialTrips,
  });

  final int dayIndex;
  final String slotKey;
  final double intensity;
  final int potentialTrips;

  DemandHeatCell copyWith({
    double? intensity,
    int? potentialTrips,
  }) {
    return DemandHeatCell(
      dayIndex: dayIndex,
      slotKey: slotKey,
      intensity: intensity ?? this.intensity,
      potentialTrips: potentialTrips ?? this.potentialTrips,
    );
  }
}

class FocusAreaSnapshot {
  FocusAreaSnapshot({
    required this.area,
    required this.window,
    required this.surge,
    required this.rideCount,
    required this.demandScore,
  });

  final String area;
  final String window;
  final double surge;
  final int rideCount;
  final double demandScore;
}

class ShiftSegmentPlan {
  ShiftSegmentPlan({
    required this.id,
    required this.label,
    required this.start,
    required this.end,
    required this.demandScore,
    required this.expectedTrips,
  });

  final String id;
  final String label;
  final String start;
  final String end;
  final double demandScore;
  final int expectedTrips;

  ShiftSegmentPlan copyWith({
    double? demandScore,
    int? expectedTrips,
  }) {
    return ShiftSegmentPlan(
      id: id,
      label: label,
      start: start,
      end: end,
      demandScore: demandScore ?? this.demandScore,
      expectedTrips: expectedTrips ?? this.expectedTrips,
    );
  }
}

class MomentumAction {
  MomentumAction({
    required this.id,
    required this.title,
    required this.description,
    required this.impact,
    required this.category,
  });

  final String id;
  final String title;
  final String description;
  final String impact;
  final String category;

  MomentumAction copyWith({
    String? impact,
    String? description,
  }) {
    return MomentumAction(
      id: id,
      title: title,
      description: description ?? this.description,
      impact: impact ?? this.impact,
      category: category,
    );
  }
}

class ShiftScenario {
  ShiftScenario({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.focusArea,
    required this.earningTarget,
    required this.surgeBoost,
    required this.riskLevel,
    required this.tags,
    required this.timeline,
    required this.actions,
  });

  final String id;
  final String title;
  final String subtitle;
  final String focusArea;
  final int earningTarget;
  final double surgeBoost;
  final double riskLevel;
  final List<String> tags;
  final List<ShiftSegmentPlan> timeline;
  final List<MomentumAction> actions;

  ShiftScenario copyWith({
    List<ShiftSegmentPlan>? timeline,
    List<MomentumAction>? actions,
  }) {
    return ShiftScenario(
      id: id,
      title: title,
      subtitle: subtitle,
      focusArea: focusArea,
      earningTarget: earningTarget,
      surgeBoost: surgeBoost,
      riskLevel: riskLevel,
      tags: tags,
      timeline: timeline ?? this.timeline,
      actions: actions ?? this.actions,
    );
  }
}

class PlannerSummary {
  PlannerSummary({
    required this.projectedEarnings,
    required this.expectedTrips,
    required this.averageDemand,
    required this.confidence,
  });

  final double projectedEarnings;
  final int expectedTrips;
  final double averageDemand;
  final double confidence;
}

class MindfulRitual {
  const MindfulRitual({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.durationMinutes,
    required this.focusTag,
    required this.imageUrl,
    this.completed = false,
  });

  final String id;
  final String title;
  final String subtitle;
  final int durationMinutes;
  final String focusTag;
  final String imageUrl;
  final bool completed;

  MindfulRitual copyWith({bool? completed, String? focusTag}) {
    return MindfulRitual(
      id: id,
      title: title,
      subtitle: subtitle,
      durationMinutes: durationMinutes,
      focusTag: focusTag ?? this.focusTag,
      imageUrl: imageUrl,
      completed: completed ?? this.completed,
    );
  }
}

class BreathGuide {
  const BreathGuide({
    required this.id,
    required this.title,
    required this.inhaleSeconds,
    required this.holdSeconds,
    required this.exhaleSeconds,
    required this.cycles,
    required this.description,
    required this.focusTag,
  });

  final String id;
  final String title;
  final int inhaleSeconds;
  final int holdSeconds;
  final int exhaleSeconds;
  final int cycles;
  final String description;
  final String focusTag;
}

class RecoveryMoment {
  const RecoveryMoment({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.durationMinutes,
    required this.vibes,
    required this.icon,
  });

  final String id;
  final String title;
  final String subtitle;
  final int durationMinutes;
  final List<String> vibes;
  final String icon;
}

class WellnessSnapshot {
  const WellnessSnapshot({
    required this.alignmentScore,
    required this.energyScore,
    required this.focusScore,
    required this.message,
    required this.anchorNotes,
    required this.vibe,
  });

  final double alignmentScore;
  final double energyScore;
  final double focusScore;
  final String message;
  final List<String> anchorNotes;
  final String vibe;

  WellnessSnapshot copyWith({
    double? alignmentScore,
    double? energyScore,
    double? focusScore,
    String? message,
    List<String>? anchorNotes,
    String? vibe,
  }) {
    return WellnessSnapshot(
      alignmentScore: alignmentScore ?? this.alignmentScore,
      energyScore: energyScore ?? this.energyScore,
      focusScore: focusScore ?? this.focusScore,
      message: message ?? this.message,
      anchorNotes: anchorNotes != null
          ? List<String>.from(anchorNotes)
          : List<String>.from(this.anchorNotes),
      vibe: vibe ?? this.vibe,
    );
  }
}

class SkillMilestone {
  const SkillMilestone({
    required this.id,
    required this.title,
    required this.description,
    required this.totalSteps,
    required this.completedSteps,
    required this.xpReward,
    this.focusTag,
  });

  final String id;
  final String title;
  final String description;
  final int totalSteps;
  final int completedSteps;
  final int xpReward;
  final String? focusTag;

  bool get isComplete => completedSteps >= totalSteps;
  double get progress =>
      totalSteps == 0 ? 0 : (completedSteps / totalSteps).clamp(0.0, 1.0);

  SkillMilestone copyWith({int? completedSteps}) {
    return SkillMilestone(
      id: id,
      title: title,
      description: description,
      totalSteps: totalSteps,
      completedSteps: completedSteps ?? this.completedSteps,
      xpReward: xpReward,
      focusTag: focusTag,
    );
  }
}

class SkillTrack {
  const SkillTrack({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.focusArea,
    required this.icon,
    required this.level,
    required this.progress,
    required this.milestones,
    required this.highlight,
  });

  final String id;
  final String title;
  final String subtitle;
  final String focusArea;
  final String icon;
  final int level;
  final double progress;
  final List<SkillMilestone> milestones;
  final String highlight;

  SkillTrack copyWith({
    double? progress,
    List<SkillMilestone>? milestones,
    int? level,
    String? highlight,
  }) {
    return SkillTrack(
      id: id,
      title: title,
      subtitle: subtitle,
      focusArea: focusArea,
      icon: icon,
      level: level ?? this.level,
      progress: progress ?? this.progress,
      milestones: milestones ?? this.milestones,
      highlight: highlight ?? this.highlight,
    );
  }
}

class MomentumChallenge {
  const MomentumChallenge({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.target,
    required this.progress,
    required this.focusArea,
    required this.rewardXp,
  });

  final String id;
  final String title;
  final String subtitle;
  final IconData? icon;
  final int target;
  final int progress;
  final String focusArea;
  final int rewardXp;

  bool get isComplete => progress >= target;
  double get percent => target == 0 ? 0 : progress / target;

  MomentumChallenge copyWith({int? progress}) {
    return MomentumChallenge(
      id: id,
      title: title,
      subtitle: subtitle,
      icon: icon,
      target: target,
      progress: progress ?? this.progress,
      focusArea: focusArea,
      rewardXp: rewardXp,
    );
  }
}

class CoachSignal {
  const CoachSignal({
    required this.id,
    required this.title,
    required this.caption,
    required this.tag,
    required this.emoji,
  });

  final String id;
  final String title;
  final String caption;
  final String tag;
  final String emoji;
}

class MomentumPulse {
  const MomentumPulse({
    required this.level,
    required this.xp,
    required this.xpToNext,
    required this.streakDays,
    required this.message,
    required this.highlights,
  });

  final int level;
  final int xp;
  final int xpToNext;
  final int streakDays;
  final String message;
  final List<String> highlights;

  double get progress => xpToNext == 0 ? 0 : (xp / xpToNext).clamp(0.0, 1.0);

  MomentumPulse copyWith({
    int? level,
    int? xp,
    int? xpToNext,
    int? streakDays,
    String? message,
    List<String>? highlights,
  }) {
    return MomentumPulse(
      level: level ?? this.level,
      xp: xp ?? this.xp,
      xpToNext: xpToNext ?? this.xpToNext,
      streakDays: streakDays ?? this.streakDays,
      message: message ?? this.message,
      highlights: highlights ?? List<String>.from(this.highlights),
    );
  }
}

class CrewCircle {
  const CrewCircle({
    required this.id,
    required this.name,
    required this.tagline,
    required this.icon,
    required this.energy,
    required this.activeDrivers,
    required this.signatureMoves,
    required this.nextSync,
    required this.joined,
  });

  final String id;
  final String name;
  final String tagline;
  final String icon;
  final double energy;
  final int activeDrivers;
  final List<String> signatureMoves;
  final String nextSync;
  final bool joined;

  CrewCircle copyWith({
    double? energy,
    int? activeDrivers,
    bool? joined,
    List<String>? signatureMoves,
    String? nextSync,
  }) {
    return CrewCircle(
      id: id,
      name: name,
      tagline: tagline,
      icon: icon,
      energy: energy ?? this.energy,
      activeDrivers: activeDrivers ?? this.activeDrivers,
      signatureMoves:
          signatureMoves ?? List<String>.from(this.signatureMoves),
      nextSync: nextSync ?? this.nextSync,
      joined: joined ?? this.joined,
    );
  }
}

class CirclePulse {
  const CirclePulse({
    required this.collaborationIndex,
    required this.shareRate,
    required this.assistRate,
    required this.message,
    required this.highlights,
  });

  final double collaborationIndex;
  final double shareRate;
  final double assistRate;
  final String message;
  final List<String> highlights;

  CirclePulse copyWith({
    double? collaborationIndex,
    double? shareRate,
    double? assistRate,
    String? message,
    List<String>? highlights,
  }) {
    return CirclePulse(
      collaborationIndex: collaborationIndex ?? this.collaborationIndex,
      shareRate: shareRate ?? this.shareRate,
      assistRate: assistRate ?? this.assistRate,
      message: message ?? this.message,
      highlights: highlights ?? List<String>.from(this.highlights),
    );
  }
}

class PeerBeacon {
  const PeerBeacon({
    required this.id,
    required this.circleId,
    required this.driverName,
    required this.message,
    required this.timeAgo,
    required this.boosts,
    required this.tags,
    required this.isBoosted,
  });

  final String id;
  final String circleId;
  final String driverName;
  final String message;
  final String timeAgo;
  final int boosts;
  final List<String> tags;
  final bool isBoosted;

  PeerBeacon copyWith({
    int? boosts,
    bool? isBoosted,
    List<String>? tags,
  }) {
    return PeerBeacon(
      id: id,
      circleId: circleId,
      driverName: driverName,
      message: message,
      timeAgo: timeAgo,
      boosts: boosts ?? this.boosts,
      tags: tags ?? List<String>.from(this.tags),
      isBoosted: isBoosted ?? this.isBoosted,
    );
  }
}

class CommunitySprint {
  const CommunitySprint({
    required this.id,
    required this.circleId,
    required this.title,
    required this.timeframe,
    required this.description,
    required this.focusTags,
    required this.joined,
  });

  final String id;
  final String circleId;
  final String title;
  final String timeframe;
  final String description;
  final List<String> focusTags;
  final bool joined;

  CommunitySprint copyWith({bool? joined}) {
    return CommunitySprint(
      id: id,
      circleId: circleId,
      title: title,
      timeframe: timeframe,
      description: description,
      focusTags: List<String>.from(focusTags),
      joined: joined ?? this.joined,
    );
  }
}

class CommunityResource {
  const CommunityResource({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.format,
    required this.duration,
    required this.vibe,
    required this.isSaved,
  });

  final String id;
  final String title;
  final String subtitle;
  final String format;
  final String duration;
  final String vibe;
  final bool isSaved;

  CommunityResource copyWith({bool? isSaved}) {
    return CommunityResource(
      id: id,
      title: title,
      subtitle: subtitle,
      format: format,
      duration: duration,
      vibe: vibe,
      isSaved: isSaved ?? this.isSaved,
    );
  }
}
