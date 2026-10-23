/// Model representing past navigated journeys, fuel telemetry, and exploration badges
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
  final double fuelEfficiencyKmL;
  final String badgeEarned;
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
    this.fuelEfficiencyKmL = 14.2,
    this.badgeEarned = 'Mughal Explorer Badge',
    required this.originLat,
    required this.originLng,
    required this.destinationLat,
    required this.destinationLng,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'origin': origin,
      'destination': destination,
      'distanceKm': distanceKm,
      'durationMinutes': durationMinutes,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'category': category,
      'scenicStopsVisited': scenicStopsVisited,
      'fuelEfficiencyKmL': fuelEfficiencyKmL,
      'badgeEarned': badgeEarned,
      'originLat': originLat,
      'originLng': originLng,
      'destinationLat': destinationLat,
      'destinationLng': destinationLng,
    };
  }

  factory SearchHistoryModel.fromMap(Map<String, dynamic> map, {required String id}) {
    final rawTs = map['timestamp'];
    DateTime dt = DateTime.now();
    if (rawTs is int) {
      dt = DateTime.fromMillisecondsSinceEpoch(rawTs);
    }

    return SearchHistoryModel(
      id: id,
      title: map['title'] as String? ?? 'Scenic Trip',
      origin: map['origin'] as String? ?? 'Dhaka',
      destination: map['destination'] as String? ?? 'Destination',
      distanceKm: (map['distanceKm'] as num?)?.toDouble() ?? 10.0,
      durationMinutes: (map['durationMinutes'] as num?)?.toInt() ?? 15,
      timestamp: dt,
      category: map['category'] as String? ?? 'Highway',
      scenicStopsVisited: (map['scenicStopsVisited'] as num?)?.toInt() ?? 1,
      fuelEfficiencyKmL: (map['fuelEfficiencyKmL'] as num?)?.toDouble() ?? 14.2,
      badgeEarned: map['badgeEarned'] as String? ?? 'Bengal Explorer',
      originLat: (map['originLat'] as num?)?.toDouble() ?? 23.8103,
      originLng: (map['originLng'] as num?)?.toDouble() ?? 90.4125,
      destinationLat: (map['destinationLat'] as num?)?.toDouble() ?? 23.8103,
      destinationLng: (map['destinationLng'] as num?)?.toDouble() ?? 90.4125,
    );
  }
}
