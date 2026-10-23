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

  /// Computes the shortest cross-track distance in kilometers from a GPS location to any segment of a route polyline.
  static double minDistanceToPolylineKm({
    required double lat,
    required double lng,
    required List<Map<String, double>> polyline,
  }) {
    if (polyline.length < 2) return 0.0;

    double minDistance = double.infinity;

    for (int i = 0; i < polyline.length - 1; i++) {
      final start = polyline[i];
      final end = polyline[i + 1];

      final dist = pointToLineDistanceKm(
        pLat: lat,
        pLon: lng,
        lineStartLat: start['lat'] ?? 0.0,
        lineStartLon: start['lng'] ?? 0.0,
        lineEndLat: end['lat'] ?? 0.0,
        lineEndLon: end['lng'] ?? 0.0,
      );

      if (dist < minDistance) {
        minDistance = dist;
      }
    }

    return minDistance == double.infinity ? 0.0 : minDistance;
  }

  /// Returns true if the GPS position is off-route beyond thresholdKm (default 100 meters / 0.1 km)
  static bool isOffRoute({
    required double lat,
    required double lng,
    required List<Map<String, double>> polyline,
    double thresholdKm = 0.1,
  }) {
    if (polyline.length < 2) return false;
    final dist = minDistanceToPolylineKm(lat: lat, lng: lng, polyline: polyline);
    return dist > thresholdKm;
  }

  /// True bearing in degrees (0° to 360°) between two coordinates
  static double calculateBearingDegrees({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) {
    final phi1 = _degreesToRadians(lat1);
    final phi2 = _degreesToRadians(lat2);
    final deltaLambda = _degreesToRadians(lon2 - lon1);

    final y = math.sin(deltaLambda) * math.cos(phi2);
    final x = math.cos(phi1) * math.sin(phi2) -
        math.sin(phi1) * math.cos(phi2) * math.cos(deltaLambda);

    final radians = math.atan2(y, x);
    final degrees = radians * (180.0 / math.pi);
    return (degrees + 360.0) % 360.0;
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
