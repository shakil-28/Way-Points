enum LocationPermissionStatus {
  notDetermined,
  granted,
  denied,
  restricted,
}

/// Represents the real-time GPS state and sensor telemetry
class LocationState {
  final double latitude;
  final double longitude;
  final double heading;
  final double speedKmh;
  final double accuracyMeters;
  final bool isTracking;
  final LocationPermissionStatus permissionStatus;
  final String? activeCorridor;

  const LocationState({
    required this.latitude,
    required this.longitude,
    this.heading = 0.0,
    this.speedKmh = 0.0,
    this.accuracyMeters = 5.0,
    this.isTracking = false,
    this.permissionStatus = LocationPermissionStatus.granted,
    this.activeCorridor = 'N1 Highway / Dhaka-Chattogram Express',
  });

  LocationState copyWith({
    double? latitude,
    double? longitude,
    double? heading,
    double? speedKmh,
    double? accuracyMeters,
    bool? isTracking,
    LocationPermissionStatus? permissionStatus,
    String? activeCorridor,
  }) {
    return LocationState(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      heading: heading ?? this.heading,
      speedKmh: speedKmh ?? this.speedKmh,
      accuracyMeters: accuracyMeters ?? this.accuracyMeters,
      isTracking: isTracking ?? this.isTracking,
      permissionStatus: permissionStatus ?? this.permissionStatus,
      activeCorridor: activeCorridor ?? this.activeCorridor,
    );
  }
}
