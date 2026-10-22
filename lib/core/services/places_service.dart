import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../core/config/app_config.dart';
import '../../features/search/models/autocomplete_prediction_model.dart';

/// Places API Service - Handles real-time Google Maps place autocomplete and details
class PlacesService {
  static String get _apiKey => AppConfig.googleMapsApiKey;
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api';

  /// Fetch Google Places Autocomplete predictions with session token support
  static Future<List<AutocompletePredictionModel>> autocomplete({
    required String query,
    String? sessionToken,
    double? lat,
    double? lng,
    double radius = 50000,
  }) async {
    if (query.trim().length < 2) return [];

    try {
      String url = '$_baseUrl/place/autocomplete/json?input=${Uri.encodeComponent(query)}&key=$_apiKey';

      if (sessionToken != null && sessionToken.isNotEmpty) {
        url += '&sessiontoken=$sessionToken';
      }

      if (lat != null && lng != null) {
        url += '&location=$lat,$lng&radius=$radius';
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final status = data['status'] as String?;

        if (status == 'OK') {
          final predictionsJson = data['predictions'] as List? ?? [];
          return predictionsJson
              .map((p) => AutocompletePredictionModel.fromJson(p as Map<String, dynamic>))
              .where((p) => p.placeId.isNotEmpty)
              .toList();
        } else if (status == 'ZERO_RESULTS') {
          return [];
        } else {
          final errorMsg = data['error_message'] as String? ?? status ?? 'Unknown error';
          debugPrint('Places Autocomplete API status: $status ($errorMsg)');
          if (status == 'REQUEST_DENIED' || status == 'OVER_QUERY_LIMIT') {
            throw Exception('Places API Error: $status ($errorMsg)');
          }
        }
      } else {
        throw Exception('HTTP Error ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Autocomplete exception: $e');
      rethrow;
    }
    return [];
  }

  /// Get detailed place information including exact geometry coordinates
  static Future<Map<String, dynamic>?> details({
    required String placeId,
    String? sessionToken,
  }) async {
    if (placeId.isEmpty) return null;

    try {
      String url = '$_baseUrl/place/details/json?place_id=$placeId&fields=name,formatted_address,geometry,rating,user_ratings_total&key=$_apiKey';

      if (sessionToken != null && sessionToken.isNotEmpty) {
        url += '&sessiontoken=$sessionToken';
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final status = data['status'] as String?;

        if (status == 'OK') {
          final result = data['result'] as Map<String, dynamic>?;
          if (result == null) return null;

          final geometry = result['geometry'] as Map<String, dynamic>?;
          final location = geometry?['location'] as Map<String, dynamic>?;

          final lat = (location?['lat'] as num?)?.toDouble();
          final lng = (location?['lng'] as num?)?.toDouble();

          if (lat == null || lng == null) {
            throw Exception('Place details missing geometry coordinates');
          }

          return {
            'placeId': placeId,
            'name': result['name'] as String? ?? '',
            'formattedAddress': result['formatted_address'] as String? ?? '',
            'rating': result['rating']?.toString() ?? '4.8',
            'userRatingsTotal': result['user_ratings_total']?.toString() ?? '0',
            'latitude': lat,
            'longitude': lng,
          };
        } else {
          final errorMsg = data['error_message'] as String? ?? status ?? 'Unknown error';
          throw Exception('Place Details API error: $status ($errorMsg)');
        }
      } else {
        throw Exception('HTTP Error ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Place details exception: $e');
      rethrow;
    }
  }

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
}
