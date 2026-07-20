# KMC Navigator — V1 Project Foundation

Indoor step-by-step walking directions for **Kottayam Medical College**,
**Medical OP Building** (3 floors). This is the **foundation only** —
no routing, hospital data, or business logic yet.

## Folder structure (Clean Architecture)

```
lib/
├── main.dart                    # App entry point: Firebase init, ProviderScope, MaterialApp.router
│
├── core/                        # Cross-cutting, app-wide building blocks
│   ├── constants/                 # Colors, strings, spacing/sizing tokens
│   ├── theme/                     # Material 3 hospital theme
│   ├── routing/                   # GoRouter setup + route name constants
│   └── widgets/                   # Reusable UI: PrimaryButton, AppCard, LoadingIndicator, PlaceholderScaffold
│
├── domain/                      # Pure business models — no Flutter/Firebase imports
│   └── entities/                  # Building, Floor, Location, Connection, Announcement, Admin
│
├── data/                        # External-world integrations
│   └── services/                  # FirestoreService, AuthService, RoutingService, NotificationService
│
└── presentation/                # UI layer
    ├── providers/                 # Riverpod providers wiring services for the UI
    └── screens/                   # Splash, Home, Route, Search, Announcement, Admin (Login + Dashboard)
```

**Why this split:** `domain` stays framework-agnostic so business rules
(like routing logic, once added) can be unit-tested without Flutter or
Firebase. `data` is the only layer allowed to talk to Firebase SDKs.
`presentation` only depends on `domain` entities and `core` widgets/theme
— it never imports Firebase directly. `core` has no dependency on any
other layer, so it can be reused anywhere.

## Dependencies (see `pubspec.yaml`)

| Package | Purpose |
|---|---|
| `firebase_core`, `cloud_firestore`, `firebase_auth`, `firebase_messaging` | Firebase backend, Firestore, Admin auth, push notifications |
| `flutter_riverpod` | State management |
| `go_router` | Declarative navigation |
| `google_fonts` | Accessible, professional typography |

## Screens included (navigation only, no logic)

- **Splash** → auto-navigates to Home after a short delay
- **Home** → cards for Get Directions / Search / Announcements, admin icon in the app bar
- **Route** → placeholder for start/destination selection + directions
- **Search** → placeholder for department/room search
- **Announcement** → placeholder for hospital notices list
- **Admin Login** → email/password form UI (no auth call wired up yet)
- **Admin Dashboard** → placeholder management list (Buildings, Floors, Locations, Connections, Announcements)

## Models included (structure only, no sample data)

`Building`, `Floor`, `Location`, `Connection`, `Announcement`, `Admin` —
all in `lib/domain/entities/`. Each has a `// TODO` marking where
Firestore `fromMap`/`toMap` serialization will be added next.

## Services included (placeholders only)

`FirestoreService`, `AuthService`, `RoutingService`, `NotificationService`
in `lib/data/services/`, each exposed via a Riverpod provider in
`lib/presentation/providers/service_providers.dart`. Method bodies are
intentionally unimplemented (`TODO` / `UnimplementedError`).

## Setup steps (once you're ready to run this)

1. `flutter pub get`
2. Create a Firebase project, then run `flutterfire configure` from the
   project root — this generates `lib/firebase_options.dart` and the
   native config files (`google-services.json`, `GoogleService-Info.plist`).
3. In `lib/main.dart`, uncomment the `firebase_options.dart` import and
   the `options: DefaultFirebaseOptions.currentPlatform` line.
4. `flutter run`

## What's intentionally NOT here yet

