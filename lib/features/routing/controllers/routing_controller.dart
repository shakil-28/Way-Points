import 'package:flutter/foundation.dart';
import '../models/route_model.dart';

/// Routing & Corridor Choice Controller
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

  List<RouteModel> get routes => _routes;
  RouteModel get selectedRoute => _selectedRoute;

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
