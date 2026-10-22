import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../../../core/config/app_config.dart';
import '../../../core/services/places_service.dart';
import '../models/autocomplete_prediction_model.dart';
import '../models/place_model.dart';

/// Autocomplete & Destination Discovery Controller implementing Google Maps–style live place predictions
class PlaceSearchController extends ChangeNotifier {
  String _query = '';
  String _selectedCategory = 'all';
  bool _isLoading = false;
  bool _isResolvingDetails = false;
  String? _errorMessage;
  List<AutocompletePredictionModel> _predictions = [];
  List<PlaceModel> _results = [];
  String? _sessionToken;
  int _searchVersion = 0;
  Timer? _debounceTimer;

  // Curated Bangladesh destinations available when search query is empty
  static const List<PlaceModel> allDestinations = [
    PlaceModel(
      id: 'poi_savar_monument',
      title: 'Savar National Martyrs Memorial',
      subtitle: 'Savar, Dhaka-Aricha Highway Corridor',
      category: 'heritage',
      latitude: 23.9117,
      longitude: 90.2547,
      rating: 4.9,
      distanceText: '12.4 km',
      imageUrl: 'https://images.unsplash.com/photo-1588416936097-41850ab3d86d?w=600',
    ),
    PlaceModel(
      id: 'poi_savar_epz',
      title: 'Savar Export Processing Zone (EPZ)',
      subtitle: 'Savar Industrial Corridor, N5 Highway',
      category: 'services',
      latitude: 23.9485,
      longitude: 90.2694,
      rating: 4.5,
      distanceText: '16.2 km',
      imageUrl: 'https://images.unsplash.com/photo-1518684079-3c830dcef090?w=600',
    ),
    PlaceModel(
      id: 'poi_savar_bus_stand',
      title: 'Savar Bus Terminal & Bazar',
      subtitle: 'Dhaka-Aricha Hwy, Savar Center',
      category: 'services',
      latitude: 23.8475,
      longitude: 90.2575,
      rating: 4.4,
      distanceText: '14.0 km',
      imageUrl: 'https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?w=600',
    ),
    PlaceModel(
      id: 'poi_lalbagh',
      title: 'Lalbagh Fort & Mughal Garden',
      subtitle: 'Old Dhaka Heritage Quarter • 17th-century Mughal fortress',
      category: 'cultural',
      latitude: 23.7189,
      longitude: 90.3881,
      rating: 4.8,
      distanceText: '2.1 km',
      imageUrl: 'https://images.unsplash.com/photo-1588416936097-41850ab3d86d?w=600',
    ),
    PlaceModel(
      id: 'poi_ahsan_manzil',
      title: 'Ahsan Manzil (Pink Palace)',
      subtitle: 'Buriganga Riverfront • Official residence of the Nawab of Dhaka',
      category: 'cultural',
      latitude: 23.7086,
      longitude: 90.4060,
      rating: 4.7,
      distanceText: '3.4 km',
      imageUrl: 'https://images.unsplash.com/photo-1608958435020-e8a7109ba809?w=600',
    ),
    PlaceModel(
      id: 'poi_sixty_dome',
      title: 'Sixty Dome Mosque (Bagerhat)',
      subtitle: 'UNESCO World Heritage • Khan Jahan Ali Sultanate architecture',
      category: 'heritage',
      latitude: 22.6740,
      longitude: 89.7420,
      rating: 4.9,
      distanceText: '178 km',
      imageUrl: 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=600',
    ),
    PlaceModel(
      id: 'poi_sreemangal',
      title: 'Sreemangal Tea Garden Corridor',
      subtitle: 'Sylhet Division • Undulating rolling hills & seven-layer tea',
      category: 'scenic',
      latitude: 24.3065,
      longitude: 91.7296,
      rating: 4.9,
      distanceText: '192 km',
      imageUrl: 'https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?w=600',
    ),
    PlaceModel(
      id: 'poi_padma_bridge',
      title: 'Padma Bridge River Overlook & Mawa Ghat',
      subtitle: 'Munshiganj / Shariatpur • Famous Ilish fish & mega-engineering',
      category: 'scenic',
      latitude: 23.4735,
      longitude: 90.2625,
      rating: 4.9,
      distanceText: '42 km',
      imageUrl: 'https://images.unsplash.com/photo-1582510003544-4d00b7f74220?w=600',
    ),
    PlaceModel(
      id: 'poi_sonargaon',
      title: 'Sonargaon Panam Nagar',
      subtitle: 'Ancient Bengal Capital • Historic brick mansions & artisan crafts',
      category: 'heritage',
      latitude: 23.6492,
      longitude: 90.5986,
      rating: 4.8,
      distanceText: '28 km',
      imageUrl: 'https://images.unsplash.com/photo-1518684079-3c830dcef090?w=600',
    ),
  ];

  String get query => _query;
  String get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  bool get isResolvingDetails => _isResolvingDetails;
  String? get errorMessage => _errorMessage;
  List<AutocompletePredictionModel> get predictions => _predictions;
  List<PlaceModel> get curatedDestinations => _applyCategoryFilter(allDestinations);
  List<PlaceModel> get results => _results.isEmpty && _query.isEmpty ? curatedDestinations : _results;

  PlaceSearchController() {
    _results = List.from(allDestinations);
  }

  List<PlaceModel> _applyCategoryFilter(List<PlaceModel> list) {
    if (_selectedCategory == 'all') return list;
    return list.where((p) => p.category == _selectedCategory).toList();
  }

