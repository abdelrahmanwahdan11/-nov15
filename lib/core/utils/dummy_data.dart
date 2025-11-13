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

const defaultCirclePulse = CirclePulse(
  collaborationIndex: 0.74,
  shareRate: 0.62,
  assistRate: 0.58,
  message: 'Crew sync window aligning — share your best quick wins.',
  highlights: <String>[
    '3 quick handoffs converted in Harbor circle',
    'Shared playlist boosted late-night vibe',
    'North ridge team swapped surge intel',
    'Two new driver buddies joined your lane',
  ],
);

final dummyCrewCircles = <CrewCircle>[
  CrewCircle(
    id: 'circle_harbor',
    name: 'Harbor wave',
    tagline: 'Sunset airport mastery.',
    icon: '🌊',
    energy: 0.82,
    activeDrivers: 38,
    signatureMoves: <String>['Airport relay', 'Runway greet', 'Harbor calm'],
    nextSync: '18:30 crew focus',
    joined: false,
  ),
  CrewCircle(
    id: 'circle_city',
    name: 'City pulse',
    tagline: 'Downtown lunch rush tacticians.',
    icon: '🏙️',
    energy: 0.68,
    activeDrivers: 52,
    signatureMoves: <String>['Micro-loop', 'Lunch express', 'Signal swap'],
    nextSync: '12:15 mic-drop',
    joined: false,
  ),
  CrewCircle(
    id: 'circle_night',
    name: 'Night aurora',
    tagline: 'Late-night vibe keepers.',
    icon: '🌌',
    energy: 0.9,
    activeDrivers: 24,
    signatureMoves: <String>['Glow trail', 'Silent arrival', 'Rewind playlist'],
    nextSync: '22:00 glow brief',
    joined: false,
  ),
];

final dummyPeerBeacons = <PeerBeacon>[
  PeerBeacon(
    id: 'beacon_airport',
    circleId: 'circle_harbor',
    driverName: 'Layla M.',
    message: 'Shifted pickups to level 3 and cut wait time by 6 min.',
    timeAgo: '7 min ago',
    boosts: 14,
    tags: <String>['wait time', 'airport'],
    isBoosted: false,
  ),
  PeerBeacon(
    id: 'beacon_city',
    circleId: 'circle_city',
    driverName: 'Rashid Q.',
    message: 'Bundle lunch stops along metro line — riders tipping high.',
    timeAgo: '22 min ago',
    boosts: 19,
    tags: <String>['tips', 'bundles'],
    isBoosted: false,
  ),
  PeerBeacon(
    id: 'beacon_night',
    circleId: 'circle_night',
    driverName: 'Nora L.',
    message: 'Glow playlist update dropped — pairs with twilight sprint.',
    timeAgo: '39 min ago',
    boosts: 11,
    tags: <String>['playlist', 'night'],
    isBoosted: false,
  ),
];

final dummyCommunitySprints = <CommunitySprint>[
  CommunitySprint(
    id: 'sprint_airport',
    circleId: 'circle_harbor',
    title: 'Twilight express relay',
    timeframe: 'Tonight • 18:00 - 21:00',
    description: 'Coordinate arrivals and share lane cues to double accepts.',
    focusTags: <String>['airport', 'coordination', 'surge'],
    joined: false,
  ),
  CommunitySprint(
    id: 'sprint_city',
    circleId: 'circle_city',
    title: 'Lunch micro-loop remix',
    timeframe: 'Tomorrow • 11:00 - 14:00',
    description: 'Run the three-stop loop and share live bundle pings.',
    focusTags: <String>['bundles', 'downtown'],
    joined: false,
  ),
  CommunitySprint(
    id: 'sprint_night',
    circleId: 'circle_night',
    title: 'Aurora vibe drop',
    timeframe: 'Friday • 21:30 - 00:30',
    description: 'Swap calm cues and co-create new night rider rituals.',
    focusTags: <String>['night', 'experience'],
    joined: false,
  ),
];

final dummyCommunityResources = <CommunityResource>[
  CommunityResource(
    id: 'resource_debrief',
    title: '3-step crew debrief',
    subtitle: 'Collect wins, remix challenges, align on next windows.',
    format: 'Playbook',
    duration: '5 min read',
    vibe: 'focus',
    isSaved: false,
  ),
  CommunityResource(
    id: 'resource_playlist',
    title: 'Night aurora playlist',
    subtitle: 'Ambient beats curated by the twilight squad.',
    format: 'Playlist',
    duration: '36 min',
    vibe: 'calm',
    isSaved: false,
  ),
  CommunityResource(
    id: 'resource_script',
    title: 'Welcome script refresh',
    subtitle: 'Crowdsourced openers that earn instant rapport.',
    format: 'Audio bites',
    duration: '8 min listen',
    vibe: 'energize',
    isSaved: false,
  ),
];

const impactFocusModes = <String>['efficiency', 'sustainability', 'experience'];

