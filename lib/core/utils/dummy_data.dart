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


const defaultMasteryPulse = MasteryPulse(
  id: 'mastery_pulse_default',
  focusTheme: 'Harbor cadence warmup',
  momentum: 0.54,
  energy: 0.68,
  microPractice: 'Run the 60-second rider welcome reset twice.',
  pathways: <String>[
    'Harbor express greetings',
    'Twilight merge timing',
    'Evening calm anchor',
  ],
  coachNote: 'Crew mentors flagged a prime hour to sharpen twilight merges.',
);

final dummyMasteryModules = <MasteryModule>[
  MasteryModule(
    id: 'module_signal_sense',
    title: 'Signal sense sprint',
    subtitle: 'Micro-drills to react to surge signals faster.',
    focusArea: 'Signal anticipation',
    lessons: 8,
    completedLessons: 3,
    progress: 0.38,
    icon: '⚡️',
    microPractice: 'Mirror surge dashboard every 15 minutes.',
    reflectionPrompt: 'What signal helped you pivot faster today?',
    isFocus: true,
  ),
  MasteryModule(
    id: 'module_rider_presence',
    title: 'Rider presence loop',
    subtitle: 'Elevate greetings, tone, and closure sequences.',
    focusArea: 'Passenger experience',
    lessons: 6,
    completedLessons: 2,
    progress: 0.33,
    icon: '🌟',
    microPractice: 'Layer a positive close-out mantra on departures.',
    reflectionPrompt: 'How did you reset the cabin tone between rides?',
    isFocus: false,
  ),
  MasteryModule(
    id: 'module_energy_flow',
    title: 'Energy flow map',
    subtitle: 'Design hydration, nutrition, and rest checkpoints.',
    focusArea: 'Driver resilience',
    lessons: 5,
    completedLessons: 1,
    progress: 0.2,
    icon: '💧',
    microPractice: 'Schedule the breathing deck before surge windows.',
    reflectionPrompt: 'Which ritual kept your energy stable tonight?',
    isFocus: false,
  ),
];

final dummyMasteryWorkshops = <MasteryWorkshop>[
  MasteryWorkshop(
    id: 'workshop_harbor',
    title: 'Harbor twilight choreography',
    focus: 'Signal anticipation',
    host: 'Amina · Crew mentor',
    date: 'Thu · 19:00',
    highlight: 'Live breakdown of surge tells from last week.',
    enrolled: true,
  ),
  MasteryWorkshop(
    id: 'workshop_presence',
    title: 'Presence and warmth clinic',
    focus: 'Passenger experience',
    host: 'Leo · Rider whisperer',
    date: 'Sat · 15:30',
    highlight: 'Practice warm-up scripts with live feedback.',
    enrolled: false,
  ),
  MasteryWorkshop(
    id: 'workshop_energy',
    title: 'Energy map co-design',
    focus: 'Driver resilience',
    host: 'Maya · Wellness studio',
    date: 'Sun · 10:00',
    highlight: 'Pair your planner with recovery rituals.',
    enrolled: false,
  ),
];

final dummyMasteryBadges = <MasteryBadge>[
  MasteryBadge(
    id: 'badge_signal_chaser',
    title: 'Signal chaser',
    description: 'React to three surge cues in under two minutes.',
    icon: '🚨',
    moduleIds: <String>['module_signal_sense'],
    progress: 0.38,
    threshold: 0.8,
    unlocked: false,
  ),
  MasteryBadge(
    id: 'badge_host_hero',
    title: 'Host hero',
    description: 'Maintain 4.9 warmth average across the week.',
    icon: '🤝',
    moduleIds: <String>['module_rider_presence', 'module_signal_sense'],
    progress: 0.35,
    threshold: 0.75,
    unlocked: false,
  ),
  MasteryBadge(
    id: 'badge_energy_sage',
    title: 'Energy sage',
    description: 'Hit three wellness check-ins during surge shifts.',
    icon: '🧘‍♀️',
    moduleIds: <String>['module_energy_flow'],
    progress: 0.2,
    threshold: 0.7,
    unlocked: false,
  ),
];

