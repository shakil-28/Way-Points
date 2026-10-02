import 'package:flutter/foundation.dart';
import '../models/place_model.dart';

/// Autocomplete & Destination Discovery Controller for Bangladesh places
class PlaceSearchController extends ChangeNotifier {
  String _query = '';
  String _selectedCategory = 'all';
  List<PlaceModel> _results = [];

  static const List<PlaceModel> allDestinations = [
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
  List<PlaceModel> get results => _results.isEmpty && _query.isEmpty ? allDestinations : _results;

  PlaceSearchController() {
    _results = List.from(allDestinations);
  }

  void onQueryChanged(String val) {
    _query = val.trim();
    _applyFilter();
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
    _query = '';
    _results = List.from(allDestinations);
    notifyListeners();
  }
}