const defaultImpactPulse = ImpactPulse(
  city: 'Harbor grid & downtown spine',
  co2Saved: 42.0,
  cleanKm: 128.0,
  renewableShare: 0.62,
  streakDays: 4,
  message: 'Regenerative shift active — keep idle dips under 6 min.',
  highlights: <String>[
    '8 riders opted into green routing today',
    'Idle time trimmed by 12% vs yesterday',
    '3 shared rides stacked in waterfront zone',
    'Charging session scheduled off-peak automatically',
  ],
);

final dummyImpactGoals = <ImpactGoal>[
  ImpactGoal(
    id: 'impact_goal_idle',
    title: 'Cut idle emissions',
    description: 'Hold idle windows under 6 minutes per trip cluster.',
    current: 38,
    target: 55,
    unit: 'kg CO₂e',
    trend: 0.18,
    direction: TrendDirection.up,
  ),
  ImpactGoal(
    id: 'impact_goal_clean_km',
    title: 'Clean distance streak',
    description: 'Stack electric-only kilometres during prime demand.',
    current: 126,
    target: 180,
    unit: 'km',
    trend: 0.09,
    direction: TrendDirection.up,
  ),
  ImpactGoal(
    id: 'impact_goal_pledge',
    title: 'Rider delight pledges',
    description: 'Share the sustainability pledge after every pooled ride.',
    current: 9,
    target: 15,
    unit: 'pledges',
    trend: 0.03,
    direction: TrendDirection.steady,
  ),
];

final dummyImpactInitiatives = <ImpactInitiative>[
  ImpactInitiative(
    id: 'initiative_microhub',
    title: 'Micro-hub recharge relay',
    subtitle: 'Pair midday breaks with solar micro-hub top-ups.',
    icon: '🔋',
    category: 'energy',
    hours: '30 min / day',
    impactScore: 0.82,
    joined: false,
  ),
  ImpactInitiative(
    id: 'initiative_greenlane',
    title: 'Green lane express',
    subtitle: 'Sequence the greenest corridors during rush minutes.',
    icon: '🌿',
    category: 'routing',
    hours: '2 hrs / shift',
    impactScore: 0.76,
    joined: false,
  ),
  ImpactInitiative(
    id: 'initiative_story',
    title: 'Rider story capsule',
    subtitle: 'Record quick rider pledges to amplify city impact.',
    icon: '🎤',
    category: 'community',
    hours: '10 min / day',
    impactScore: 0.68,
    joined: false,
  ),
];

final dummyImpactActions = <ImpactAction>[
  ImpactAction(
    id: 'action_precondition',
    title: 'Pre-condition cabin',
    description: 'Cool the cabin remotely before pickup to avoid idle AC.',
    tag: 'efficiency',
    impactValue: 0.34,
    completed: false,
  ),
  ImpactAction(
    id: 'action_bundle_share',
    title: 'Offer pooled pledge',
    description: 'Invite pooled riders to split pledge and log the moment.',
    tag: 'experience',
    impactValue: 0.22,
    completed: false,
  ),
  ImpactAction(
    id: 'action_charge_shift',
    title: 'Shift charge timing',
    description: 'Move top-up to off-peak renewable window tonight.',
    tag: 'sustainability',
    impactValue: 0.28,
    completed: false,
  ),
  ImpactAction(
    id: 'action_idle_scan',
    title: 'Idle scan loop',
    description: 'Run 3-min scan to spot idle heavy corners to avoid.',
    tag: 'efficiency',
    impactValue: 0.18,
    completed: false,
  ),
];

final dummyImpactRipples = <ImpactRipple>[
  ImpactRipple(
    id: 'ripple_air',
    title: 'Air quality boost',
    value: 18.0,
    unit: '% cleaner vs avg',
    change: 0.6,
    direction: TrendDirection.up,
  ),
  ImpactRipple(
    id: 'ripple_rider',
    title: 'Rider pledge rate',
    value: 0.64,
    unit: 'opt-in',
    change: 0.04,
    direction: TrendDirection.up,
  ),
  ImpactRipple(
    id: 'ripple_grid',
    title: 'Grid harmony',
    value: 0.78,
    unit: 'renewable',
    change: -0.02,
    direction: TrendDirection.steady,
  ),
];

const innovationFocusLanes = <String>[
  'predictive navigation',
  'eco-routing loops',
  'rider delight',
  'crew enablement',
];

const defaultInnovationPulse = InnovationPulse(
  id: 'innovation_pulse_default',
  headline: 'Lab ready for twilight pilot loops.',
  readiness: 0.58,
  temperature: 0.64,
  focusLanes: <String>[
    'predictive navigation',
    'eco-routing loops',
    'rider delight',
  ],
  nextReview: 'Tonight · 21:30',
  energyBursts: <String>[
    'Micro-sprint at Ferry Pier ready.',
    'Beacon riders want calmer audio cues.',
    'Downtown detour blueprint trending.',
  ],
);