  /// Called on search input text change with 350ms debouncing and generation versioning
  void onQueryChanged(String val) {
    final newQuery = val.trim();
    if (_query == newQuery) return;

    _query = newQuery;

    if (_query.isEmpty) {
      _debounceTimer?.cancel();
      _predictions = [];
      _errorMessage = null;
      _isLoading = false;
      _sessionToken = null;
      notifyListeners();
      return;
    }

    if (_query.length < 2) {
      _debounceTimer?.cancel();
      _predictions = [];
      _errorMessage = null;
      _isLoading = false;
      notifyListeners();
      return;
    }

    // Generate session token if search session has just started
    _sessionToken ??= _generateSessionToken();

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 350), _fetchPredictions);
  }

  /// Execute Google Places API autocomplete request with fallback on API denial
  Future<void> _fetchPredictions() async {
    if (_query.length < 2) return;

    _searchVersion++;
    final currentVersion = _searchVersion;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await PlacesService.autocomplete(
        query: _query,
        sessionToken: _sessionToken,
        lat: AppConfig.defaultLatitude,
        lng: AppConfig.defaultLongitude,
      );

      // Discard stale responses if user continued typing
      if (currentVersion != _searchVersion) return;

      if (results.isNotEmpty) {
        _predictions = results;
      } else {
        _fallbackToCuratedOrQueryMatch();
      }

      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      if (currentVersion != _searchVersion) return;

      debugPrint('Autocomplete fetch error: $e');

      // Fallback gracefully to curated matching places if Google Places API returns REQUEST_DENIED
      _fallbackToCuratedOrQueryMatch();

      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
    }
  }

  void _fallbackToCuratedOrQueryMatch() {
    final matchedCurated = allDestinations.where((place) {
      return place.title.toLowerCase().contains(_query.toLowerCase()) ||
          place.subtitle.toLowerCase().contains(_query.toLowerCase());
    }).toList();

    if (matchedCurated.isNotEmpty) {
      _predictions = matchedCurated.map((p) => AutocompletePredictionModel(
        placeId: p.id,
        primaryText: p.title,
        secondaryText: p.subtitle,
        fullDescription: '${p.title}, ${p.subtitle}',
      )).toList();
    } else {
      _predictions = [
        AutocompletePredictionModel(
          placeId: 'search_query_${_query.hashCode}',
          primaryText: '$_query, Dhaka Division',
          secondaryText: 'Direct Route via Highway Corridor',
          fullDescription: '$_query, Bangladesh',
        ),
      ];
    }
  }

  /// Retry pending search query
  void retrySearch() {
    if (_query.length >= 2) {
      _fetchPredictions();
    }
  }

  /// Resolve exact latitude/longitude for a prediction tap using Google Place Details API
  Future<PlaceModel?> selectPrediction(AutocompletePredictionModel prediction) async {
    _debounceTimer?.cancel();
    _isResolvingDetails = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (prediction.placeId.startsWith('poi_') || prediction.placeId.startsWith('search_query_')) {
        final match = allDestinations.firstWhere(
          (p) => p.id == prediction.placeId,
          orElse: () => PlaceModel(
            id: prediction.placeId,
            title: prediction.primaryText,
            subtitle: prediction.secondaryText,
            category: 'cultural',
            latitude: AppConfig.defaultLatitude,
            longitude: AppConfig.defaultLongitude,
          ),
        );
        _isResolvingDetails = false;
        notifyListeners();
        return match;
      }

      final details = await PlacesService.details(
        placeId: prediction.placeId,
        sessionToken: _sessionToken,
      );

      _sessionToken = null;

      if (details != null && details['latitude'] != null && details['longitude'] != null) {
        final place = PlaceModel(
          id: prediction.placeId,
          title: (details['name'] as String?)?.isNotEmpty == true
              ? details['name'] as String
              : prediction.primaryText,
          subtitle: (details['formattedAddress'] as String?)?.isNotEmpty == true
              ? details['formattedAddress'] as String
              : prediction.secondaryText,
          category: 'cultural',
          latitude: (details['latitude'] as num).toDouble(),
          longitude: (details['longitude'] as num).toDouble(),
          rating: double.tryParse(details['rating']?.toString() ?? '4.8') ?? 4.8,
          distanceText: 'Live Fix',
        );

        _isResolvingDetails = false;
        notifyListeners();
        return place;
      } else {
        throw Exception('Missing coordinates in place details response');
      }
    } catch (e) {
      debugPrint('Error resolving prediction details: $e');
      
      // Fallback gracefully for prediction selection
      final place = PlaceModel(
        id: prediction.placeId,
        title: prediction.primaryText,
        subtitle: prediction.secondaryText,
        category: 'cultural',
        latitude: AppConfig.defaultLatitude,
        longitude: AppConfig.defaultLongitude,
      );

      _isResolvingDetails = false;
      notifyListeners();
      return place;
    }
  }

  void selectCategory(String category) {
    _selectedCategory = category;
    _applyFilter();
  }

  void _applyFilter() {
    _results = allDestinations.where((place) {
      final matchesCat = _selectedCategory == 'all' || place.category == _selectedCategory;
      final matchesText = _query.isEmpty ||
          place.title.toLowerCase().contains(_query.toLowerCase()) ||
          place.subtitle.toLowerCase().contains(_query.toLowerCase());
      return matchesCat && matchesText;
    }).toList();
    notifyListeners();
  }

  void clear() {
    _debounceTimer?.cancel();
    _query = '';
    _predictions = [];
    _errorMessage = null;
    _isLoading = false;
    _sessionToken = null;
    notifyListeners();
  }

  String _generateSessionToken() {
    final random = Random.secure();
    final values = List<int>.generate(16, (i) => random.nextInt(256));
    return values.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
