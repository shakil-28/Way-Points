import 'package:flutter/foundation.dart';
import '../../../core/config/app_config.dart';
import '../../../core/services/routes_service.dart';
import '../models/route_model.dart';

/// Routing & Corridor Choice Controller with live Google Directions API integration
class RoutingController extends ChangeNotifier {
  static const List<RouteModel> predefinedRoutes = [
    RouteModel(
      id: 'route_n1_express',
      title: 'N1 Express Corridor',
      subtitle: 'Fastest route via Meghna Bridge with 4-lane bypass',
      viaCorridor: 'N1 Highway • 4 Lane Asian Highway',
      distanceKm: 242.0,
      durationMinutes: 245,
      trafficLevel: 'Fast',
      isFastest: true,
      isScenic: false,
      estimatedTollBdt: 250.0,
      fuelCostBdt: 1850.0,
    ),
    RouteModel(
      id: 'route_riverine_scenic',
      title: 'Old Bengal Riverine Route',
      subtitle: 'Scenic river crossings, Sonargaon heritage & lush countryside',
      viaCorridor: 'Meghna Ghat • Sonargaon Historic Lane',
      distanceKm: 268.0,
      durationMinutes: 285,
      trafficLevel: 'Moderate',
      isFastest: false,
      isScenic: true,
      estimatedTollBdt: 180.0,
      fuelCostBdt: 1950.0,
    ),
    RouteModel(
      id: 'route_padma_expressway',
      title: 'Padma South Corridor',
      subtitle: 'Ultra-modern 8-lane expressway with river overlook',
      viaCorridor: 'N8 Expressway • Padma Mega Bridge',
      distanceKm: 215.0,
      durationMinutes: 190,
      trafficLevel: 'Fast',
      isFastest: false,
      isScenic: true,
      estimatedTollBdt: 400.0,
      fuelCostBdt: 1620.0,
    ),
  ];

  List<RouteModel> _routes = List.from(predefinedRoutes);
  RouteModel _selectedRoute = predefinedRoutes.first;
  bool _isLoadingRoute = false;

  List<RouteModel> get routes => _routes;
  RouteModel get selectedRoute => _selectedRoute;
  bool get isLoadingRoute => _isLoadingRoute;

  /// Calculate live directions and routes from Google Directions API
  Future<void> fetchLiveDirections({
    required double destLat,
    required double destLng,
    double? originLat,
    double? originLng,
  }) async {
    _isLoadingRoute = true;
    notifyListeners();

    try {
      final startLat = originLat ?? AppConfig.defaultLatitude;
      final startLng = originLng ?? AppConfig.defaultLongitude;

      final directions = await RoutesService.getDirections(
        originLat: startLat,
        originLng: startLng,
        destLat: destLat,
        destLng: destLng,
      );

      if (directions != null) {
        final distMeters = (directions['distanceMeters'] as int?) ?? 0;
        final durationSecs = (directions['durationSeconds'] as int?) ?? 0;
        final summary = (directions['summary'] as String?) ?? '';
        final polylineStr = (directions['polyline'] as String?) ?? '';
        final decodedPoints = RoutesService.decodePolylinePoints(polylineStr);

        final liveRoute = RouteModel(
          id: 'route_live_${DateTime.now().millisecondsSinceEpoch}',
          title: summary.isNotEmpty ? 'Via $summary' : 'Live Highway Route',
          subtitle: '${directions['startAddress']} → ${directions['endAddress']}',
          viaCorridor: summary.isNotEmpty ? '$summary Expressway' : 'Google Directions Live Corridor',
          distanceKm: distMeters / 1000.0,
          durationMinutes: (durationSecs / 60.0).round(),
          trafficLevel: 'Live Flow',
          isFastest: true,
          isScenic: false,
          estimatedTollBdt: 250.0,
          fuelCostBdt: ((distMeters / 1000.0) * 7.5).roundToDouble(),
          polyline: polylineStr,
          polylinePoints: decodedPoints,
        );

        _routes = [liveRoute, ...predefinedRoutes];
        _selectedRoute = liveRoute;
      }
    } catch (e) {
      debugPrint('Error fetching live directions: $e');
    } finally {
      _isLoadingRoute = false;
      notifyListeners();
    }
  }

  void selectRoute(RouteModel route) {
    _selectedRoute = route;
    notifyListeners();
  }

  void selectRouteById(String id) {
    final match = _routes.firstWhere((r) => r.id == id, orElse: () => _selectedRoute);
    _selectedRoute = match;
    notifyListeners();
  }
}
