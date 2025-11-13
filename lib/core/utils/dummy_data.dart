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

final dummyShiftScenarios = <ShiftScenario>[
  ShiftScenario(
    id: 'scenario_airport',
    title: 'Sunrise Airport Surge',
    subtitle: 'Stack back-to-back early airport runs before rush hour.',
    focusArea: 'Airport Express',
    earningTarget: 240,
    surgeBoost: 1.32,
    riskLevel: 0.22,
    tags: ['early'],
    timeline: [
      ShiftSegmentPlan(
        id: 'seg1',
        label: 'Warm-up loop',
        start: '04:30',
        end: '05:30',
        demandScore: 0.62,
        expectedTrips: 3,
      ),
      ShiftSegmentPlan(
        id: 'seg2',
        label: 'Airport surge',
        start: '05:30',
        end: '07:15',
        demandScore: 0.88,
        expectedTrips: 5,
      ),
      ShiftSegmentPlan(
        id: 'seg3',
        label: 'City return',
        start: '07:15',
        end: '08:30',
        demandScore: 0.74,
        expectedTrips: 3,
      ),
    ],
    actions: [
      MomentumAction(
        id: 'action1',
        title: 'Pre-stage near terminals',
        description: 'Arrive 20 minutes early to secure priority queue placement.',
        impact: '+12%',
        category: 'positioning',
      ),
      MomentumAction(
        id: 'action2',
        title: 'Stack corporate pickups',
        description: 'Accept consecutive rides heading to downtown hotels.',
        impact: '+3 trips',
        category: 'sequence',
      ),
    ],
  ),
  ShiftScenario(
    id: 'scenario_midtown',
    title: 'Lunchtime Midtown Flow',
    subtitle: 'Rotate through office clusters during peak lunch blocks.',
    focusArea: 'Midtown Loop',
    earningTarget: 210,
    surgeBoost: 1.18,
    riskLevel: 0.16,
    tags: ['midday'],
    timeline: [
      ShiftSegmentPlan(
        id: 'seg4',
        label: 'Office arrivals',
        start: '10:45',
        end: '11:30',
        demandScore: 0.58,
        expectedTrips: 2,
      ),
      ShiftSegmentPlan(
        id: 'seg5',
        label: 'Lunch circuit',
        start: '11:30',
        end: '13:15',
        demandScore: 0.82,
        expectedTrips: 5,
      ),
      ShiftSegmentPlan(
        id: 'seg6',
        label: 'Return boosts',
        start: '13:15',
        end: '14:00',
        demandScore: 0.67,
        expectedTrips: 3,
      ),
    ],
    actions: [
      MomentumAction(
        id: 'action3',
        title: 'Partner lunch drops',
        description: 'Prioritize rides ending near food courts with high return demand.',
        impact: '+9%',
        category: 'timing',
      ),
      MomentumAction(
        id: 'action4',
        title: 'Micro-break pulse',
        description: 'Take a 5-minute break after the third ride to reset positioning.',
        impact: 'Stability',
        category: 'wellness',
      ),
    ],
  ),
  ShiftScenario(
    id: 'scenario_night',
    title: 'Twilight Festival Run',
    subtitle: 'Capture event exits and late-night bonuses responsibly.',
    focusArea: 'Harbor Front',
    earningTarget: 265,
    surgeBoost: 1.41,
    riskLevel: 0.28,
    tags: ['evening'],
    timeline: [
      ShiftSegmentPlan(
        id: 'seg7',
        label: 'Sound-check arrivals',
        start: '17:30',
        end: '18:30',
        demandScore: 0.66,
        expectedTrips: 3,
      ),
      ShiftSegmentPlan(
        id: 'seg8',
        label: 'Festival exit wave',
        start: '18:30',
        end: '20:45',
        demandScore: 0.91,
        expectedTrips: 6,
      ),
      ShiftSegmentPlan(
        id: 'seg9',
        label: 'Late-night cooldown',
        start: '20:45',
        end: '22:00',
        demandScore: 0.72,
        expectedTrips: 4,
      ),
    ],
    actions: [
      MomentumAction(
        id: 'action5',
        title: 'Event lane clearance',
        description: 'Coordinate arrival via service lane to skip festival roadblocks.',
        impact: '+15%',
        category: 'access',
      ),
      MomentumAction(
        id: 'action6',
        title: 'Night safety sweep',
        description: 'Toggle safety checklist between rides to maintain top rating.',
        impact: 'Rating +0.1',
        category: 'quality',
      ),
    ],
  ),
];
