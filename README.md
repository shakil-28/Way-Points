# 📍 WayPoint — Bengal Scenic Navigation

[![Flutter](https://img.shields.io/badge/Flutter-3.22+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.4+-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Material 3](https://img.shields.io/badge/Design-Material_3-025939)](https://m3.material.io)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

WayPoint is a high-performance, mobile frontend navigation application built with Flutter. Designed specifically for scenic highway corridors across Dhaka and Greater Bengal, WayPoint combines turn-by-turn navigation, heritage corridor discovery, and travel analytics into a unified map experience.

---

## ✨ Key Features

- 🗺️ **Unified Map Hub:**
  Single full-screen interactive vector map (`MapScreenMode.explore`, `routePreview`, `navigation`) with auto-panning live GPS recenter and custom 64x64 Bengal Emerald heading marker.

- 🚗 **Turn-by-Turn Navigation HUD:**
  Compact, non-clipping maneuver card displaying upcoming turn direction chevrons, street instructions, speed readout (`km/h` vs `mph`), and speed limit indicators.

- 🏰 **Adaptive Corridor Pitstops Dashboard:**
  Draggable bottom sheet (`NavigationBottomSheet`) with adaptive UI across snap sizes:
  - **`0.25` Snap Size:** Compact POI summary pill.
  - **`0.50` Snap Size:** Swipable horizontal `PageView` card carousel.
  - **`0.80` Snap Size:** Full landmark details view featuring operating hours, entry fee, parking status, heritage history narratives, and trip metrics.

- 📊 **Expedition Analytics:**
  Custom bar and donut charts rendering fuel efficiency, distance covered, and past trip replay history.

- 🔐 **Authentication & Driver Profile Setup:**
  Step 1 Sign-In/Registration and Step 2 Complete Driver Profile with vehicle type customization and speed measurement unit preferences.

---

## 🎨 Design System Tokens

- **Brand Primary:** Deep Bengal Emerald (`#025939`)
- **Accent Neon:** Cyber Neon Green (`#00FF87`)
- **Dark Canvas:** Obsidian Surface (`#141315`)
- **Design Tokens:** `AppTheme`, `AppColors`, `Spacing`, `AppStrings`

---

## 🏗️ Project Architecture

```text
lib/
├── app/                  # Application root & MultiProvider setup
├── core/
│   ├── config/           # AppConfig, AppRoutes
│   ├── constants/        # AppColors, Spacing, AppStrings
│   ├── services/         # LocationService, RoutesService, PlacesService
│   ├── theme/            # AppTheme (Light & Dark Material 3)
│   └── widgets/          # CircularFloatingButton, ContextHeader, WayPointLogo
├── features/
│   ├── auth/             # LoginScreen, SignUpScreen, ProfileSetupScreen
│   ├── discovery/        # PoiDetailsSheet, PoiDetailsScreen, DiscoveryController
│   ├── history/          # HistoryScreen, CustomPainter Analytics
│   ├── location/         # LocationController, LocationPermissionView
│   ├── main/             # MainScreen & Floating Bottom Navigation Capsule
│   ├── map/              # MapScreen, MapView, MapController
│   ├── navigation/       # ActiveNavigationScreen, NavigationManeuverCard, SpeedHUD, POIBadge
│   ├── routing/          # RoutePreviewScreen, RoutePreviewView
│   ├── search/           # SearchScreen, SearchView, PlaceSearchController
│   └── settings/         # SettingsScreen, SettingsController
├── routes/               # GoRouter configuration
└── main.dart             # Application entry point
```

---

## 🚀 Getting Started & Build Guide

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.22 or higher)
- Android Studio / Xcode
- Google Cloud Console API Keys with **Maps SDK for Android/iOS**, **Places API (New)**, and **Routes API** enabled.

### 🔑 Parameterizing API Keys

#### 1. Android Configuration
Add your Android Maps API Key to `android/local.properties`:

```properties
MAPS_API_KEY=YOUR_ANDROID_GOOGLE_MAPS_API_KEY
```

#### 2. Flutter / Dart Compile-time Define
Pass your Google Maps API Key at build or run time using `--dart-define`:

```bash
flutter run --dart-define=MAPS_API_KEY=YOUR_GOOGLE_MAPS_API_KEY
```

### 📦 Installation

```bash
# 1. Clone repository
git clone https://github.com/your-username/way_point.git
cd way_point

# 2. Install dependencies
flutter pub get

# 3. Run application
flutter run
```

---

## 🧪 Testing & Verification

```bash
# Run static analysis
flutter analyze

# Run unit and widget tests
flutter test
```

---

## 📄 License
This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.
