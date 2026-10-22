import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/config/app_config.dart';
import '../../../core/services/location_service.dart';
import '../models/location_state.dart';

/// Manages real GPS coordinates and live position streaming
class LocationController extends ChangeNotifier {
  LocationState _state = const LocationState(
    latitude: AppConfig.defaultLatitude,
    longitude: AppConfig.defaultLongitude,
    speedKmh: 0.0,
    heading: 0.0,
    isTracking: false,
    permissionStatus: LocationPermissionStatus.granted,
  );

  StreamSubscription<Position>? _positionSubscription;

  LocationState get state => _state;
  bool get isGranted => _state.permissionStatus == LocationPermissionStatus.granted;
  bool get isLocationUpdated => 
      _state.latitude != AppConfig.defaultLatitude || 
      _state.longitude != AppConfig.defaultLongitude;

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
      _state = _state.copyWith(
        latitude: position.latitude,
        longitude: position.longitude,
        speedKmh: position.speed * 3.6, // Convert m/s to km/h
        heading: position.heading,
        permissionStatus: LocationPermissionStatus.granted,
      );
      notifyListeners();
    }
  }

  /// Start tracking live location stream
  void startTracking() {
    _positionSubscription?.cancel();
    _positionSubscription = LocationService.getPositionStream().listen(
      (position) {
        _state = _state.copyWith(
          latitude: position.latitude,
          longitude: position.longitude,
          speedKmh: position.speed * 3.6,
          heading: position.heading,
          isTracking: true,
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
