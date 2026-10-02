/// Model representing a navigation route option with toll, fuel, congestion, and scenic scores
class RouteModel {
  final String id;
  final String title;
  final String subtitle;
  final String viaCorridor;
  final double distanceKm;
  final int durationMinutes;
  final String trafficLevel; // 'Fast', 'Moderate', 'Heavy'
  final bool isFastest;
  final bool isScenic;
  final double estimatedTollBdt;
  final double fuelCostBdt;

  const RouteModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.viaCorridor,
    required this.distanceKm,
    required this.durationMinutes,
    this.trafficLevel = 'Fast',
    this.isFastest = false,
    this.isScenic = false,
    this.estimatedTollBdt = 120.0,
    this.fuelCostBdt = 680.0,
  });
}
