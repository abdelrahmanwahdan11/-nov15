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
