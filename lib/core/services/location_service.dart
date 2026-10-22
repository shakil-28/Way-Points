import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

/// Service for handling real GPS location requests and live position streams
class LocationService {
  /// Get current single location fix with fallback for iOS/Android simulators
  static Future<Position?> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Location services are disabled');
        return null;
      }

      // Check permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('Location permission denied');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('Location permission denied forever');
        return null;
      }

      // Attempt single position fix with 5-second timeout for simulator responsiveness
      try {
        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 5),
          ),
        );
        debugPrint('Location acquired: ${position.latitude}, ${position.longitude}');
        return position;
      } on TimeoutException {
        // Fallback to last known location if fix times out on simulator
        final lastKnown = await Geolocator.getLastKnownPosition();
        if (lastKnown != null) {
          debugPrint('Last known location acquired: ${lastKnown.latitude}, ${lastKnown.longitude}');
          return lastKnown;
        }
        debugPrint('Location fix timed out on simulator');
        return null;
      }
    } catch (e) {
      debugPrint('Location error: $e');
      return null;
    }
  }

  /// Stream live GPS location updates
  static Stream<Position> getPositionStream({
    int distanceFilter = 5,
  }) {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: distanceFilter,
      ),
    );
  }

  /// Check if location service is available
  static Future<bool> isLocationAvailable() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (e) {
      return false;
    }
  }
}