final dummyInnovationPrototypes = <InnovationPrototype>[
  InnovationPrototype(
    id: 'prototype_autopilot',
    title: 'Adaptive autopilot lane',
    summary: 'Layer AI-assisted cues for dynamic lane merges.',
    stage: 'discover',
    progress: 0.32,
    confidence: 0.42,
    nextStep: 'Host 3-ride observation loops with mentors.',
    tags: <String>['automation', 'signal'],
    lastNote: 'Crew noted smoother arrival glides in beta.',
  ),
  InnovationPrototype(
    id: 'prototype_ritual',
    title: 'Rider ritual capsule',
    summary: 'Bundle micro-wellness prompts into welcome flow.',
    stage: 'design',
    progress: 0.56,
    confidence: 0.58,
    nextStep: 'Storyboard audio cues with wellness studio.',
    tags: <String>['experience', 'wellness'],
    lastNote: 'Night riders upvoted the grounding voice track.',
  ),
  InnovationPrototype(
    id: 'prototype_heatmap',
    title: 'Live demand heatmap overlay',
    summary: 'Project community beacons into map overlay layers.',
    stage: 'pilot',
    progress: 0.78,
    confidence: 0.7,
    nextStep: 'Expand pilot to waterfront surge hours.',
    tags: <String>['insights', 'community'],
    lastNote: 'Pulse board shows 9 crews requesting beta access.',
  ),
];

final dummyInnovationExperiments = <InnovationExperiment>[
  InnovationExperiment(
    id: 'experiment_heatmap',
    title: 'Beacon overlay trial',
    hypothesis: 'Shared beacon cues lift accept rate by 6%.',
    metric: 'accept_rate',
    status: 'running',
    signal: 'positive',
    confidence: 0.62,
  ),
  InnovationExperiment(
    id: 'experiment_autopilot',
    title: 'Assistive lane nudge',
    hypothesis: 'Lane voice prompts reduce detours per trip.',
    metric: 'detour_delta',
    status: 'design',
    signal: 'forming',
    confidence: 0.48,
  ),
  InnovationExperiment(
    id: 'experiment_ritual',
    title: 'Welcome ritual resonance',
    hypothesis: 'Mindful intro lifts rider rating sentiment.',
    metric: 'sentiment_index',
    status: 'pilot',
    signal: 'upward',
    confidence: 0.67,
  ),
];

final dummyInnovationBlueprints = <InnovationBlueprint>[
  InnovationBlueprint(
    id: 'blueprint_harbor',
    title: 'Harbor twilight express',
    description: 'Align harbor surge, community beacons, and wellness cues.',
    horizon: '2 weeks',
    owner: 'Momentum crew',
    readiness: 0.66,
    phases: <String>['Discovery sync', 'Pilot window', 'Scale drop'],
  ),
  InnovationBlueprint(
    id: 'blueprint_rider',
    title: 'Rider delight ritual',
    description: 'Blend wellness studio assets with onboarding script.',
    horizon: '10 days',
    owner: 'Wellness lab',
    readiness: 0.58,
    phases: <String>['Map cues', 'Prototype audio', 'Crew practice'],
  ),
  InnovationBlueprint(
    id: 'blueprint_signal',
    title: 'Signal fusion board',
    description: 'Merge momentum tracks with community beacons for alerts.',
    horizon: '3 weeks',
    owner: 'Insights guild',
    readiness: 0.72,
    phases: <String>['Data braid', 'Pilot pack', 'Rollout'],
  ),
];

const dummyInnovationBursts = <String>[
  'Beacon overlay reducing decision lag.',
  'Autopilot lane voice prompts scored 4.6/5.',
  'Crew sprint aligning on twilight surge rituals.',
  'Rider welcome ritual trending in community lounge.',
  'Strategy lab feeding two fresh prototype briefs.',
];

const dummyInnovationHeadlines = <String>[
  'Prototype momentum cresting near pilot readiness.',
  'Lab insights highlight rider wow-factor leaps.',
  'Discovery lanes lighting up for next sprint.',
  'Scaling blueprint ready for twilight drop.',
];

const dummyInnovationNotes = <String>[
  'Rider audio cues rated 4.7 after micro-tweak.',
  'Navigation overlay resonated with late-night crew.',
  'Community beacon wants earlier access to ritual deck.',
  'Momentum coach suggested layering softer prompts.',
];

const dummyInnovationReviewSlots = <String>[
  'Tonight · 21:30',
  'Tomorrow · 07:15',
  'Weekend Lab · 16:00',
];

const innovationStageNextSteps = <String, String>{
  'discover': 'Host rider micro-interviews and capture friction notes.',
  'design': 'Prototype flows with crew feedback loops in Figma.',
  'pilot': 'Schedule 3-ride twilight pilot with mentor drivers.',
  'scale': 'Package lab learnings into nightly rollout playbook.',
};

