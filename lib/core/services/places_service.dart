import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../core/config/app_config.dart';
import '../../features/search/models/autocomplete_prediction_model.dart';

/// Places API Service - Handles real-time Google Places API (New) autocomplete and place details
class PlacesService {
  static String get _apiKey => AppConfig.googleMapsApiKey;
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api';

  /// Fetch Google Places Autocomplete predictions (Primary: Places API (New), Fallback: Legacy Places API)
  static Future<List<AutocompletePredictionModel>> autocomplete({
    required String query,
    String? sessionToken,
    double? lat,
    double? lng,
    double radius = 50000,
  }) async {
    if (query.trim().length < 2) return [];

    // 1. Primary: Google Places API (New) POST endpoint
    try {
      const newApiUrl = 'https://places.googleapis.com/v1/places:autocomplete';
      final Map<String, dynamic> body = {
        'input': query,
      };

      if (sessionToken != null && sessionToken.isNotEmpty) {
        body['sessionToken'] = sessionToken;
      }

      if (lat != null && lng != null) {
        body['locationBias'] = {
          'circle': {
            'center': {'latitude': lat, 'longitude': lng},
            'radius': radius,
          }
        };
      }

      final response = await http.post(
        Uri.parse(newApiUrl),
        headers: {
          'Content-Type': 'application/json',
          'X-Goog-Api-Key': _apiKey,
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final suggestions = data['suggestions'] as List? ?? [];
        if (suggestions.isNotEmpty) {
          final List<AutocompletePredictionModel> results = [];
          for (var item in suggestions) {
            final pred = item['placePrediction'] as Map<String, dynamic>?;
            if (pred != null) {
              final rawPlaceId = (pred['placeId'] as String?) ??
                  ((pred['place'] as String? ?? '').replaceFirst('places/', ''));
              final text = pred['text']?['text'] as String? ?? '';
              final mainText = (pred['structuredFormat']?['mainText']?['text'] as String?) ??
                  (text.contains(',') ? text.split(',').first : text);
              final secondaryText = (pred['structuredFormat']?['secondaryText']?['text'] as String?) ??
                  (text.contains(',') ? text.substring(text.indexOf(',') + 1).trim() : '');
              final types = (pred['types'] as List?)?.map((t) => t.toString()).toList() ?? [];

              if (rawPlaceId.isNotEmpty) {
                results.add(AutocompletePredictionModel(
                  placeId: rawPlaceId,
                  primaryText: mainText,
                  secondaryText: secondaryText,
                  fullDescription: text,
                  types: types,
                ));
              }
            }
          }
          if (results.isNotEmpty) return results;
        }
      }
    } catch (e) {
      debugPrint('Places API (New) autocomplete note: $e');
    }

    // 2. Fallback: Legacy Google Places API GET endpoint
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
        }
      }
    } catch (e) {
      debugPrint('Legacy Autocomplete note: $e');
    }

    return [];
  }

  /// Get detailed place information including exact geometry coordinates (Primary: Places API (New))
  static Future<Map<String, dynamic>?> details({
    required String placeId,
    String? sessionToken,
  }) async {
    if (placeId.isEmpty) return null;

    // 1. Primary: Google Places API (New) GET endpoint
    try {
      final newDetailsUrl = 'https://places.googleapis.com/v1/places/$placeId';
      final response = await http.get(
        Uri.parse(newDetailsUrl),
        headers: {
          'X-Goog-Api-Key': _apiKey,
          'X-Goog-FieldMask': 'id,displayName,formattedAddress,location,rating,userRatingCount',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final location = data['location'] as Map<String, dynamic>?;
        final lat = (location?['latitude'] as num?)?.toDouble();
        final lng = (location?['longitude'] as num?)?.toDouble();

        if (lat != null && lng != null) {
          return {
            'placeId': placeId,
            'name': data['displayName']?['text'] as String? ?? '',
            'formattedAddress': data['formattedAddress'] as String? ?? '',
            'rating': data['rating']?.toString() ?? '4.8',
            'userRatingsTotal': data['userRatingCount']?.toString() ?? '0',
            'latitude': lat,
            'longitude': lng,
          };
        }
      }
    } catch (e) {
      debugPrint('Places API (New) details note: $e');
    }

    // 2. Fallback: Legacy Google Places Details API GET endpoint
    try {
      String url = '$_baseUrl/place/details/json?place_id=$placeId&fields=name,formatted_address,geometry,rating,user_ratings_total&key=$_apiKey';

      if (sessionToken != null && sessionToken.isNotEmpty) {
        url += '&sessiontoken=$sessionToken';
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['status'] == 'OK' && data['result'] != null) {
          final result = data['result'] as Map<String, dynamic>;
          final geometry = result['geometry'] as Map<String, dynamic>?;
          final location = geometry?['location'] as Map<String, dynamic>?;

          final lat = (location?['lat'] as num?)?.toDouble();
          final lng = (location?['lng'] as num?)?.toDouble();

          if (lat != null && lng != null) {
            return {
              'placeId': placeId,
              'name': result['name'] as String? ?? '',
              'formattedAddress': result['formatted_address'] as String? ?? '',
              'rating': result['rating']?.toString() ?? '4.8',
              'userRatingsTotal': result['user_ratings_total']?.toString() ?? '0',
              'latitude': lat,
              'longitude': lng,
            };
          }
        }
      }
    } catch (e) {
      debugPrint('Legacy Details note: $e');
    }

    return null;
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