final dummyMasteryReflections = <MasteryReflection>[
  MasteryReflection(
    id: 'reflection_1',
    prompt: 'Signal anticipation',
    response: 'Caught the ferry surge six minutes early after the planner ping.',
    timestamp: DateTime.now().subtract(const Duration(hours: 6)),
  ),
  MasteryReflection(
    id: 'reflection_2',
    prompt: 'Passenger experience',
    response: 'Soft jazz loop kept the cabin calm during the storm detour.',
    timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
  ),
];

const dummyMasteryPathways = <String>[
  'Twilight merge choreography',
  'Crew co-pilot callouts',
  'Rider warmth cadences',
  'Hydration resets every 90 minutes',
  'Focus breath in staging lane',
  'Post-ride gratitude loop',
];

const dummyMasteryCoachNotes = <String>[
  'Prime-time cadence ready — lean on the harbor micro-drill tonight.',
  'Crew mentors noticed sharper greetings — keep the warmth rising.',
  'Signals humming — rotate through your surge dashboards every 10 minutes.',
  'Energy map aligned — stack a hydration check before the late sprint.',
];

const dummyMasteryMicroPractices = <String>[
  'Run the 3-2-1 breath stack before entering a hotspot.',
  'Swap playlists at each third ride to refresh tone.',
  'Log a 20-second gratitude note after each five-ride set.',
  'Stretch shoulders while waiting in the staging lane.',
  'Check mirror posture when the beacon signal flashes.',
];

const defaultHorizonPulse = HorizonPulse(
  headline: 'City grid shift tilts toward riverside districts',
  alignment: 0.68,
  runwayDays: 11,
  confidence: 0.62,
  guidingQuestion: 'Where will the next 15-ride streak emerge?',
  focusThemes: <String>[
    'Harbor night festival',
    'Airport express experiments',
    'Downtown micro-shift overlap',
  ],
  signalHighlights: <String>[
    '48hr micro-climate spike',
    'Rider concierge trials',
    'Multi-modal hub upgrade',
  ],
  nextWindow: 'Thu 18:00',
);

final dummyHorizonScenarios = <HorizonScenario>[
  HorizonScenario(
    id: 'scenario_1',
    title: 'Riverwalk surge lanes',
    timeframe: 'Next 7 days',
    impact: 0.76,
    probability: 0.64,
    focus: 'Evening festival routes',
    narrative:
        'Night festival foot traffic spills over to private rides with premium fares.',
    isFocus: true,
  ),
  HorizonScenario(
    id: 'scenario_2',
    title: 'Airport midnight corridor',
    timeframe: '14 day outlook',
    impact: 0.58,
    probability: 0.52,
    focus: 'Late-night arrival waves',
    narrative:
        'Flight schedule changes add late pulses that need flexible driver coverage.',
  ),
  HorizonScenario(
    id: 'scenario_3',
    title: 'Old town street closures',
    timeframe: '21 day outlook',
    impact: 0.44,
    probability: 0.48,
    focus: 'Detour aware loops',
    narrative:
        'Planned restorations reduce parking but increase short-stay shuttle demand.',
  ),
];

final dummyHorizonSignals = <HorizonSignal>[
  HorizonSignal(
    id: 'signal_1',
    title: 'Harbor decks reopening',
    category: 'City ops',
    description:
        'Dock spaces reopen with capacity for live events and pop-up dining zones.',
    momentum: 0.72,
    confidence: 0.61,
  ),
  HorizonSignal(
    id: 'signal_2',
    title: 'Concierge pilot invites',
    category: 'Premium',
    description:
        'Hotel concierge partners request elevated greeting scripts during weekends.',
    momentum: 0.55,
    confidence: 0.66,
  ),
  HorizonSignal(
    id: 'signal_3',
    title: 'Riverside sound checks',
    category: 'Events',
    description:
        'Sound checks confirmed for nightly stage warmups leading to pre-ride gatherings.',
    momentum: 0.48,
    confidence: 0.52,
  ),
];

final dummyHorizonRunway = <HorizonRunwayMarker>[
  HorizonRunwayMarker(
    id: 'runway_1',
    title: 'Tune riverside playlist arc',
    timeframe: 'Within 48h',
    priority: 'High',
    notes: 'Blend calm intros with upbeat closes for festival exits.',
  ),
  HorizonRunwayMarker(
    id: 'runway_2',
    title: 'Prep airport micro-break kit',
    timeframe: 'Next 5 days',
    priority: 'Medium',
    notes: 'Add hydration + stretch cards near baggage pickup cues.',
  ),
  HorizonRunwayMarker(
    id: 'runway_3',
    title: 'Map old town detour loops',
    timeframe: 'Next 10 days',
    priority: 'Medium',
    notes: 'Coordinate with community hub for lane-by-lane voice notes.',
  ),
];

