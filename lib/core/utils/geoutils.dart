import 'dart:math' as math;

/// Geographic calculations and spatial utilities for navigation corridors.
class GeoUtils {
  static const double earthRadiusKm = 6371.0;

  /// Haversine formula to compute great-circle distance between two coordinates in kilometers.
  static double haversineDistanceKm({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) {
    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) *
            math.cos(_degreesToRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  /// Calculates perpendicular distance (cross-track distance) from a point to a route line segment.
  static double pointToLineDistanceKm({
    required double pLat,
    required double pLon,
    required double lineStartLat,
    required double lineStartLon,
    required double lineEndLat,
    required double lineEndLon,
  }) {
    final d13 = haversineDistanceKm(lat1: lineStartLat, lon1: lineStartLon, lat2: pLat, lon2: pLon);
    final bearing13 = _bearing(lineStartLat, lineStartLon, pLat, pLon);
    final bearing12 = _bearing(lineStartLat, lineStartLon, lineEndLat, lineEndLon);

    final dXt = math.asin(math.sin(d13 / earthRadiusKm) * math.sin(bearing13 - bearing12)) * earthRadiusKm;
    return dXt.abs();
  }

  /// Bearing in radians between two points
  static double _bearing(double lat1, double lon1, double lat2, double lon2) {
    final phi1 = _degreesToRadians(lat1);
    final phi2 = _degreesToRadians(lat2);
    final deltaLambda = _degreesToRadians(lon2 - lon1);

    final y = math.sin(deltaLambda) * math.cos(phi2);
    final x = math.cos(phi1) * math.sin(phi2) -
        math.sin(phi1) * math.cos(phi2) * math.cos(deltaLambda);

    return math.atan2(y, x);
  }

  static double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180.0);
  }

  /// Formats distance nicely (e.g. "850 m" or "14.2 km")
  static String formatDistance(double distanceKm) {
    if (distanceKm < 1.0) {
      final meters = (distanceKm * 1000).round();
      return '$meters m';
    }
    return '${distanceKm.toStringAsFixed(1)} km';
  }
}
