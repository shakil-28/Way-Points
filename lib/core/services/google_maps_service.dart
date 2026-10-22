import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../core/config/app_config.dart';

/// Google Maps Service - Handles all Google Maps API calls
class GoogleMapsService {
  static final String _apiKey = AppConfig.googleMapsApiKey;
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api';

  // ==================== GEOCODING ====================

  /// Convert address to coordinates
  static Future<Map<String, double>?> geocode(String address) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/geocode/json?address=${Uri.encodeComponent(address)}&key=$_apiKey',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['status'] == 'OK' && (data['results'] as List).isNotEmpty) {
          final result = data['results'][0]['geometry']['location'] as Map<String, dynamic>;
          return {
            'lat': (result['lat'] as num).toDouble(),
            'lng': (result['lng'] as num).toDouble(),
          };
        }
      }
    } catch (e) {
      debugPrint('Geocoding error: $e');
    }
    return null;
  }

  /// Convert coordinates to address (reverse geocoding)
  static Future<String?> reverseGeocode(double latitude, double longitude) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/geocode/json?latlng=$latitude,$longitude&key=$_apiKey',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['status'] == 'OK' && (data['results'] as List).isNotEmpty) {
          return data['results'][0]['formatted_address'] as String?;
        }
      }
    } catch (e) {
      debugPrint('Reverse geocoding error: $e');
    }
    return null;
  }

  // ==================== PLACES ====================

  /// Search for places by text query
  static Future<List<Map<String, dynamic>>> placeSearch(String query, {double? lat, double? lng, double? radius}) async {
    try {
      String url = '$_baseUrl/place/textsearch/json?query=${Uri.encodeComponent(query)}&key=$_apiKey';
      
      if (lat != null && lng != null) {
        url += '&location=$lat,$lng&radius=${radius ?? 50000}';
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['status'] == 'OK') {
          return (data['results'] as List).map((item) {
            final geometry = item['geometry']?['location'] as Map<String, dynamic>?;
            return {
              'placeId': item['place_id'],
              'name': item['name'],
              'formattedAddress': item['formatted_address'],
              'rating': item['rating']?.toString() ?? '0',
              'userRatingsTotal': item['user_ratings_total']?.toString() ?? '0',
              'latitude': geometry?['lat'],
              'longitude': geometry?['lng'],
            };
          }).toList();
        }
      }
    } catch (e) {
      debugPrint('Place search error: $e');
    }
    return [];
  }

  /// Autocomplete suggestions
  static Future<List<Map<String, dynamic>>> autocomplete(String query, {double? lat, double? lng, double? radius}) async {
    try {
      String url = '$_baseUrl/place/autocomplete/json?input=${Uri.encodeComponent(query)}&key=$_apiKey';
      
      if (lat != null && lng != null) {
        url += '&location=$lat,$lng&radius=${radius ?? 50000}';
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['status'] == 'OK') {
          return (data['predictions'] as List).map((item) => {
            'description': item['description'],
            'placeId': item['place_id'],
          }).toList();
        }
      }
    } catch (e) {
      debugPrint('Autocomplete error: $e');
    }
    return [];
  }

  /// Get place details
  static Future<Map<String, dynamic>?> placeDetails(String placeId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/place/details/json?place_id=$placeId&key=$_apiKey&fields=name,formatted_address,formatted_phone_number,rating,user_ratings_total,geometry,opening_hours'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['status'] == 'OK') {
          final result = data['result'] as Map<String, dynamic>;
          final geometry = result['geometry'] as Map<String, dynamic>?;
          return {
            'name': result['name'],
            'formattedAddress': result['formatted_address'],
            'formattedPhoneNumber': result['formatted_phone_number'],
            'rating': result['rating']?.toString() ?? '0',
            'userRatingsTotal': result['user_ratings_total']?.toString() ?? '0',
            'openNow': result['opening_hours']?['open_now'],
            'latitude': geometry?['location']?['lat'],
            'longitude': geometry?['location']?['lng'],
          };
        }
      }
    } catch (e) {
      debugPrint('Place details error: $e');
    }
    return null;
  }

  // ==================== DIRECTIONS ====================

  /// Get directions between two points
  static Future<Map<String, dynamic>?> getDirections({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
    String mode = 'driving',
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/directions/json?origin=$originLat,$originLng'
          '&destination=$destLat,$destLng'
          '&mode=$mode'
          '&key=$_apiKey',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['status'] == 'OK' && (data['routes'] as List).isNotEmpty) {
          final route = data['routes'][0] as Map<String, dynamic>;
          final leg = (route['legs'] as List)[0] as Map<String, dynamic>;
          final overviewPolyline = route['overview_polyline']?['points'] as String?;
          
          return {
            'distanceText': leg['distance']?['text'] ?? '',
            'distanceMeters': leg['distance']?['value'] ?? 0,
            'durationText': leg['duration']?['text'] ?? '',
            'durationSeconds': leg['duration']?['value'] ?? 0,
            'startAddress': leg['start_address'] ?? '',
            'endAddress': leg['end_address'] ?? '',
            'polyline': overviewPolyline ?? '',
            'bounds': route['bounds'],
          };
        }
      }
    } catch (e) {
      debugPrint('Directions error: $e');
    }
    return null;
  }

  // ==================== DISTANCE MATRIX ====================

  /// Get distance matrix between multiple points
  static Future<List<List<Map<String, dynamic>>>> distanceMatrix({
    required List<Map<String, double>> origins,
    required List<Map<String, double>> destinations,
    String mode = 'driving',
  }) async {
    try {
      final originStr = origins.map((o) => '${o['lat']},${o['lng']}').join('|');
      final destStr = destinations.map((d) => '${d['lat']},${d['lng']}').join('|');

      final response = await http.get(
        Uri.parse(
          '$_baseUrl/distancematrix/json?origins=$originStr'
          '&destinations=$destStr'
          '&mode=$mode'
          '&key=$_apiKey',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['status'] == 'OK') {
          return (data['rows'] as List).map((row) =>
            (row['elements'] as List).map((element) => {
              'distanceText': element['distance']?['text'] ?? '',
              'distanceMeters': element['distance']?['value'] ?? 0,
              'durationText': element['duration']?['text'] ?? '',
              'durationSeconds': element['duration']?['value'] ?? 0,
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
}
