/// Model representing past navigated journeys and search queries
class SearchHistoryModel {
  final String id;
  final String title;
  final String origin;
  final String destination;
  final double distanceKm;
  final int durationMinutes;
  final DateTime timestamp;
  final String category;
  final int scenicStopsVisited;
  final double originLat;
  final double originLng;
  final double destinationLat;
  final double destinationLng;

  const SearchHistoryModel({
    required this.id,
    required this.title,
    required this.origin,
    required this.destination,
    required this.distanceKm,
    required this.durationMinutes,
    required this.timestamp,
    this.category = 'Highway',
    this.scenicStopsVisited = 1,
    required this.originLat,
    required this.originLng,
    required this.destinationLat,
    required this.destinationLng,
  });
}
