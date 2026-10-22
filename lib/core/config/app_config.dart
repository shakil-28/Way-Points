/// Application configuration and regional parameters for WayPoint Navigation.
class AppConfig {
  static const String appName = 'WayPoint';
  static const String appTagline = 'Bengal Scenic Navigation';
  static const String defaultRegion = 'Dhaka & Greater Bengal';

  // Default regional coordinates (Dhaka Center)
  static const double defaultLatitude = 23.8103;
  static const double defaultLongitude = 90.4125;
  static const double defaultZoom = 13.5;

  /// Parameterized Google Maps API key passed via compile-time --dart-define=MAPS_API_KEY=YOUR_KEY
  static String get googleMapsApiKey {
    return const String.fromEnvironment(
      'MAPS_API_KEY',
      defaultValue: 'YOUR_MAPS_API_KEY',
    );
  }

  static const double defaultSpeedKmh = 0.0;
  static const int gpsTelemetryIntervalMs = 1000;
}