final dummyHorizonBlueprints = <HorizonBlueprint>[
  HorizonBlueprint(
    id: 'blueprint_1',
    pillar: 'Experience',
    summary: 'Deliver signature riverwalk send-offs with music cues.',
    owner: 'Crew ambience lead',
    status: 'Activating',
    confidence: 0.74,
    actions: <String>[
      'Sync playlists with festival calendar',
      'Test 2-minute warm welcome script',
      'Share vibe notes in crew lounge',
    ],
    nextWindow: 'Thu dusk',
  ),
  HorizonBlueprint(
    id: 'blueprint_2',
    pillar: 'Coverage',
    summary: 'Layer midnight airport corridor coverage with tag-team slots.',
    owner: 'Momentum coach',
    status: 'In review',
    confidence: 0.63,
    actions: <String>[
      'Pair drivers for 2-hour rotations',
      'Add hydration reminders at shift handoffs',
      'Log rider comfort scores nightly',
    ],
    nextWindow: 'Mon 23:30',
  ),
  HorizonBlueprint(
    id: 'blueprint_3',
    pillar: 'Signals',
    summary: 'Capture detour intel before old town resurfacing.',
    owner: 'Community scout',
    status: 'Queued',
    confidence: 0.51,
    actions: <String>[
      'Walk detour loops with crew scout',
      'Record audio markers for tricky turns',
      'Publish quick map overlays',
    ],
    nextWindow: 'Fri AM',
  ),
];

const dummyHorizonHeadlines = <String>[
  'Future shifts lean into riverside evenings',
  'Transit revamp creates midnight micro-waves',
  'Signals cluster around cross-dock experiments',
];

const dummyHorizonQuestions = <String>[
  'Which route unlocks the next signature rider story?',
  'How do we choreograph coverage before the surge appears?',
  'Where can delight and efficiency intersect this week?',
];
final defaultCosmosPulse = CosmosPulse(
  headline: 'Night orbit alignment rising',
  magnetism: 0.78,
  signalStrength: 0.66,
  activeAlliances: 4,
  window: '21:00 - 23:30',
  highlight: 'Pair harbor pickups with airport drop-offs for a double boost.',
  nextTrajectory: 'Dawn corridor 05:40',
  focus: 'Harbor → Airport corridor',
);

final dummyCosmosConstellations = <CosmosConstellation>[
  CosmosConstellation(
    id: 'cosmos-constellation-airport',
    title: 'Aero Nexus',
    icon: '🛫',
    anchor: 'Airport Express',
    resonance: 0.82,
    window: '05:00 - 07:30',
    snapshot: 'Early flyers syncing with harbor shuttles.',
    isFocus: true,
  ),
  CosmosConstellation(
    id: 'cosmos-constellation-harbor',
    title: 'Harbor Tide',
    icon: '⚓',
    anchor: 'Harbor Front',
    resonance: 0.74,
    window: '19:00 - 21:30',
    snapshot: 'Evening cruise departures with premium tips.',
  ),
  CosmosConstellation(
    id: 'cosmos-constellation-midtown',
    title: 'Midtown Current',
    icon: '🌆',
    anchor: 'Midtown Loop',
    resonance: 0.68,
    window: '11:30 - 14:00',
    snapshot: 'Lunch rush stacking with corporate bookings.',
  ),
  CosmosConstellation(
    id: 'cosmos-constellation-nightfall',
    title: 'Nightfall Relay',
    icon: '🌙',
    anchor: 'Old Town',
    resonance: 0.7,
    window: '22:00 - 00:30',
    snapshot: 'Late-night concerts feeding cross-city rides.',
  ),
];

