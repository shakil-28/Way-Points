/// Application configuration and regional parameters for WayPoint Navigation.
class AppConfig {
  static const String appName = 'WayPoint';
  static const String appTagline = 'Bengal Scenic Navigation';
  static const String defaultRegion = 'Dhaka & Greater Bengal';

  // Default regional coordinates (Dhaka Center)
  static const double defaultLatitude = 23.8103;
  static const double defaultLongitude = 90.4125;
  static const double defaultZoom = 13.5;

  static const String _activeApiKey = 'AIzaSyCnPh6dFHh8Pn4obz3pTEQhVES8bUKd-uo';

  /// Dynamically returns the Google Maps API key passed via --dart-define=MAPS_API_KEY=YOUR_KEY or default active key
  static String get googleMapsApiKey {
    const envKey = String.fromEnvironment('MAPS_API_KEY');
    if (envKey.isNotEmpty && envKey != 'YOUR_MAPS_API_KEY') return envKey;
    return _activeApiKey;
  }

  static const double defaultSpeedKmh = 0.0;
  static const int gpsTelemetryIntervalMs = 1000;
}
