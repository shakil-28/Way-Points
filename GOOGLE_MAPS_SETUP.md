# Google Maps Integration Setup Guide

## APIs to Enable in Google Cloud Console

| API | Purpose | Use in Project |
|-----|---------|----------------|
| Maps SDK for Android | Display maps on Android | Future use |
| Maps SDK for iOS | Display maps on iOS | Future use |
| Places API (New) | Place search, autocomplete | ✅ Integrated |
| Routes API | Route optimization | ✅ Integrated (via Directions API) |
| Geocoding API | Address ↔ coordinates | ✅ Integrated |

---

## Step 1: Create Google Cloud Project

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Sign in with your Google account
3. Click **"Select a project"** → **"New Project"**
4. Name it: `way-point-app`
5. Click **"Create"**
6. Select the project from the dropdown

---

## Step 2: Enable APIs

Go to **APIs & Services** → **Library**

Search and enable these 5 APIs:

```
1. Maps SDK for Android
2. Maps SDK for iOS
3. Places API (New)
4. Routes API
5. Geocoding API
```

---

## Step 3: Create API Key

1. Go to **APIs & Services** → **Credentials**
2. Click **"+ CREATE CREDENTIALS"** → **"API key"**
3. Copy the generated key (looks like: `AIzaSyD-xxxxxxxxxxxxxxxxxxxxxxxx`)

### Restrict the API Key (Recommended)

Click **"Restrict key"**:

**Application Restrictions:**
- Android apps → Add package name and SHA-1
- OR HTTP referrers → Add your website

**API Restrictions:**
- Select **"Restrict key"**
- Check these APIs:
  - Maps SDK for Android
  - Maps SDK for iOS
  - Places API (New)
  - Routes API
  - Geocoding API

Click **"Save"**

---

## Step 4: Get SHA-1 Fingerprint (Android)

```bash
cd /Users/mdnurnabishakil/Desktop/way_point/android
./gradlew signingReport
```

Copy the **SHA1** value (looks like: `AA:BB:CC:...`)

---

## Step 5: Add API Key to Project

### A. Update app_config.dart

Replace `'DEMO_MAPS_KEY_BENGAL'` with your real API key:

```dart
// lib/core/config/app_config.dart
static const String googleMapsApiKey = String.fromEnvironment(
  'MAPS_API_KEY',
  defaultValue: 'YOUR_REAL_API_KEY_HERE',  // ← Replace this
);
```

### B. Update AndroidManifest.xml

Edit: `android/app/src/main/AndroidManifest.xml`

Add inside `<application>` tag:

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_API_KEY_HERE" />
```

### C. Update Info.plist (iOS)

Edit: `ios/Runner/Info.plist`

Add inside `<dict>` tag:

```xml
<key>GMSAPIKey</key>
<string>YOUR_API_KEY_HERE</string>
```

---

## Step 6: Run the App

```bash
flutter pub get
flutter run
```

---

## Service Files Created

| File | Purpose |
|------|---------|
| `lib/core/services/google_maps_service.dart` | Geocoding, Directions, Distance Matrix |
| `lib/core/services/places_service.dart` | Place search, Autocomplete, Details |
| `lib/core/services/routes_service.dart` | Route calculation, Waypoint optimization |

---

## Usage Examples

### Geocode Address
```dart
final coords = await GoogleMapsService.geocode('Dhaka, Bangladesh');
print('${coords!['lat']}, ${coords['lng']}');
```

### Search Places
```dart
final places = await PlacesService.search(query: 'restaurant', lat: 23.81, lng: 90.41);
```

### Get Directions
```dart
final route = await RoutesService.getDirections(
  originLat: 23.81, originLng: 90.41,
  destLat: 23.78, destLng: 90.37,
);
print(route!['distanceText']); // "5.2 km"
```

---

## Free Tier Limits (No Credit Card Needed)

| API | Free Quota |
|-----|------------|
| Maps SDK Android/iOS | $200/month credit (~100k+ loads) |
| Places API | 1,000 requests/day free |
| Geocoding API | 40,000 requests/month |
| Directions API | 40,000 requests/month |
| Routes API | 1,000 requests/day free |

**Your usage as a portfolio project:** ~0 cost

---

## Security Notes

- Never commit API keys to Git
- Use environment variables for production:
  ```bash
  flutter run --dart-define=MAPS_API_KEY=your_real_key
  ```
