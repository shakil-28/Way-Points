import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../core/config/app_config.dart';

/// Places API Service - Place search and discovery
class PlacesService {
  static final String _apiKey = AppConfig.googleMapsApiKey;
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api';

  /// Search places with text query
  static Future<List<Map<String, dynamic>>> search({
    required String query,
    double? lat,
    double? lng,
    double radius = 50000,
    String? type,
  }) async {
    try {
      String url = '$_baseUrl/place/textsearch/json?query=${Uri.encodeComponent(query)}&key=$_apiKey';
      
      if (lat != null && lng != null) {
        url += '&location=$lat,$lng&radius=$radius';
      }
      
      if (type != null) {
        url += '&type=$type';
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['status'] == 'OK') {
          return (data['results'] as List).map((place) {
            final geometry = place['geometry']?['location'] as Map<String, dynamic>?;
            return {
              'placeId': place['place_id'],
              'name': place['name'],
              'formattedAddress': place['formatted_address'],
              'rating': place['rating']?.toString() ?? '0',
              'userRatingsTotal': place['user_ratings_total']?.toString() ?? '0',
              'types': place['types'] as List?,
              'priceLevel': place['price_level']?.toString() ?? '0',
              'openNow': place['open_now'] as bool?,
              'latitude': geometry?['lat'],
              'longitude': geometry?['lng'],
              'photos': (place['photos'] as List?)?.map((p) => p['photo_reference']).toList() ?? [],
            };
          }).toList();
        }
      }
    } catch (e) {
      debugPrint('Places search error: $e');
    }
    return [];
  }

  /// Auto-complete suggestions
  static Future<List<Map<String, dynamic>>> autocomplete({
    required String query,
    double? lat,
    double? lng,
    double radius = 50000,
    String? region,
  }) async {
    try {
      String url = '$_baseUrl/place/autocomplete/json?input=${Uri.encodeComponent(query)}&key=$_apiKey';
      
      if (lat != null && lng != null) {
        url += '&location=$lat,$lng&radius=$radius';
      }
      
      if (region != null) {
        url += '&region=$region';
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['status'] == 'OK') {
          return (data['predictions'] as List).map((pred) => {
            'description': pred['description'],
            'placeId': pred['place_id'],
            'types': pred['types'] as List?,
            'matchedSubstrings': pred['matched_substrings'],
          }).toList();
        }
      }
    } catch (e) {
      debugPrint('Autocomplete error: $e');
    }
    return [];
  }

  /// Get detailed place information
  static Future<Map<String, dynamic>?> details({
    required String placeId,
    List<String>? fields,
  }) async {
    try {
      final defaultFields = ['name', 'formatted_address', 'formatted_phone_number', 
                             'rating', 'user_ratings_total', 'geometry', 'opening_hours'];
      final fieldsParam = (fields ?? defaultFields).join(',');
      
      final response = await http.get(
        Uri.parse('$_baseUrl/place/details/json?place_id=$placeId&fields=$fieldsParam&key=$_apiKey'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['status'] == 'OK') {
          final result = data['result'] as Map<String, dynamic>;
          final geometry = result['geometry'] as Map<String, dynamic>?;
          
          return {
            'placeId': result['place_id'],
            'name': result['name'],
            'formattedAddress': result['formatted_address'],
            'formattedPhoneNumber': result['formatted_phone_number'],
            'rating': result['rating']?.toString() ?? '0',
            'userRatingsTotal': result['user_ratings_total']?.toString() ?? '0',
            'priceLevel': result['price_level']?.toString() ?? '0',
            'openNow': result['opening_hours']?['open_now'],
            'openingHours': result['opening_hours'],
            'latitude': geometry?['location']?['lat'],
            'longitude': geometry?['location']?['lng'],
            'viewport': geometry?['viewport'],
            'website': result['website'],
            'reviews': result['reviews'],
          };
        }
      }
    } catch (e) {
      debugPrint('Place details error: $e');
    }
    return null;
  }

  /// Find places near a location
  static Future<List<Map<String, dynamic>>> nearbySearch({
    required double lat,
    required double lng,
    required String type,
    double radius = 50000,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/place/nearbysearch/json?location=$lat,$lng&radius=$radius&type=$type&key=$_apiKey',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['status'] == 'OK') {
          return (data['results'] as List).map((place) {
            final geometry = place['geometry']?['location'] as Map<String, dynamic>?;
            return {
              'placeId': place['place_id'],
              'name': place['name'],
              'formattedAddress': place['vicinity'] ?? place['formatted_address'],
              'rating': place['rating']?.toString() ?? '0',
              'userRatingsTotal': place['user_ratings_total']?.toString() ?? '0',
              'priceLevel': place['price_level']?.toString() ?? '0',
              'openNow': place['open_now'],
              'latitude': geometry?['lat'],
              'longitude': geometry?['lng'],
              'photos': (place['photos'] as List?)?.map((p) => p['photo_reference']).toList() ?? [],
            };
          }).toList();
        }
      }
    } catch (e) {
      debugPrint('Nearby search error: $e');
    }
    return [];
  }

  /// Search by query with session token for billing optimization
  static Future<List<Map<String, dynamic>>> findPlaces({
    required String query,
    double? lat,
    double? lng,
    String? sessionToken,
  }) async {
    try {
      String url = '$_baseUrl/place/autocomplete/json?input=${Uri.encodeComponent(query)}&key=$_apiKey';
      
      if (sessionToken != null) {
        url += '&sessiontoken=$sessionToken';
      }
      
      if (lat != null && lng != null) {
        url += '&location=$lat,$lng';
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['status'] == 'OK') {
          return (data['predictions'] as List).map((pred) => {
            'description': pred['description'],
            'placeId': pred['place_id'],
            'types': pred['types'] as List?,
            'structuredFormatting': pred['structured_formatting'],
          }).toList();
        }
      }
    } catch (e) {
      debugPrint('Find places error: $e');
    }
    return [];
  }
}
