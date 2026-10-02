import 'package:flutter/foundation.dart';
import '../models/search_history_model.dart';

/// Controller managing past searches and completed scenic corridor trips
class HistoryController extends ChangeNotifier {
  static final List<SearchHistoryModel> initialTrips = [
    SearchHistoryModel(
      id: 'trip_1',
      title: 'Dhaka to Sreemangal Tea Trail',
      origin: 'Gulshan 2, Dhaka',
      destination: 'Grand Sultan Tea Resort, Sreemangal',

      originLat: 23.7925,
      originLng: 90.4078,
      destinationLat: 24.3065,
      destinationLng: 91.7296,

      distanceKm: 194.5,
      durationMinutes: 240,
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      category: 'Scenic Trail',
      scenicStopsVisited: 3,
    ),
    SearchHistoryModel(
      id: 'trip_2',
      title: 'Padma Bridge South Bypass',
      origin: 'Dhanmondi 27, Dhaka',
      destination: 'Mawa Fish Ghat & Overlook',

      originLat: 23.7461,
      originLng: 90.3742,
      destinationLat: 23.4707,
      destinationLng: 90.2676,

      distanceKm: 42.0,
      durationMinutes: 48,
      timestamp: DateTime.now().subtract(const Duration(days: 5)),
      category: 'Waterfront',
      scenicStopsVisited: 2,
    ),
    SearchHistoryModel(
      id: 'trip_2',
      title: 'Padma Bridge South Bypass',
      origin: 'Dhanmondi 27, Dhaka',
      destination: 'Mawa Fish Ghat & Overlook',

      originLat: 23.7461,
      originLng: 90.3742,
      destinationLat: 23.4707,
      destinationLng: 90.2676,

      distanceKm: 42.0,
      durationMinutes: 48,
      timestamp: DateTime.now().subtract(const Duration(days: 5)),
      category: 'Waterfront',
      scenicStopsVisited: 2,
    ),
  ];

  final List<SearchHistoryModel> _trips = List.from(initialTrips);

  List<SearchHistoryModel> get trips => _trips;

  void addTrip(SearchHistoryModel trip) {
    _trips.insert(0, trip);
    notifyListeners();
  }

  void clearHistory() {
    _trips.clear();
    notifyListeners();
  }

  void removeTrip(String id) {
    _trips.removeWhere((t) => t.id == id);
    notifyListeners();
  }
}
