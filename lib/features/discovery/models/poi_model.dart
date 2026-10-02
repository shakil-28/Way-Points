/// Model for Cultural Points of Interest & Curated Waystops
class PoiModel {
  final String id;
  final String name;
  final String category;
  final String description;
  final String historicSignificance;
  final double rating;
  final int reviewCount;
  final double latitude;
  final double longitude;
  final String imageUrl;
  final int detourMinutes;
  final double detourDistanceKm;
  final List<String> amenities;
  final String bestTimeToVisit;

  const PoiModel({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.historicSignificance,
    required this.rating,
    required this.reviewCount,
    required this.latitude,
    required this.longitude,
    required this.imageUrl,
    required this.detourMinutes,
    required this.detourDistanceKm,
    required this.amenities,
    required this.bestTimeToVisit,
  });
}
