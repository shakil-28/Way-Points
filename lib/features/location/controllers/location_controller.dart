import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/config/app_config.dart';
import '../../../core/services/location_service.dart';
import '../../../core/utils/geoutils.dart';
import '../models/location_state.dart';

/// Manages real GPS coordinates, native OS course heading & movement bearing calculation
class LocationController extends ChangeNotifier {
  LocationState _state = const LocationState(
    latitude: AppConfig.defaultLatitude,
    longitude: AppConfig.defaultLongitude,
    speedKmh: 0.0,
    heading: 0.0,
    isTracking: false,
    hasRealGpsFix: false,
    permissionStatus: LocationPermissionStatus.granted,
  );

  StreamSubscription<Position>? _positionSubscription;
  double _prevLat = 0.0;
  double _prevLng = 0.0;

  LocationState get state => _state;
  bool get isGranted => _state.permissionStatus == LocationPermissionStatus.granted;
  bool get isLocationUpdated => _state.hasRealGpsFix;

  LocationController() {
    init();
  }

  /// Initialize location on startup and start live position stream
  Future<void> init() async {
    await fetchLocation();
    startTracking();
  }

  /// Request location permission
  Future<LocationPermission> requestPermission() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      
      if (permission == LocationPermission.denied) {
        _state = _state.copyWith(permissionStatus: LocationPermissionStatus.denied);
        notifyListeners();
        return permission;
      }
      
      if (permission == LocationPermission.deniedForever) {
        _state = _state.copyWith(permissionStatus: LocationPermissionStatus.restricted);
        notifyListeners();
        return permission;
      }
      
      _state = _state.copyWith(permissionStatus: LocationPermissionStatus.granted);
      notifyListeners();
      
      await fetchLocation();
      startTracking();
      return permission;
    } catch (e) {
      debugPrint('Permission error: $e');
      return LocationPermission.denied;
    }
  }

  /// Fetch location fix and update state
  Future<void> fetchLocation() async {
    final position = await LocationService.getCurrentLocation();
    if (position != null) {
      double headingVal = position.heading;

      if (headingVal <= 0.0 && _prevLat != 0.0 && _prevLng != 0.0) {
        final distKm = GeoUtils.haversineDistanceKm(
          lat1: _prevLat,
          lon1: _prevLng,
          lat2: position.latitude,
          lon2: position.longitude,
        );
        if (distKm > 0.001) {
          headingVal = GeoUtils.calculateBearingDegrees(
            lat1: _prevLat,
            lon1: _prevLng,
            lat2: position.latitude,
            lon2: position.longitude,
          );
        } else {
          headingVal = _state.heading;
        }
      }

      _prevLat = position.latitude;
      _prevLng = position.longitude;

      _state = _state.copyWith(
        latitude: position.latitude,
        longitude: position.longitude,
        speedKmh: position.speed * 3.6, // Convert m/s to km/h
        heading: headingVal >= 0.0 ? headingVal : _state.heading,
        hasRealGpsFix: true,
        permissionStatus: LocationPermissionStatus.granted,
      );
      notifyListeners();
    }
  }

  /// Start tracking live location stream using native OS heading & movement course vector
  void startTracking() {
    _positionSubscription?.cancel();
    _positionSubscription = LocationService.getPositionStream().listen(
      (position) {
        final speedKmh = position.speed * 3.6;
        double headingVal = position.heading;

        // If native OS heading is unavailable (<= 0), compute movement bearing
        if (headingVal <= 0.0 && _prevLat != 0.0 && _prevLng != 0.0) {
          final distKm = GeoUtils.haversineDistanceKm(
            lat1: _prevLat,
            lon1: _prevLng,
            lat2: position.latitude,
            lon2: position.longitude,
          );

          if (distKm > 0.001) {
            headingVal = GeoUtils.calculateBearingDegrees(
              lat1: _prevLat,
              lon1: _prevLng,
              lat2: position.latitude,
              lon2: position.longitude,
            );
          } else {
            headingVal = _state.heading;
          }
        }

        _prevLat = position.latitude;
        _prevLng = position.longitude;

        _state = _state.copyWith(
          latitude: position.latitude,
          longitude: position.longitude,
          speedKmh: speedKmh,
          heading: headingVal >= 0.0 ? headingVal : _state.heading,
          isTracking: true,
          hasRealGpsFix: true,
          permissionStatus: LocationPermissionStatus.granted,
        );
        notifyListeners();
      },
      onError: (error) {
        debugPrint('Location stream error: $error');
      },
    );
  }

  /// Refresh location on demand
  Future<void> refreshLocation() async {
    await fetchLocation();
  }

  /// Stop tracking location stream
  void stopTracking() {
    _positionSubscription?.cancel();
    _state = _state.copyWith(isTracking: false);
    notifyListeners();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
  }
}