final dummyCosmosOrbits = <CosmosOrbit>[
  CosmosOrbit(
    id: 'orbit-airport-corridor',
    label: 'Airport corridor',
    window: '05:00 - 07:30',
    magnetic: 0.76,
    trajectory: 0.18,
    tone: 'High uplift',
  ),
  CosmosOrbit(
    id: 'orbit-harbor-link',
    label: 'Harbor link',
    window: '18:30 - 21:15',
    magnetic: 0.71,
    trajectory: 0.12,
    tone: 'Steady surge',
  ),
  CosmosOrbit(
    id: 'orbit-midtown-fusion',
    label: 'Midtown fusion',
    window: '11:00 - 13:30',
    magnetic: 0.63,
    trajectory: -0.04,
    tone: 'Balanced flow',
  ),
  CosmosOrbit(
    id: 'orbit-night-relay',
    label: 'Night relay',
    window: '22:15 - 00:45',
    magnetic: 0.69,
    trajectory: 0.08,
    tone: 'Rising sparks',
  ),
];

final dummyCosmosBeacons = <CosmosBeacon>[
  CosmosBeacon(
    id: 'cosmos-beacon-airport',
    title: 'Runway ripple',
    subtitle: 'Align departures with downtown returns.',
    energy: 0.82,
    urgency: 3,
  ),
  CosmosBeacon(
    id: 'cosmos-beacon-harbor',
    title: 'Pier sync',
    subtitle: 'Pinpoint cruise unload surge windows.',
    energy: 0.74,
    urgency: 2,
  ),
  CosmosBeacon(
    id: 'cosmos-beacon-midtown',
    title: 'Lunch fusion',
    subtitle: 'Bundle office lunch runs with express rides.',
    energy: 0.61,
    urgency: 1,
  ),
];

final dummyCosmosExpeditions = <CosmosExpedition>[
  CosmosExpedition(
    id: 'cosmos-expedition-dawn',
    title: 'Dawn corridor relay',
    window: 'Tomorrow 05:30',
    focus: 'Back-to-back airport shifts with zero idle time.',
    progress: 0.42,
  ),
  CosmosExpedition(
    id: 'cosmos-expedition-sunset',
    title: 'Sunset harbor sync',
    window: 'Tonight 19:00',
    focus: 'Stack harbor pickups with premium drop-offs.',
    progress: 0.58,
  ),
  CosmosExpedition(
    id: 'cosmos-expedition-night',
    title: 'Night relay sprint',
    window: 'Tonight 23:00',
    focus: 'Bridge late-night events into dawn airport runs.',
    progress: 0.33,
  ),
];

final dummyCosmosArtifacts = <CosmosArtifact>[
  CosmosArtifact(
    id: 'cosmos-artifact-playbook',
    title: 'Orbit playbook 2.0',
    summary: 'Curated moves linking harbor and airport runs.',
    tag: 'Strategy',
  ),
  CosmosArtifact(
    id: 'cosmos-artifact-signal',
    title: 'Signal harmonics',
    summary: 'Top driver sequences for night relay coverage.',
    tag: 'Signals',
  ),
  CosmosArtifact(
    id: 'cosmos-artifact-alliance',
    title: 'Alliance ledger',
    summary: 'Partner perks unlocked with aligned arrivals.',
    tag: 'Alliances',
  ),
];

final dummyCosmosHeadlines = <String>[
  'Constellation uplift detected across harbor lanes',
  'Night orbit alignment surging 12% above baseline',
  'Magnetic flux primed for dawn express gains',
  'Alliance mesh syncing with city-wide demand pulses',
];

final dummyCosmosHighlights = <String>[
  'Anchor a triple loop before the dawn corridor opens.',
  'Sync harbor arrivals with airport departures for prime boosts.',
  'Pair Midtown lunches with express return legs.',
  'Set night relay checkpoints for smoother handoffs.',
];

final dummyCosmosFocuses = <String>[
  'Harbor → Airport corridor',
  'Midtown → Harbor express',
  'Downtown → Night relay arc',
  'Airport → Midtown lunch ladder',
];

final dummyCosmosTrajectories = <String>[
  'Sunrise surge 05:20',
  'Twilight cascade 19:10',
  'Nightfall sprint 23:45',
  'Lunch wave 12:05',
];

final defaultFusionPulse = FusionPulse(
  headline: 'Fusion lattice warming up',
  alignment: 0.72,
  cohesion: 0.64,
  window: '18:00 - 22:00',
  focus: 'Harbor storytelling lane',
  nextSync: 'Sync check 19:40',
  highlight: 'Blend premium playlists with express airport returns.',
);

