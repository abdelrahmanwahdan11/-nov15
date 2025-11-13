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

final dummyRides = List.generate(
  12,
  (index) => Ride(
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
    passengerAvatarUrl: 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1',
    carImageUrl: 'https://images.unsplash.com/photo-1503736334956-4c8f8e92946d',
  ),
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
