import 'models.dart';

final dummyUser = User(
  id: 'driver-1',
  name: 'Sofia Lane',
  avatarUrl: 'https://images.unsplash.com/photo-1544723795-3fb6469f5b39',
  phone: '+1 404 123 4567',
  rating: 4.9,
  totalTrips: 1284,
  carModel: 'Toyota Prius 2021',
  carPlate: 'DXY-8021',
);

final _cities = [
  'Midtown Loop',
  'Harbor Front',
  'Airport Express',
  'Old Town',
];

final dummyRides = List.generate(
  12,
  (index) {
    final city = _cities[index % _cities.length];
    final surge = 1.0 + (index % 4) * 0.15;
    final demandIndex = 0.55 + (index % 3) * 0.18;
    final window = index % 3 == 0
        ? '17:00 - 19:00'
        : index % 3 == 1
            ? '06:00 - 08:00'
            : '22:00 - 23:30';
    final cancellationRisk = 0.02 + (index % 4) * 0.01;
    return Ride(
      id: 'ride-$index',
      pickupAddress: '123 Sunset Blvd, City $index',
      destinationAddress: 'Downtown Plaza ${index + 2}',
      pickupTime: DateTime.now().subtract(Duration(hours: index * 3)),
      dropTime: DateTime.now().subtract(Duration(hours: (index * 3) - 1)),
      price: 18 + index * 3.5,
      distanceKm: 6.5 + index,
      avgTimeMinutes: 18 + index,
      status: index % 3 == 0
          ? 'incoming'
          : index % 3 == 1
              ? 'completed'
              : 'on_trip',
      passengerName: 'Passenger ${index + 1}',
      passengerAvatarUrl:
          'https://images.unsplash.com/photo-1524504388940-b1c1722653e1',
      carImageUrl:
          'https://images.unsplash.com/photo-1503736334956-4c8f8e92946d',
      meta: {
        'city': city,
        'surge': surge,
        'demandIndex': demandIndex,
        'hotspotWindow': window,
        'cancellationRisk': cancellationRisk,
        'earningTarget': 32 + index * 1.5,
      },
    );
  },
);

final dummyTransactions = List.generate(
  20,
  (index) => TransactionItem(
    id: 'txn-$index',
    rideId: 'ride-$index',
    dateTime: DateTime.now().subtract(Duration(days: index)),
    amount: 14.5 + index,
    location: 'City Center ${index + 1}',
  ),
);

final dummyCatalogItems = List.generate(
  10,
  (index) => CatalogItem(
    id: 'catalog-$index',
    title: 'Premium Route ${index + 1}',
    subtitle: 'High demand area with surge pricing.',
    imageUrl: 'https://images.unsplash.com/photo-1529429617124-aee64c1a05d5',
    category: index % 2 == 0 ? 'Peak' : 'Airport',
    tags: ['peak', 'bonus', if (index % 2 == 0) 'city'],
    rating: 4.0 + (index % 3) * 0.3,
    price: 12.5 + index * 2,
    distanceKm: 8 + index * 1.5,
    meta: {
      'traffic': index % 2 == 0 ? 'Medium' : 'Low',
      'time': '${15 + index} mins',
    },
  ),
);

final dummyDemandHeatCells = <DemandHeatCell>[
  DemandHeatCell(dayIndex: 1, slotKey: 'am', intensity: 0.62, potentialTrips: 6),
  DemandHeatCell(dayIndex: 1, slotKey: 'mid', intensity: 0.48, potentialTrips: 4),
  DemandHeatCell(dayIndex: 1, slotKey: 'pm', intensity: 0.8, potentialTrips: 8),
  DemandHeatCell(dayIndex: 2, slotKey: 'am', intensity: 0.74, potentialTrips: 7),
  DemandHeatCell(dayIndex: 2, slotKey: 'mid', intensity: 0.57, potentialTrips: 5),
  DemandHeatCell(dayIndex: 2, slotKey: 'pm', intensity: 0.83, potentialTrips: 9),
  DemandHeatCell(dayIndex: 3, slotKey: 'am', intensity: 0.51, potentialTrips: 4),
  DemandHeatCell(dayIndex: 3, slotKey: 'mid', intensity: 0.69, potentialTrips: 6),
  DemandHeatCell(dayIndex: 3, slotKey: 'pm', intensity: 0.9, potentialTrips: 10),
  DemandHeatCell(dayIndex: 4, slotKey: 'am', intensity: 0.58, potentialTrips: 5),
  DemandHeatCell(dayIndex: 4, slotKey: 'mid', intensity: 0.64, potentialTrips: 6),
  DemandHeatCell(dayIndex: 4, slotKey: 'pm', intensity: 0.77, potentialTrips: 8),
];

final dummyDemandPulses = <DemandPulse>[
  DemandPulse(
    area: 'Airport Express',
    window: '05:00 - 07:00',
    direction: TrendDirection.up,
    change: 0.14,
    potentialTrips: 9,
    focusMinutes: 32,
  ),
  DemandPulse(
    area: 'Midtown Loop',
    window: '11:00 - 13:00',
    direction: TrendDirection.steady,
    change: 0.04,
    potentialTrips: 6,
    focusMinutes: 26,
  ),
  DemandPulse(
    area: 'Harbor Front',
    window: '19:00 - 21:00',
    direction: TrendDirection.up,
    change: 0.18,
    potentialTrips: 10,
    focusMinutes: 34,
  ),
  DemandPulse(
    area: 'Old Town',
    window: '22:00 - 23:30',
    direction: TrendDirection.down,
    change: -0.06,
    potentialTrips: 4,
    focusMinutes: 18,
  ),
];

final dummyFocusSnapshots = <FocusAreaSnapshot>[
  FocusAreaSnapshot(
    area: 'Airport Express',
    window: '05:00 - 07:00',
    surge: 1.35,
    rideCount: 14,
    demandScore: 0.86,
  ),
  FocusAreaSnapshot(
    area: 'Midtown Loop',
    window: '07:00 - 09:00',
    surge: 1.22,
    rideCount: 11,
    demandScore: 0.78,
  ),
  FocusAreaSnapshot(
    area: 'Harbor Front',
    window: '17:00 - 19:00',
    surge: 1.41,
    rideCount: 13,
    demandScore: 0.9,
  ),
];