final dummyFusionStrands = <FusionStrand>[
  FusionStrand(
    id: 'fusion-strand-story',
    icon: '🎙️',
    title: 'Story lane',
    snapshot: 'Curated narratives for loyalty riders.',
    alignment: 0.78,
    flow: 0.66,
    isFocus: true,
  ),
  FusionStrand(
    id: 'fusion-strand-sonic',
    icon: '🎧',
    title: 'Sonic sync',
    snapshot: 'Adaptive soundscapes for peak vibes.',
    alignment: 0.69,
    flow: 0.71,
  ),
  FusionStrand(
    id: 'fusion-strand-lux',
    icon: '💎',
    title: 'Lux weave',
    snapshot: 'Treat arrival rituals for VIP bookings.',
    alignment: 0.74,
    flow: 0.58,
  ),
  FusionStrand(
    id: 'fusion-strand-groove',
    icon: '🎶',
    title: 'Groove stitch',
    snapshot: 'Micro-celebrations on milestone drop-offs.',
    alignment: 0.62,
    flow: 0.64,
  ),
];

final dummyFusionCanvases = <FusionCanvas>[
  FusionCanvas(
    id: 'fusion-canvas-twilight',
    title: 'Twilight blend',
    description: 'Harbor golden hour stitched with airport returns.',
    threads: ['Harbor', 'Airport', 'Old town'],
    heat: 0.7,
    cohesion: 0.6,
  ),
  FusionCanvas(
    id: 'fusion-canvas-late',
    title: 'Late night glow',
    description: 'After-show pickups fused with skyline detours.',
    threads: ['Arena', 'Downtown', 'Skyline'],
    heat: 0.65,
    cohesion: 0.68,
  ),
  FusionCanvas(
    id: 'fusion-canvas-dawn',
    title: 'Dawn resonance',
    description: 'Sunrise airport runs layered with cafe stories.',
    threads: ['Airport', 'Cafe row', 'Financial'],
    heat: 0.58,
    cohesion: 0.72,
  ),
];

final dummyFusionExperiments = <FusionExperiment>[
  FusionExperiment(
    id: 'fusion-experiment-playlist',
    title: 'Playlist concierge',
    intent: 'Co-create sonic palettes with regular riders.',
    stage: 'Pilot',
    confidence: 0.62,
  ),
  FusionExperiment(
    id: 'fusion-experiment-moment',
    title: 'Moment markers',
    intent: 'Trigger celebratory lighting on milestones.',
    stage: 'Sprint',
    confidence: 0.57,
  ),
  FusionExperiment(
    id: 'fusion-experiment-scout',
    title: 'Story scout',
    intent: 'Capture rider stories for loyalty follow-ups.',
    stage: 'Explore',
    confidence: 0.5,
  ),
];

final dummyFusionSignals = <FusionSignal>[
  FusionSignal(
    id: 'fusion-signal-harbor',
    title: 'Harbor storytellers',
    detail: 'Writers meetup requesting immersive arrivals.',
    urgency: 3,
  ),
  FusionSignal(
    id: 'fusion-signal-campus',
    title: 'Campus showcase',
    detail: 'Student creators expecting custom playlists.',
    urgency: 2,
  ),
  FusionSignal(
    id: 'fusion-signal-lounge',
    title: 'Sky lounge revival',
    detail: 'Premium flyers seeking signature send-offs.',
    urgency: 4,
  ),
];

final defaultOdysseyPulse = OdysseyPulse(
  headline: 'Odyssey arc humming with new signals',
  rhythm: 0.68,
  momentum: 0.62,
  window: 'Next 8 hours',
  focus: 'Sunset harbor streak',
  nextMilestone: 'Checkpoint at 19:45',
  storyBeat: 'Line up twilight pickups with creator studio drops.',
);

final dummyOdysseyChapters = <OdysseyChapter>[
  OdysseyChapter(
    id: 'odyssey-chapter-dawn',
    title: 'Dawn ignition',
    motif: 'Warm morning rituals with crafted playlists.',
    progress: 0.72,
    spotlight: 'Airport express riders asked for mindful openers.',
    isFocus: true,
  ),
  OdysseyChapter(
    id: 'odyssey-chapter-surge',
    title: 'Midday surge',
    motif: 'Sync lunch loops with co-working shuttles.',
    progress: 0.58,
    spotlight: 'Coworking loft extended their afternoon window.',
  ),
  OdysseyChapter(
    id: 'odyssey-chapter-twilight',
    title: 'Twilight story',
    motif: 'Pair harbor views with film studio call-times.',
    progress: 0.46,
    spotlight: 'Indie film crew prepping for night shoots.',
  ),
  OdysseyChapter(
    id: 'odyssey-chapter-night',
    title: 'Night resonance',
    motif: 'Layer skyline detours on premium returns.',
    progress: 0.31,
    spotlight: 'Sky lounge hints at surprise midnight drop.',
  ),
];

