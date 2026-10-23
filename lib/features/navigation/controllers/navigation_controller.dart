import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../core/services/voice_guidance_service.dart';
import '../../../core/utils/geoutils.dart';
import '../models/maneuver_model.dart';

/// Live Turn-by-Turn Navigation Engine Controller with off-route monitoring & voice prompts
class NavigationController extends ChangeNotifier {
  static const List<ManeuverModel> sequence = [
    ManeuverModel(
      id: 'm1',
      instruction: 'Take ramp onto Dhaka Elevated Expressway',
      streetName: 'Dhaka Elevated Expressway • South Gate',
      distanceMeters: 450,
      direction: TurnDirection.slightRight,
      laneIndicator: 'Right 2 lanes',
      speedLimitKmh: 60.0,
    ),
    ManeuverModel(
      id: 'm2',
      instruction: 'Continue straight on Asian Highway 1 (N1 Corridor)',
      streetName: 'N1 Dhaka-Chattogram Highway',
      distanceMeters: 14200,
      direction: TurnDirection.straight,
      laneIndicator: 'Stay on flyover',
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
      instruction: 'Arrive at Meghna Scenic River Overlook',
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
  bool _isOffRoute = false;
  bool _isRerouting = false;
  String? _statusBannerText;
  double _currentSpeedKmh = 52.0;
  double _remainingDistanceKm = 34.2;
  int _remainingTimeMinutes = 38;
  Timer? _stepTimer;

  bool get isNavigating => _isNavigating;
  bool get isMuted => _isMuted;
  bool get isOffRoute => _isOffRoute;
  bool get isRerouting => _isRerouting;
  String? get statusBannerText => _statusBannerText;
  double get currentSpeedKmh => _currentSpeedKmh;
  double get remainingDistanceKm => _remainingDistanceKm;
  int get remainingTimeMinutes => _remainingTimeMinutes;
  ManeuverModel get currentManeuver => sequence[_currentIndex];

  void startNavigation() {
    _isNavigating = true;
    _currentIndex = 0;
    _isOffRoute = false;
    _isRerouting = false;
    _statusBannerText = null;
    _remainingDistanceKm = 34.2;
    _remainingTimeMinutes = 38;
    VoiceGuidanceService.clearPromptHistory();
    notifyListeners();

    _speakCurrentManeuver();

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

  /// Process live GPS position update for off-route cross-track detection
  void processGpsTelemetry({
    required double lat,
    required double lng,
    required List<Map<String, double>> polyline,
    String language = 'Bengali (BD - Farhana)',
  }) {
    if (!_isNavigating || polyline.length < 2) return;

    final offRoute = GeoUtils.isOffRoute(lat: lat, lng: lng, polyline: polyline, thresholdKm: 0.1);

    if (offRoute && !_isOffRoute) {
      _isOffRoute = true;
      _isRerouting = true;
      _statusBannerText = 'Off-route detected. Re-calculating route...';
      notifyListeners();

      VoiceGuidanceService.speakPrompt('Off route. Recalculating route...', language: language);

      // Simulate live auto-rerouting completion after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        if (_isNavigating) {
          _isOffRoute = false;
          _isRerouting = false;
          _statusBannerText = 'Route updated.';
          notifyListeners();
        }
      });
    }
  }

  void _speakCurrentManeuver() {
    VoiceGuidanceService.speakPrompt('In ${currentManeuver.distanceMeters} meters, ${currentManeuver.instruction}');
  }

  void stopNavigation() {
    _isNavigating = false;
    _isOffRoute = false;
    _isRerouting = false;
    _statusBannerText = null;
    _stepTimer?.cancel();
    notifyListeners();
  }

  void nextManeuver() {
    if (_currentIndex < sequence.length - 1) {
      _currentIndex++;
      _speakCurrentManeuver();
      notifyListeners();
    }
  }

  void toggleMute() {
    _isMuted = !_isMuted;
    VoiceGuidanceService.setMuted(_isMuted);
    notifyListeners();
  }

  @override
  void dispose() {
    _stepTimer?.cancel();
    super.dispose();
  }
}
