# PawPawLand iOS

SwiftUI frontend for PawPawLand — a gamified dog park exploration app.

## Requirements

- Xcode 16+
- iOS 17.0+
- NestJS backend running at `http://localhost:3000` (see repo `backend/`)

## Open the project

```bash
cd ios
open PawPawLand.xcodeproj
```

Select an iPhone simulator and press **Run** (⌘R).

## Backend integration

The app is wired to the NestJS `dog-parks` API:

| Step | Endpoint | When |
|------|----------|------|
| 1 | `POST /dog-parks/import?lat=&lng=&radiusMiles=15` | On explore load / refresh — seeds OSM data for user's area |
| 2 | `GET /dog-parks/nearby?lat=&lng=&radiusMiles=15` | Immediately after import — parks for map pins |

Flow on launch:

1. Request GPS permission
2. Read device location
3. Import + fetch nearby parks via `DogParkAPI.syncAndFetchNearby`
4. Center map on user and show paw pins

### API base URL

Configured in `Info.plist` → `API_BASE_URL` (default `http://localhost:3000`).

- **Simulator:** `localhost` works
- **Physical device:** change to your Mac's LAN IP, e.g. `http://192.168.1.42:3000`

### Run backend + database

```bash
# Terminal 1 — database
docker compose up -d

# Terminal 2 — API
cd backend
npm run start:dev
```

## Architecture

```
PawPawLand/
├── App/              Entry point
├── Theme/            Colors, typography
├── Models/           DogPark, CheckIn, Badge
├── Services/
│   ├── AppState.swift        @Observable global state
│   ├── DogParkAPI.swift      NestJS client (import + nearby)
│   ├── LocationManager.swift GPS + reverse geocoding
│   └── MockData.swift        Preview data + peak-time charts
└── Views/            SwiftUI screens
```

- **State:** `AppState` is injected via `@Environment`
- **Map data:** Live from API via GPS — not hardcoded LA mock parks
- **Gamification:** Check-ins, badges, fog-of-war remain local (no backend yet)

## MVP features

| Feature | Screen |
|---------|--------|
| Explore Map | `ExploreMapView` — GPS-centered map, live API pins |
| Map Unlocking | `FogOfWarOverlay` |
| Check In | `CheckInView` |
| Adventure Journal | `AdventureJournalView` |
| Achievements | `ProfileView`, `NewParkUnlockedView` |
| Park Detail | `ParkDetailView` — hours, phone, website from OSM |

## Notes

- Set your **Development Team** in Xcode before running on a physical device.
- `NSAllowsLocalNetworking` is enabled for local HTTP during development.
- Peak-times chart still uses `MockData` — no backend endpoint yet.
