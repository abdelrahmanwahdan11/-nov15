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
  });

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
