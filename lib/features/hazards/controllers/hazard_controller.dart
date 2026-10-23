import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/utils/geoutils.dart';
import '../models/hazard_model.dart';

/// State Manager controlling highway hazard reporting and real-time Firestore synchronization
class HazardController extends ChangeNotifier {
  static final List<HazardModel> _initialHazards = [
    HazardModel(
      id: 'haz_police_n1',
      title: 'Police Checkpoint',
      type: 'police',
      icon: Symbols.local_police,
      color: Colors.blue,
      latitude: 23.7925,
      longitude: 90.4078,
      timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      reportedBy: 'Driver #204',
    ),
    HazardModel(
      id: 'haz_traffic_savar',
      title: 'Heavy Traffic Congestion',
      type: 'traffic',
      icon: Symbols.traffic,
      color: Colors.amber,
      latitude: 23.8475,
      longitude: 90.2575,
      timestamp: DateTime.now().subtract(const Duration(minutes: 8)),
      reportedBy: 'Driver #108',
    ),
    HazardModel(
      id: 'haz_construction_padma',
      title: 'Road Construction / Detour',
      type: 'construction',
      icon: Symbols.construction,
      color: Colors.orange,
      latitude: 23.4735,
      longitude: 90.2625,
      timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
      reportedBy: 'Corridor Monitor',
    ),
  ];

  List<HazardModel> _hazards = List.from(_initialHazards);
  HazardModel? _nearbyActiveHazard;
  StreamSubscription<QuerySnapshot>? _firestoreSubscription;

  List<HazardModel> get hazards => _hazards;
  HazardModel? get nearbyActiveHazard => _nearbyActiveHazard;

  HazardController() {
    initFirestoreStream();
  }

  /// Listen to live Cloud Firestore hazard broadcasts in real-time (< 100ms)
  void initFirestoreStream() {
    try {
      _firestoreSubscription = FirebaseFirestore.instance
          .collection('hazards')
          .orderBy('timestamp', descending: true)
          .limit(50)
          .snapshots()
          .listen((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          final liveList = snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final type = data['type'] as String? ?? 'police';
            return HazardModel(
              id: doc.id,
              title: data['title'] as String? ?? 'Highway Hazard',
              type: type,
              icon: _iconFromType(type),
              color: _colorFromType(type),
              latitude: (data['latitude'] as num?)?.toDouble() ?? 23.8103,
              longitude: (data['longitude'] as num?)?.toDouble() ?? 90.4125,
              timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
              reportedBy: data['reportedBy'] as String? ?? 'Corridor Driver',
            );
          }).toList();

          _hazards = [...liveList, ..._initialHazards];
          notifyListeners();
        }
      }, onError: (e) {
        debugPrint('Firestore hazards stream error: $e');
      });
    } catch (e) {
      debugPrint('Firestore hazard stream init note: $e');
    }
  }

  static IconData _iconFromType(String type) {
    switch (type) {
      case 'police':
        return Symbols.local_police;
      case 'traffic':
        return Symbols.traffic;
      case 'construction':
        return Symbols.construction;
      case 'accident':
      default:
        return Symbols.car_crash;
    }
  }

  static Color _colorFromType(String type) {
    switch (type) {
      case 'police':
        return Colors.blue;
      case 'traffic':
        return Colors.amber;
      case 'construction':
        return Colors.orange;
      case 'accident':
      default:
        return Colors.redAccent;
    }
  }

  /// Report a live highway hazard at current GPS coordinates and save to Firestore
  Future<void> reportHazard({
    required String title,
    required String type,
    required IconData icon,
    required Color color,
    required double lat,
    required double lng,
    String reportedBy = 'You',
  }) async {
    final newHazard = HazardModel(
      id: 'haz_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      type: type,
      icon: icon,
      color: color,
      latitude: lat,
      longitude: lng,
      timestamp: DateTime.now(),
      reportedBy: reportedBy,
    );

    _hazards.insert(0, newHazard);
    notifyListeners();

    try {
      await FirebaseFirestore.instance.collection('hazards').doc(newHazard.id).set({
        'title': title,
        'type': type,
        'latitude': lat,
        'longitude': lng,
        'timestamp': FieldValue.serverTimestamp(),
        'reportedBy': reportedBy,
      });
    } catch (e) {
      debugPrint('Error saving hazard to Firestore: $e');
    }
  }

  /// Check if the driver is within alertRadiusKm (default 1.0 km) of any active reported hazard
  void checkProximityAlerts({
    required double driverLat,
    required double driverLng,
    double alertRadiusKm = 1.0,
  }) {
    HazardModel? closest;
    double smallestDist = double.infinity;

    for (var hazard in _hazards) {
      final distKm = GeoUtils.haversineDistanceKm(
        lat1: driverLat,
        lon1: driverLng,
        lat2: hazard.latitude,
        lon2: hazard.longitude,
      );

      if (distKm <= alertRadiusKm && distKm < smallestDist) {
        smallestDist = distKm;
        closest = hazard;
      }
    }

    if (_nearbyActiveHazard?.id != closest?.id) {
      _nearbyActiveHazard = closest;
      notifyListeners();
    }
  }

  void dismissProximityAlert() {
    _nearbyActiveHazard = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _firestoreSubscription?.cancel();
    super.dispose();
  }
}
