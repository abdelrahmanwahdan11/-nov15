import 'package:flutter/material.dart';

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

final defaultMomentumPulse = MomentumPulse(
  level: 4,
  xp: 620,
  xpToNext: 900,
  streakDays: 6,
  message: 'Momentum is surging heading into evening commutes.',
  highlights: [
    'Precision craft +18%',
    'Acceptance streak ×6',
    'Focus: Airport express',
  ],
);

final dummySkillTracks = <SkillTrack>[
  SkillTrack(
    id: 'precision-craft',
    title: 'Precision craft',
    subtitle: 'Sharpen pickups and arrivals for consistent five-star flow.',
    focusArea: 'quality',
    icon: '🎯',
    level: 2,
    progress: 0.58,
    highlight: '3 flawless pickups streak',
    milestones: [
      SkillMilestone(
        id: 'precision-arrival',
        title: 'Pinpoint arrivals',
        description: 'Arrive within 2 minutes of ETA on 6 rides.',
        totalSteps: 6,
        completedSteps: 3,
        xpReward: 120,
        focusTag: 'focus',
      ),
      SkillMilestone(
        id: 'precision-pickup',
        title: 'Landing zone clarity',
        description: 'Share precise pickup cues with 4 passengers.',
        totalSteps: 4,
        completedSteps: 2,
        xpReward: 90,
        focusTag: 'calm',
      ),
      SkillMilestone(
        id: 'precision-map',
        title: 'Route clarity notes',
        description: 'Log map notes for 3 tricky blocks.',
        totalSteps: 3,
        completedSteps: 1,
        xpReward: 75,
        focusTag: 'focus',
      ),
    ],
  ),
  SkillTrack(
    id: 'demand-wave',
    title: 'Demand wave',
    subtitle: 'Orchestrate demand spikes with nimble repositioning.',
    focusArea: 'growth',
    icon: '🌊',
    level: 3,
    progress: 0.66,
    highlight: 'Surge surfer badge unlocked',
    milestones: [
      SkillMilestone(
        id: 'wave-cadence',
        title: 'Cadence mapping',
        description: 'Capture 5 micro-notes after each surge pivot.',
        totalSteps: 5,
        completedSteps: 4,
        xpReward: 140,
        focusTag: 'energize',
      ),
      SkillMilestone(
        id: 'wave-airport',
        title: 'Airport sprint',
        description: 'Stack 3 efficient airport round-trips.',
        totalSteps: 3,
        completedSteps: 1,
        xpReward: 110,
        focusTag: 'focus',
      ),
      SkillMilestone(
        id: 'wave-night',
        title: 'Night shift sync',
        description: 'Keep energy above 70% through 2 night shifts.',
        totalSteps: 2,
        completedSteps: 1,
        xpReward: 100,
        focusTag: 'energize',
      ),
    ],
  ),
  SkillTrack(
    id: 'community-ally',
    title: 'Community ally',
    subtitle: 'Grow rider loyalty with micro moments and kindness cues.',
    focusArea: 'loyalty',
    icon: '🤝',
    level: 1,
    progress: 0.42,
    highlight: 'Two gratitude mentions today',
    milestones: [
      SkillMilestone(
        id: 'ally-feedback',
        title: 'Feedback loops',
        description: 'Collect 4 rider preferences inside the app.',
        totalSteps: 4,
        completedSteps: 1,
        xpReward: 70,
        focusTag: 'calm',
      ),
      SkillMilestone(
        id: 'ally-gesture',
        title: 'Micro gestures',
        description: 'Log 6 micro appreciation gestures.',
        totalSteps: 6,
        completedSteps: 2,
        xpReward: 95,
        focusTag: 'energize',
      ),
      SkillMilestone(
        id: 'ally-recovery',
        title: 'Ride recovery',
        description: 'Turn 3 delayed starts into 5★ closes.',
        totalSteps: 3,
        completedSteps: 0,
        xpReward: 130,
        focusTag: 'focus',
      ),
    ],
  ),
];

final dummyMomentumChallenges = <MomentumChallenge>[
  MomentumChallenge(
    id: 'challenge_acceptance',
    title: 'Acceptance streak',
    subtitle: 'Maintain a 95% acceptance rate through tonight.',
    icon: Icons.bolt,
    target: 8,
    progress: 5,
    focusArea: 'growth',
    rewardXp: 160,
  ),
  MomentumChallenge(
    id: 'challenge_rating',
    title: 'Rating glow',
    subtitle: 'Secure three 5★ feedback moments before midnight.',
    icon: Icons.stars,
    target: 3,
    progress: 1,
    focusArea: 'quality',
    rewardXp: 130,
  ),
  MomentumChallenge(
    id: 'challenge_energy',
    title: 'Energy balance',
    subtitle: 'Hold energy above 70% through three segments.',
    icon: Icons.local_fire_department,
    target: 3,
    progress: 2,
    focusArea: 'wellness',
    rewardXp: 115,
  ),
];

final dummyCoachSignals = <CoachSignal>[
  const CoachSignal(
    id: 'signal_lanewave',
    title: 'Lane wave tipping point',
    caption: 'Midtown loop heat is cresting — catch the 18:40 crest.',
    tag: 'growth',
    emoji: '📈',
  ),
  const CoachSignal(
    id: 'signal_calm',
    title: 'Calm cadence ready',
    caption: 'Breath deck “wave cadence” syncs with your next run.',
    tag: 'wellness',
    emoji: '🌬️',
  ),
  const CoachSignal(
    id: 'signal_loyal',
    title: 'Loyalty sparks',
    caption: 'Two riders mentioned shout-outs — send gratitude notes.',
    tag: 'loyalty',
    emoji: '💌',
  ),
];