final dummyOdysseyRoutes = <OdysseyRoute>[
  OdysseyRoute(
    id: 'odyssey-route-harbor',
    title: 'Harbor → Creator studios',
    stage: 'Sculpt',
    distance: 12.4,
    readiness: 0.66,
    signal: 'Creator set requests scenic arrival teasers.',
  ),
  OdysseyRoute(
    id: 'odyssey-route-campus',
    title: 'Campus → Downtown showcase',
    stage: 'Launch',
    distance: 9.1,
    readiness: 0.72,
    signal: 'Live showcase expects curated intros.',
    tracking: true,
  ),
  OdysseyRoute(
    id: 'odyssey-route-airport',
    title: 'Airport → Sunset pier',
    stage: 'Prototype',
    distance: 18.7,
    readiness: 0.54,
    signal: 'Premium flyers flagged twilight arrival tours.',
  ),
  OdysseyRoute(
    id: 'odyssey-route-sprint',
    title: 'Night sprint → Skyline',
    stage: 'Explore',
    distance: 7.6,
    readiness: 0.48,
    signal: 'Late-night creators want micro-celebrations.',
  ),
];

final dummyOdysseyBeacons = <OdysseyBeacon>[
  OdysseyBeacon(
    id: 'odyssey-beacon-harbor',
    title: 'Harbor twilight welcome',
    intent: 'Layer warm lighting on premium returns.',
    eta: 'In 1h 20m',
    energy: 0.74,
  ),
  OdysseyBeacon(
    id: 'odyssey-beacon-campus',
    title: 'Campus creative ping',
    intent: 'Queue curated audio cues for creators.',
    eta: 'In 45m',
    energy: 0.62,
    boosted: true,
  ),
  OdysseyBeacon(
    id: 'odyssey-beacon-airport',
    title: 'Airport drift sync',
    intent: 'Align traveler welcomes with brand rituals.',
    eta: 'Tomorrow 06:30',
    energy: 0.55,
  ),
];

final dummyOdysseyReflections = <OdysseyReflection>[
  OdysseyReflection(
    id: 'odyssey-reflection-morning',
    prompt: 'What made the morning arc resonate?',
    lastEntry: 'Paired airport arrivals with a sunrise playlist.',
    sentiment: 'Hopeful',
    energy: 0.68,
  ),
  OdysseyReflection(
    id: 'odyssey-reflection-midday',
    prompt: 'Which midday route felt most aligned?',
    lastEntry: 'Coworking shuttle appreciated surprise coffee tokens.',
    sentiment: 'Energized',
    energy: 0.61,
  ),
  OdysseyReflection(
    id: 'odyssey-reflection-night',
    prompt: 'How did the night skyline story land?',
    lastEntry: 'VIP couple loved the custom city trivia stops.',
    sentiment: 'Grateful',
    energy: 0.57,
  ),
];

final dummyOdysseyFocuses = <String>[
  'Sunrise runway handshake',
  'Harbor twilight crescendo',
  'Campus showcase baton',
  'Night skyline celebration',
];

final dummyOdysseyWindows = <String>[
  'Next 4 hours',
  'Next 6 hours',
  'Next 8 hours',
  'Overnight arc',
];

final dummyOdysseyMilestones = <String>[
  'Checkpoint at 19:45',
  'Bridge sync at 21:10',
  'Sunrise meetup 06:20',
  'Creator lounge at 15:30',
];

final dummyOdysseyBeats = <String>[
  'Stitch harbor welcomes with creator studio drops.',
  'Layer midday co-working loops with snack rituals.',
  'Prime skyline tours with micro-story stops.',
  'Cue nighttime gratitude notes for loyal riders.',
];

const dummyFusionHeadlines = <String>[
  'Fusion lattice humming 9% above baseline',
  'Premium riders seeking curated sonic blends tonight',
  'Story-driven loops unlocking repeat bookings',
];

