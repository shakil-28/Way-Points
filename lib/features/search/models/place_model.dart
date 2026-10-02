/// Model representing a searchable destination, heritage site, or corridor waypoint
class PlaceModel {
  final String id;
  final String title;
  final String subtitle;
  final String category;
  final double latitude;
  final double longitude;
  final double rating;
  final String distanceText;
  final String imageUrl;

  const PlaceModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.latitude,
    required this.longitude,
    this.rating = 4.8,
    this.distanceText = '3.2 km',
    this.imageUrl = 'https://images.unsplash.com/photo-1588416936097-41850ab3d86d?w=600',
  });
}
