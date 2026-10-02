/// Application configuration and regional parameters for WayPoint Navigation.
class AppConfig {
  static const String appName = 'WayPoint';
  static const String appTagline = 'Bengal Scenic Navigation';
  static const String defaultRegion = 'Dhaka & Greater Bengal';

  // Default regional coordinates (Dhaka Center)
  static const double defaultLatitude = 23.8103;
  static const double defaultLongitude = 90.4125;
  static const double defaultZoom = 13.5;

  // Google Maps / Routing API configuration (Set via environment or runtime)
  static const String googleMapsApiKey = String.fromEnvironment(
    'MAPS_API_KEY',
    defaultValue: 'DEMO_MAPS_KEY_BENGAL',
  );

  // Speed limits & simulation defaults
  static const double defaultSpeedKmh = 48.0;
  static const int gpsTelemetryIntervalMs = 1000;
}