final defaultWellnessSnapshot = WellnessSnapshot(
  alignmentScore: 0.62,
  energyScore: 0.58,
  focusScore: 0.66,
  message: 'Centered and ready for adaptive driving.',
  anchorNotes: [
    'Prime window: 17:00 micro reset',
    'Hydration reminder logged',
    '3 ride streak poised',
  ],
  vibe: 'calm',
);

final dummyMindfulRituals = <MindfulRitual>[
  MindfulRitual(
    id: 'ritual_sunrise',
    title: 'Sunrise alignment',
    subtitle: 'Lengthen spine and reset shoulders before accepting rides.',
    durationMinutes: 3,
    focusTag: 'calm',
    imageUrl:
        'https://images.unsplash.com/photo-1506126613408-eca07ce68773?auto=format&fit=crop&w=900&q=80',
  ),
  MindfulRitual(
    id: 'ritual_breath',
    title: 'Grounding breath',
    subtitle: 'Sync breath with next shift segment to ease transitions.',
    durationMinutes: 2,
    focusTag: 'calm',
    imageUrl:
        'https://images.unsplash.com/photo-1526402469535-74b31b414c5b?auto=format&fit=crop&w=900&q=80',
  ),
  MindfulRitual(
    id: 'ritual_focus',
    title: 'Focus ignition',
    subtitle: 'Prime reaction time with gentle visual sprints.',
    durationMinutes: 4,
    focusTag: 'focus',
    imageUrl:
        'https://images.unsplash.com/photo-1521737604893-d14cc237f11d?auto=format&fit=crop&w=900&q=80',
  ),
  MindfulRitual(
    id: 'ritual_energy',
    title: 'Energy loop',
    subtitle: 'Activate posture and breath for festival rush hours.',
    durationMinutes: 5,
    focusTag: 'energize',
    imageUrl:
        'https://images.unsplash.com/photo-1517832207067-4db24a2ae47c?auto=format&fit=crop&w=900&q=80',
  ),
  MindfulRitual(
    id: 'ritual_night',
    title: 'Twilight unwind',
    subtitle: 'Release night tension and close the shift with clarity.',
    durationMinutes: 3,
    focusTag: 'calm',
    imageUrl:
        'https://images.unsplash.com/photo-1527515637462-cff94eecc1ac?auto=format&fit=crop&w=900&q=80',
  ),
];

final dummyBreathGuides = <BreathGuide>[
  BreathGuide(
    id: 'breath_box',
    title: 'Box balance',
    inhaleSeconds: 4,
    holdSeconds: 4,
    exhaleSeconds: 4,
    cycles: 5,
    description: 'Stabilize heart rate before surge windows.',
    focusTag: 'calm',
  ),
  BreathGuide(
    id: 'breath_peak',
    title: 'Peak priming',
    inhaleSeconds: 3,
    holdSeconds: 1,
    exhaleSeconds: 3,
    cycles: 8,
    description: 'Quick focus burst when approaching airport queue.',
    focusTag: 'focus',
  ),
  BreathGuide(
    id: 'breath_wave',
    title: 'Wave cadence',
    inhaleSeconds: 5,
    holdSeconds: 2,
    exhaleSeconds: 6,
    cycles: 6,
    description: 'Longer waves for late night calm and clarity.',
    focusTag: 'calm',
  ),
  BreathGuide(
    id: 'breath_power',
    title: 'Power lift',
    inhaleSeconds: 2,
    holdSeconds: 0,
    exhaleSeconds: 4,
    cycles: 10,
    description: 'Supercharge reaction time before festival exits.',
    focusTag: 'energize',
  ),
  BreathGuide(
    id: 'breath_flow',
    title: 'Flow sync',
    inhaleSeconds: 4,
    holdSeconds: 2,
    exhaleSeconds: 5,
    cycles: 7,
    description: 'Align micro-breaks with planner focus blocks.',
    focusTag: 'focus',
  ),
];

final dummyRecoveryMoments = <RecoveryMoment>[
  RecoveryMoment(
    id: 'moment_light',
    title: 'Window light reset',
    subtitle: 'Face natural light, roll shoulders, reset breathing.',
    durationMinutes: 2,
    vibes: ['calm', 'focus'],
    icon: '🌤️',
  ),
  RecoveryMoment(
    id: 'moment_stretch',
    title: 'Seat stretch loop',
    subtitle: 'Lower-back twists and ankle circles between pickups.',
    durationMinutes: 3,
    vibes: ['focus', 'energize'],
    icon: '🧘',
  ),
  RecoveryMoment(
    id: 'moment_walk',
    title: 'Micro walk pulse',
    subtitle: 'Two-minute walk around the vehicle for circulation.',
    durationMinutes: 2,
    vibes: ['energize'],
    icon: '🚶',
  ),
  RecoveryMoment(
    id: 'moment_audio',
    title: 'Audio shift check',
    subtitle: 'Play focus playlist curated for the upcoming route.',
    durationMinutes: 1,
    vibes: ['focus'],
    icon: '🎧',
  ),
  RecoveryMoment(
    id: 'moment_breathe',
    title: 'Calm hold',
    subtitle: 'Close eyes, inhale steadily, and soften jaw tension.',
    durationMinutes: 2,
    vibes: ['calm'],
    icon: '🌬️',
  ),
];

