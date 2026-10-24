import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import '../../core/config/app_config.dart';

/// Routes Service - Route calculation, direction decoding, and optimization
class RoutesService {
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api';
  static final String _apiKey = AppConfig.googleMapsApiKey;

  /// Decodes Google Directions API overview_polyline points into LatLng list for Google Maps rendering
  static List<LatLng> decodePolylinePoints(String encodedPolyline) {
    if (encodedPolyline.isEmpty) return [];
    try {
      PolylinePoints polylinePoints = PolylinePoints();
      List<PointLatLng> result = polylinePoints.decodePolyline(encodedPolyline);
      return result.map((p) => LatLng(p.latitude, p.longitude)).toList();
    } catch (e) {
      debugPrint('Error decoding polyline: $e');
      return [];
    }
  }

  /// Get directions between two points
  static Future<Map<String, dynamic>?> getDirections({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
    String mode = 'driving',
    bool avoidTolls = false,
    bool avoidHighways = false,
    List<String>? waypoints,
  }) async {
    try {
      String url = '$_baseUrl/directions/json?origin=$originLat,$originLng'
          '&destination=$destLat,$destLng'
          '&mode=$mode'
          '&key=$_apiKey';

      if (avoidTolls && avoidHighways) {
        url += '&avoid=tolls|highways';
      } else if (avoidTolls) {
        url += '&avoid=tolls';
      } else if (avoidHighways) {
        url += '&avoid=highways';
      }

      if (waypoints != null && waypoints.isNotEmpty) {
        final waypointStr = waypoints.join('|');
        url += '&waypoints=$waypointStr';
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['status'] == 'OK' && (data['routes'] as List).isNotEmpty) {
          final route = data['routes'][0] as Map<String, dynamic>;
          final legs = route['legs'] as List;
          
          // Decode polyline
          final overviewPolyline = route['overview_polyline']?['points'] as String?;
          final path = _decodePolyline(overviewPolyline ?? '');

          // Calculate totals safely
          int totalDistance = 0;
          int totalDuration = 0;
          for (var leg in legs) {
            totalDistance += ((leg['distance']?['value'] ?? 0) as num).toInt();
            totalDuration += ((leg['duration']?['value'] ?? 0) as num).toInt();
          }

          return {
            'distanceText': legs.first['distance']?['text'] ?? '',
            'distanceMeters': totalDistance,
            'durationText': legs.first['duration']?['text'] ?? '',
            'durationSeconds': totalDuration,
            'durationInTraffic': legs.first['duration_in_traffic']?['text'],
            'startAddress': legs.first['start_address'] ?? '',
            'endAddress': legs.first['end_address'] ?? '',
            'polyline': overviewPolyline ?? '',
            'path': path,
            'bounds': route['bounds'],
            'summary': route['summary'] ?? '',
            'warnings': route['warnings'] ?? [],
            'legs': legs.map((leg) => {
              'distanceText': leg['distance']?['text'] ?? '',
              'distanceMeters': ((leg['distance']?['value'] ?? 0) as num).toInt(),
              'durationText': leg['duration']?['text'] ?? '',
              'durationSeconds': ((leg['duration']?['value'] ?? 0) as num).toInt(),
              'startAddress': leg['start_address'] ?? '',
              'endAddress': leg['end_address'] ?? '',
              'steps': (leg['steps'] as List?)?.map((step) => {
                'instruction': step['html_instructions'] ?? step['instructions'] ?? '',
                'distanceText': step['distance']?['text'] ?? '',
                'distanceMeters': ((step['distance']?['value'] ?? 0) as num).toInt(),
                'durationText': step['duration']?['text'] ?? '',
                'durationSeconds': ((step['duration']?['value'] ?? 0) as num).toInt(),
              }).toList() ?? [],
            }).toList(),
          };
        }
      }
    } catch (e) {
      debugPrint('Directions error: $e');
    }
    return null;
  }

  /// Get distance matrix between multiple origins and destinations
  static Future<List<List<Map<String, dynamic>>>> distanceMatrix({
    required List<Map<String, double>> origins,
    required List<Map<String, double>> destinations,
    String mode = 'driving',
    bool avoidTolls = false,
    bool avoidHighways = false,
  }) async {
    try {
      final originStr = origins.map((o) => '${o['lat']},${o['lng']}').join('|');
      final destStr = destinations.map((d) => '${d['lat']},${d['lng']}').join('|');

      String url = '$_baseUrl/distancematrix/json?origins=$originStr&destinations=$destStr&mode=$mode&key=$_apiKey';

      if (avoidTolls && avoidHighways) {
        url += '&avoid=tolls|highways';
      } else if (avoidTolls) {
        url += '&avoid=tolls';
      } else if (avoidHighways) {
        url += '&avoid=highways';
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['status'] == 'OK') {
          return (data['rows'] as List).map((row) =>
            (row['elements'] as List).map((element) => {
              'distanceText': element['distance']?['text'] ?? '',
              'distanceMeters': ((element['distance']?['value'] ?? 0) as num).toInt(),
              'durationText': element['duration']?['text'] ?? '',
              'durationSeconds': ((element['duration']?['value'] ?? 0) as num).toInt(),
              'status': element['status'] ?? '',
            }).toList()
          ).toList();
        }
      }
    } catch (e) {
      debugPrint('Distance matrix error: $e');
    }
    return [];
  }

  /// Optimize waypoints for a route (Traveling Salesman approximation)
  static Future<Map<String, dynamic>?> optimizeWaypoints({
    required List<Map<String, double>> waypoints,
    double? originLat,
    double? originLng,
    double? destLat,
    double? destLng,
  }) async {
    try {
      final String? origin = originLat != null && originLng != null 
          ? '$originLat,$originLng' 
          : null;
      final String? destination = destLat != null && destLng != null
          ? '$destLat,$destLng'
          : null;

      final waypointStr = waypoints.isEmpty ? '' : waypoints.map((wp) => 
        '${wp['lat']},${wp['lng']}'
      ).join('|');

      String url = '$_baseUrl/directions/json?';
      if (origin != null) {
        url += 'origin=$origin&';
      }
      if (destination != null) {
        url += 'destination=$destination&';
      }
      if (waypointStr.isNotEmpty) {
        url += 'waypoints=optimize:true|$waypointStr&';
      }
      url += 'mode=driving&key=$_apiKey';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['status'] == 'OK' && (data['routes'] as List).isNotEmpty) {
          final route = data['routes'][0] as Map<String, dynamic>;
          final legs = route['legs'] as List?;
          return {
            'optimizedWaypointOrder': route['waypoint_order'] ?? [],
            'distanceText': legs?.first['distance']?['text'] ?? '',
            'distanceMeters': ((legs?.first['distance']?['value'] ?? 0) as num).toInt(),
            'durationText': legs?.first['duration']?['text'] ?? '',
            'durationSeconds': ((legs?.first['duration']?['value'] ?? 0) as num).toInt(),
          };
        }
      }
    } catch (e) {
      debugPrint('Optimize waypoints error: $e');
    }
    return null;
  }

  /// Decode Google polyline encoding string to list of lat/lng coordinates
  static List<Map<String, double>> _decodePolyline(String encoded) {
    final points = <Map<String, double>>[];
    if (encoded.isEmpty) return points;

    var index = 0;
    final len = encoded.length;
    var lat = 0;
    var lng = 0;

    while (index < len) {
      int result = 0;
      int shift = 0;
      int byte;
      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1f) << shift;
        shift += 5;
      } while (byte >= 0x20);
      final dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      result = 0;
      shift = 0;
      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1f) << shift;
        shift += 5;
      } while (byte >= 0x20);
      final dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add({'lat': lat / 1E5, 'lng': lng / 1E5});
    }

    return points;
  }
}