- Hospital data (buildings/floors/locations/connections for KMC OP Building)
- Routing/pathfinding algorithm
- Push notification handling
- Admin CRUD screens (buttons exist on the dashboard; they're not wired to forms yet)

These will be implemented in the next prompts, on top of this foundation.

---

## Prompt #3 — Firebase backend & data layer

Everything above is Prompt #1/#2 (architecture + UI). Prompt #3 added the
live Firebase wiring, on top of the same architecture:

**Entities** (`domain/entities/`) now each have `fromFirestore()` /
`toFirestore()` / `copyWith()`. They stay Firebase-SDK-free (Map-based
serialization) except `Announcement`, which imports `cloud_firestore`
only for the `Timestamp` value type.

**Data layer** (`data/`):
- `services/firestore_service.dart` — typed collection refs (`withConverter`) for `buildings`, `locations`, `connections`, `announcements`, `admins`.
- `services/auth_service.dart` — admin-only email/password sign-in via Firebase Auth.
- `services/notification_service.dart` — FCM permission request + shared `announcements` topic subscription.
- `repositories/` — one per collection, wrapping services in streams/futures and mapping every exception through `core/errors/app_failure.dart` into a friendly `AppFailure`. `AuthRepository` also cross-checks Firebase Auth sign-in against the `admins` collection — a valid Firebase login that isn't a provisioned admin is treated as logged out.

**State management** (`presentation/providers/`):
- `repository_providers.dart` — one provider per repository.
- `data_providers.dart` — `StreamProvider`s screens actually watch: `buildingsProvider`, `locationsProvider`, `announcementsProvider` (active, newest-first), `adminAuthStateProvider`, plus `locationSearchProvider` (a `Provider.family<String>` that filters the live location list client-side as the person types).

**Error/loading/empty handling**: `core/widgets/async_value_widget.dart` renders any `AsyncValue` through the existing `LoadingIndicator` / `ErrorStateWidget` / `EmptyStateWidget`, so every Firestore-backed screen handles "no internet", "empty collection", and "permission denied" the same way without repeating `.when(...)` boilerplate.

**Screens rewired to live data**: Home (buildings + locations for the three selectors), Search (live filtering), Announcements (newest-first stream), Admin Login (real sign-in with friendly error messages), Admin Dashboard (real sign-out + shows the signed-in admin's email).

**Security**: `firestore.rules` documents the assumed model — open reads, writes restricted to `request.auth.uid` existing in `admins/`, and the `admins` collection itself is never client-writable. `core/routing/app_router.dart` enforces the client side of this: `/admin/dashboard` redirects to `/admin/login` unless `adminAuthStateProvider` resolves to a signed-in admin, and re-checks automatically on sign-out via `GoRouterRefreshStream`.

**Still placeholder by design**: Firestore collections are empty (no hospital data seeded), and Route screen still shows mock walking steps — the routing engine is Prompt #4.

---

## Prompt #4 — Navigation & routing engine

**Graph architecture** (`domain/routing/`, pure Dart, no Firebase):
- `location_graph.dart` — `LocationGraph` treats every `Location` as a node and every `Connection` as an edge (`GraphEdge`). Inactive locations/connections are excluded; bidirectional connections add an edge in both directions; broken references (a connection pointing at a location that doesn't exist) are skipped rather than crashing.
- Edge weight = `distanceMeters` when available, else derived from `estimatedSeconds`, else a small positive fallback.
- `shortestPath()` implements **Dijkstra's algorithm** as a classic O(V²) array-scan (no priority queue/heap) — deliberately simple, and plenty fast for a single building's location count (see the method's doc comment for the scale reasoning and the upgrade path if it's ever needed).

**Step generation** (`route_step_generator.dart`): converts each traveled `Connection` into a `RouteStep` with a natural-language instruction. An admin-authored `Connection.instruction` always wins; otherwise it's built from generic templates driven by `directionPriority` / `floorChange` / `stairType` / `landmark` / `distanceMeters` — nothing hospital-specific is hardcoded.

**Route output**: `RouteResult` (`domain/entities/route_result.dart`) carries ordered locations, ordered `RouteStep`s, total distance, estimated walking time, floor-change count, starting/destination floor, and visited location ids — everything Prompt #4 asked the model to include.

**Firestore integration**: `Connection` and `Location` entities gained the new fields Prompt #4 specifies (`estimatedSeconds`, `landmark`, `stairType`, `floorChange`, `directionPriority`, `isActive`, `searchKeywords`, `buildingId`), read/written via the same `fromFirestore`/`toFirestore` pattern from Prompt #3. `RoutingService` (`data/services/routing_service.dart`) subscribes once to `LocationRepository.watchLocations()` / `ConnectionRepository.watchConnections()`, keeps the latest snapshot of each in memory, and only rebuilds the graph (in-memory, no network call) when either stream emits — `calculateRoute()` reuses the cached graph otherwise.

**Riverpod integration**: `presentation/providers/routing_providers.dart` exposes `routingServiceProvider` and a `RouteController` (`AsyncNotifier<RouteResult?>`) with a single public method, `calculateRoute()`. The UI (`RouteScreen`) only ever calls `ref.read(routeControllerProvider.notifier).calculateRoute(...)` and watches `ref.watch(routeControllerProvider)` for loading/error/data via the existing `AsyncValueWidget` — it never touches graph logic directly.

**Error handling**: `AppFailure` gained `sameLocation()`, `locationNotFound()`, `noRouteFound()`, and `emptyGraph()` factories, each with a friendly message, covering every case Prompt #4 listed (same source/destination, missing location, broken/empty graph, no path, plus the existing no-internet/permission-denied handling from Prompt #3).

**Testing** (`test/domain/routing/`): since `LocationGraph` and `RouteStepGenerator` have zero Firebase dependency, they're tested directly with plain Dart objects — no mocking required. Covers: shortest-vs-fewest-hops correctness, same-location, no-path (disconnected graph), invalid/missing node, floor-change detection, empty-graph construction, instruction generation (authored vs. auto-generated, floor-change phrasing, destination phrasing), and a 500-node chain-graph timing sanity check. Run with `flutter test`.

**UI**: `RouteScreen`'s layout is untouched from Prompt #2/#3 (same hero summary card, same connected step timeline) — it now renders a real `RouteResult` instead of mock data. `HomeScreen` now passes the selected `Location` objects (not just display strings) through `RouteSelection` so `RouteScreen` has real ids to route between.


