import 'dart:async';

import 'package:flutter/material.dart';

import '../core/utils/dummy_data.dart';
import '../core/utils/models.dart';

class RideController {
  RideController._();

  static final RideController instance = RideController._();

  final ValueNotifier<Ride?> currentRide = ValueNotifier(dummyRides.first);
  final StreamController<List<Ride>> _ridesStreamController =
      StreamController<List<Ride>>.broadcast();
  final StreamController<List<TransactionItem>> _transactionsController =
      StreamController<List<TransactionItem>>.broadcast();

  final List<Ride> _rides = List.of(dummyRides);
  final List<TransactionItem> _transactions = List.of(dummyTransactions);

  Stream<List<Ride>> get ridesStream => _ridesStreamController.stream;
  Stream<List<TransactionItem>> get transactionsStream =>
      _transactionsController.stream;

  Future<void> loadInitial() async {
    await Future.delayed(const Duration(milliseconds: 600));
    _ridesStreamController.add(_rides);
    _transactionsController.add(_transactions.take(10).toList());
  }

  Future<void> refreshRides() async {
    await Future.delayed(const Duration(milliseconds: 800));
    _rides.shuffle();
    _ridesStreamController.add(List.of(_rides));
  }

  Future<void> paginateRides() async {
    await Future.delayed(const Duration(milliseconds: 500));
    final nextIndex = _rides.length;
    _rides.addAll(List.generate(
      5,
      (index) => Ride(
        id: 'ride-${nextIndex + index}',
        pickupAddress: 'New Pickup ${(nextIndex + index) * 2}',
        destinationAddress: 'New Destination ${(nextIndex + index) * 3}',
        pickupTime: DateTime.now().subtract(Duration(hours: index + nextIndex)),
        dropTime:
            DateTime.now().subtract(Duration(hours: index + nextIndex - 1)),
        price: 20 + index * 2,
        distanceKm: 10 + index.toDouble(),
        avgTimeMinutes: 20 + index,
        status: index.isEven ? 'completed' : 'incoming',
        passengerName: 'Passenger ${nextIndex + index}',
        passengerAvatarUrl:
            'https://images.unsplash.com/photo-1524504388940-b1c1722653e1',
        carImageUrl:
            'https://images.unsplash.com/photo-1503736334956-4c8f8e92946d',
      ),
    ));
    _ridesStreamController.add(List.of(_rides));
  }

  Future<void> refreshTransactions() async {
    await Future.delayed(const Duration(milliseconds: 600));
    _transactions.shuffle();
    _transactionsController.add(_transactions.take(10).toList());
  }

  Future<void> paginateTransactions(int currentLength) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final nextLength = (currentLength + 5).clamp(0, _transactions.length);
    _transactionsController.add(_transactions.take(nextLength).toList());
  }

  List<Ride> filterRides(String query, {String? status}) {
    return _rides.where((ride) {
      final matchStatus = status == null || ride.status == status;
      final matchQuery = query.isEmpty ||
          ride.pickupAddress.toLowerCase().contains(query.toLowerCase()) ||
          ride.destinationAddress.toLowerCase().contains(query.toLowerCase()) ||
          ride.passengerName.toLowerCase().contains(query.toLowerCase());
      return matchStatus && matchQuery;
    }).toList();
  }

  void updateRideRating(String rideId, double rating) {
    final ride = _rides.firstWhere((element) => element.id == rideId);
    ride.rating = rating;
    _ridesStreamController.add(List.of(_rides));
  }

  void dispose() {
    _ridesStreamController.close();
    _transactionsController.close();
  }
}