const dummyFusionHighlights = <String>[
  'Layer skyline detours with a celebratory soundtrack.',
  'Pair story prompts with arrival rituals for top riders.',
  'Cue a sonic lift before airport farewell runs.',
];

const dummyFusionFocuses = <String>[
  'Harbor storytelling lane',
  'Skyline celebration loop',
  'Airport twilight weave',
  'Downtown creator express',
];

const dummyFusionSyncs = <String>[
  'Sync check 19:40',
  'Sync check 22:10',
  'Sync check 05:20',
  'Sync check 13:45',
];

final ZenithPulse defaultZenithPulse = ZenithPulse(
  headline: 'Zenith weave trending 7% above guidance',
  clarity: 0.78,
  acceleration: 0.64,
  altitude: 0.88,
  momentum: 0.71,
  window: 'Twilight 18:00-22:00',
  message: 'Prime skyline loops are ready for story-driven riders tonight.',
);

const List<String> zenithModes = <String>[
  'Launch cadence',
  'Navigation sync',
  'Resonance craft',
];

const List<String> zenithWindows = <String>[
  'Sunrise 05:30-09:00',
  'Midday 11:00-14:00',
  'Twilight 18:00-22:00',
  'Midnight 22:00-02:00',
];

const List<String> zenithPulseHeadlines = <String>[
  'Zenith weave aligning with high-value rider arcs',
  'Momentum beams spiking toward late-night skyline loops',
  'Navigator cues highlighting premium harbor storytellers',
  'Rhythm arcs stabilizing around creator corridor',
];

final List<ZenithVector> dummyZenithVectors = <ZenithVector>[
  const ZenithVector(
    id: 'zenith-vector-skyline',
    icon: '🌆',
    title: 'Skyline anthem',
    summary: 'Layer skyline arcs with curated arrival audio and gratitude loops.',
    momentum: 0.72,
    isFocus: true,
  ),
  const ZenithVector(
    id: 'zenith-vector-harbor',
    icon: '⚓',
    title: 'Harbor resonance',
    summary: 'Blend harbor meetups with maker shout-outs and snack rituals.',
    momentum: 0.63,
  ),
  const ZenithVector(
    id: 'zenith-vector-campus',
    icon: '🎓',
    title: 'Campus pulse',
    summary: 'Surface campus shuttle loops with micro-coaching moments.',
    momentum: 0.58,
  ),
  const ZenithVector(
    id: 'zenith-vector-airport',
    icon: '🛫',
    title: 'Runway glow',
    summary: 'Prime runway farewells with reflective journaling cues.',
    momentum: 0.54,
  ),
];

final List<ZenithPath> dummyZenithPaths = <ZenithPath>[
  const ZenithPath(
    id: 'zenith-path-skyline',
    title: 'Skyline orbit',
    window: 'Twilight 18:00',
    distanceKm: 14.2,
    progress: 0.46,
    active: true,
  ),
  const ZenithPath(
    id: 'zenith-path-harbor',
    title: 'Harbor weave',
    window: 'Sunset 19:10',
    distanceKm: 11.8,
    progress: 0.38,
  ),
  const ZenithPath(
    id: 'zenith-path-campus',
    title: 'Campus glide',
    window: 'Midday 12:20',
    distanceKm: 9.6,
    progress: 0.57,
    active: true,
  ),
  const ZenithPath(
    id: 'zenith-path-airport',
    title: 'Runway ascent',
    window: 'Midnight 23:40',
    distanceKm: 21.4,
    progress: 0.24,
  ),
];

final List<ZenithSignal> dummyZenithSignals = <ZenithSignal>[
  const ZenithSignal(
    id: 'zenith-signal-skyline',
    title: 'Skyline beacon ping',
    detail: 'Creator corridor expects heightened playlist requests at 20:15.',
    severity: 3,
  ),
  const ZenithSignal(
    id: 'zenith-signal-harbor',
    title: 'Harbor cameo',
    detail: 'Local maker collective ready to co-host arrival rituals.',
    severity: 2,
  ),
  const ZenithSignal(
    id: 'zenith-signal-campus',
    title: 'Campus crescendo',
    detail: 'Students prepping gratitude notes for twilight loops.',
    severity: 4,
  ),
  const ZenithSignal(
    id: 'zenith-signal-airport',
    title: 'Runway flare',
    detail: 'Long-haul travelers requesting reflective farewells.',
    severity: 3,
  ),
];
