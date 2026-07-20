import 'package:flutter/material.dart';

/// ---------------------------------------------------------------------
/// PLACEHOLDER / MOCK DATA — UI DEMONSTRATION ONLY
/// ---------------------------------------------------------------------
/// As of Prompt #3, Buildings, Locations, and Announcements are loaded
/// live from Firestore (see `presentation/providers/data_providers.dart`)
/// — `mockLocations` and `mockAnnouncements` below are no longer used by
/// any screen and are kept only for reference/local testing.
///
/// `mockRouteSteps` is still used by the Route screen (step-by-step
/// directions require the routing engine, which is Prompt #4's job) and
/// `mockFaqs` still backs the static Help screen. Nothing here is real
/// hospital data.
/// ---------------------------------------------------------------------

/// A lightweight stand-in for a searchable place (department, room,
/// or landmark) shown in the Search screen and the location selectors.
class MockLocation {
  const MockLocation({
    required this.name,
    required this.category,
    required this.floor,
    required this.icon,
  });

  final String name;
  final String category;
  final String floor;
  final IconData icon;
}

/// A lightweight stand-in for a hospital announcement.
class MockAnnouncement {
  const MockAnnouncement({
    required this.title,
    required this.description,
    required this.date,
    required this.tag,
  });

  final String title;
  final String description;
  final String date;
  final String tag;
}

/// A single step in a placeholder walking-direction sequence.
class MockRouteStep {
  const MockRouteStep({
    required this.instruction,
    required this.icon,
    this.isDestination = false,
  });

  final String instruction;
  final IconData icon;
  final bool isDestination;
}

/// A single Help-screen FAQ entry.
class MockFaq {
  const MockFaq({required this.question, required this.answer});

  final String question;
  final String answer;
}

/// Placeholder searchable locations inside the Medical OP Building.
const List<MockLocation> mockLocations = [
  MockLocation(name: 'Main Entrance', category: 'Landmark', floor: 'Ground Floor', icon: Icons.meeting_room_rounded),
  MockLocation(name: 'Reception & Billing', category: 'Service', floor: 'Ground Floor', icon: Icons.point_of_sale_rounded),
  MockLocation(name: 'Pharmacy', category: 'Service', floor: 'Ground Floor', icon: Icons.local_pharmacy_rounded),
  MockLocation(name: 'General Medicine OPD', category: 'Department', floor: 'Ground Floor', icon: Icons.medical_services_rounded),
  MockLocation(name: 'Cardiology OPD', category: 'Department', floor: 'First Floor', icon: Icons.favorite_rounded),
  MockLocation(name: 'Orthopaedics OPD', category: 'Department', floor: 'First Floor', icon: Icons.accessibility_new_rounded),
  MockLocation(name: 'Radiology / X-Ray', category: 'Department', floor: 'First Floor', icon: Icons.camera_rounded),
  MockLocation(name: 'Dermatology OPD', category: 'Department', floor: 'Second Floor', icon: Icons.face_retouching_natural_rounded),
  MockLocation(name: 'ENT OPD', category: 'Department', floor: 'Second Floor', icon: Icons.hearing_rounded),
  MockLocation(name: 'Laboratory', category: 'Service', floor: 'Second Floor', icon: Icons.biotech_rounded),
  MockLocation(name: 'Lift Lobby A', category: 'Landmark', floor: 'All Floors', icon: Icons.elevator_rounded),
  MockLocation(name: 'Restrooms', category: 'Facility', floor: 'All Floors', icon: Icons.wc_rounded),
];

/// Placeholder announcements shown on the Announcements screen.
const List<MockAnnouncement> mockAnnouncements = [
  MockAnnouncement(
    title: 'Lift B under maintenance',
    description:
        'Lift B near the Radiology department will be closed for scheduled maintenance. Please use Lift A or the staircase near Reception.',
    date: 'Today, 9:00 AM',
    tag: 'Maintenance',
  ),
  MockAnnouncement(
    title: 'New Dermatology OPD opened',
    description:
        'The Dermatology OPD has moved to a larger space on the Second Floor, next to the ENT department.',
    date: 'Yesterday',
    tag: 'Update',
  ),
  MockAnnouncement(
    title: 'Extended pharmacy hours',
    description:
        'The Ground Floor pharmacy now stays open until 9:00 PM on weekdays to better serve evening OPD visitors.',
    date: '2 days ago',
    tag: 'Service',
  ),
  MockAnnouncement(
    title: 'Festival holiday schedule',
    description:
        'OPD services will run on a modified schedule during the upcoming festival days. Emergency services remain unaffected.',
    date: '4 days ago',
    tag: 'Notice',
  ),
];

/// Placeholder step-by-step walking directions for the Route screen.
const List<MockRouteStep> mockRouteSteps = [
  MockRouteStep(instruction: 'Walk straight from the Main Entrance', icon: Icons.straight_rounded),
  MockRouteStep(instruction: 'Turn left after the Reception desk', icon: Icons.turn_left_rounded),
  MockRouteStep(instruction: 'Take Lift A to the First Floor', icon: Icons.elevator_rounded),
  MockRouteStep(instruction: 'Continue straight past the waiting area', icon: Icons.straight_rounded),
  MockRouteStep(instruction: 'Turn right at the corridor junction', icon: Icons.turn_right_rounded),
  MockRouteStep(
    instruction: 'Destination is on your right',
    icon: Icons.flag_rounded,
    isDestination: true,
  ),
];

/// Placeholder FAQs for the Help screen.
const List<MockFaq> mockFaqs = [
  MockFaq(
    question: 'How do I search for a department?',
    answer:
        'Tap "Search Department" on the Home screen, then type a department, room, or facility name. Matching results appear instantly as you type.',
  ),
  MockFaq(
    question: 'How do I select my current location?',
    answer:
        'On the Home screen, tap the "Current Location" field and choose the landmark closest to you — for example, the Main Entrance or a nearby lift lobby.',
  ),
  MockFaq(
    question: 'How do I find my department?',
    answer:
        'Select your current location and your destination department on the Home screen, then tap "Find Route" to see step-by-step walking directions.',
  ),
  MockFaq(
    question: 'What if I can\u2019t find my destination in the list?',
    answer:
        'Try searching with a shorter keyword, such as the specialty name only. If it still doesn\u2019t appear, please ask hospital staff at the nearest reception desk.',
  ),
  MockFaq(
    question: 'Does the app work without internet access?',
    answer:
        'KMC Navigator needs a connection to load hospital data and announcements. Basic navigation features will work offline in a future update.',
  ),
];
