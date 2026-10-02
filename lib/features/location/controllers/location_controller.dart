import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../core/config/app_config.dart';
import '../models/location_state.dart';

/// Manages GPS coordinates, movement simulation, and permission events
class LocationController extends ChangeNotifier {
  LocationState _state = const LocationState(
    latitude: AppConfig.defaultLatitude,
    longitude: AppConfig.defaultLongitude,
    speedKmh: AppConfig.defaultSpeedKmh,
    heading: 142.0,
    isTracking: true,
    permissionStatus: LocationPermissionStatus.granted,
  );

  Timer? _telemetryTimer;

  LocationState get state => _state;
  bool get isGranted => _state.permissionStatus == LocationPermissionStatus.granted;

  LocationController() {
    startLocationTelemetry();
  }

  void requestPermission() {
    _state = _state.copyWith(permissionStatus: LocationPermissionStatus.granted);
    startLocationTelemetry();
    notifyListeners();
  }

  void startLocationTelemetry() {
    _telemetryTimer?.cancel();
    _state = _state.copyWith(isTracking: true);
    notifyListeners();

    // Subtle drift simulation along Dhaka corridor for live telemetry HUD
    _telemetryTimer = Timer.periodic(
      const Duration(milliseconds: AppConfig.gpsTelemetryIntervalMs),
          (timer) {
        if (!_state.isTracking) return;
        final latDelta = (DateTime.now().millisecond % 5 - 2) * 0.00003;
        final lonDelta = (DateTime.now().second % 5 - 2) * 0.00003;

        _state = _state.copyWith(
          latitude: _state.latitude + latDelta,
          longitude: _state.longitude + lonDelta,
          speedKmh: 45.0 + (DateTime.now().second % 8),
          heading: (_state.heading + 0.5) % 360,
        );
        notifyListeners();
      },
    );
  }

  void stopLocationTelemetry() {
    _telemetryTimer?.cancel();
    _state = _state.copyWith(isTracking: false, speedKmh: 0.0);
    notifyListeners();
  }

  void setCoordinates(double lat, double lon) {
    _state = _state.copyWith(latitude: lat, longitude: lon);
    notifyListeners();
  }

  @override
  void dispose() {
    _telemetryTimer?.cancel();
    super.dispose();
  }
}
