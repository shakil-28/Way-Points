import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/maneuver_model.dart';

/// Live Turn-by-Turn Navigation Engine Controller
class NavigationController extends ChangeNotifier {
  static const List<ManeuverModel> sequence = [
    ManeuverModel(
      id: 'm1',
      instruction: 'In 450 m, take the ramp onto Dhaka Elevated Expressway',
      streetName: 'Dhaka Elevated Expressway • South Gate',
      distanceMeters: 450,
      direction: TurnDirection.slightRight,
      laneIndicator: 'Use right 2 lanes',
      speedLimitKmh: 60.0,
    ),
    ManeuverModel(
      id: 'm2',
      instruction: 'Continue straight on Asian Highway 1 (N1 Corridor)',
      streetName: 'N1 Dhaka-Chattogram Highway',
      distanceMeters: 14200,
      direction: TurnDirection.straight,
      laneIndicator: 'Stay on express flyover',
      speedLimitKmh: 80.0,
    ),
    ManeuverModel(
      id: 'm3',
      instruction: 'Take Exit 4 towards Sonargaon Folk Art Museum',
      streetName: 'Panam Nagar Heritage Bypass',
      distanceMeters: 800,
      direction: TurnDirection.turnRight,
      laneIndicator: 'Exit right lane',
      speedLimitKmh: 40.0,
    ),
    ManeuverModel(
      id: 'm4',
      instruction: 'You will arrive at Meghna Scenic River Overlook',
      streetName: 'Old Ferry Ghat Road',
      distanceMeters: 250,
      direction: TurnDirection.arrive,
      laneIndicator: 'Destination on left',
      speedLimitKmh: 30.0,
    ),
  ];

  int _currentIndex = 0;
  bool _isNavigating = false;
  bool _isMuted = false;
  double _currentSpeedKmh = 52.0;
  double _remainingDistanceKm = 34.2;
  int _remainingTimeMinutes = 38;
  Timer? _stepTimer;

  bool get isNavigating => _isNavigating;
  bool get isMuted => _isMuted;
  double get currentSpeedKmh => _currentSpeedKmh;
  double get remainingDistanceKm => _remainingDistanceKm;
  int get remainingTimeMinutes => _remainingTimeMinutes;
  ManeuverModel get currentManeuver => sequence[_currentIndex];

  void startNavigation() {
    _isNavigating = true;
    _currentIndex = 0;
    _remainingDistanceKm = 34.2;
    _remainingTimeMinutes = 38;
    notifyListeners();

    _stepTimer?.cancel();
    _stepTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!_isNavigating) return;
      _currentSpeedKmh = 48.0 + (DateTime.now().second % 12);
      if (_remainingDistanceKm > 0.5) {
        _remainingDistanceKm -= 0.3;
      }
      notifyListeners();
    });
  }

  void stopNavigation() {
    _isNavigating = false;
    _stepTimer?.cancel();
    notifyListeners();
  }

  void nextManeuver() {
    if (_currentIndex < sequence.length - 1) {
      _currentIndex++;
      notifyListeners();
    }
  }

  void toggleMute() {
    _isMuted = !_isMuted;
    notifyListeners();
  }

  @override
  void dispose() {
    _stepTimer?.cancel();
    super.dispose();
  }
}
