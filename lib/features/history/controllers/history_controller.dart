import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/search_history_model.dart';

/// Controller managing past searches and completed scenic corridor trips with Cloud Firestore synchronization
class HistoryController extends ChangeNotifier {
  static final List<SearchHistoryModel> initialTrips = [
    SearchHistoryModel(
      id: 'trip_1',
      title: 'Dhaka to Sreemangal Tea Trail',
      origin: 'Gulshan 2, Dhaka',
      destination: 'Grand Sultan Tea Resort, Sreemangal',
      originLat: 23.7925,
      originLng: 90.4078,
      destinationLat: 24.3065,
      destinationLng: 91.7296,
      distanceKm: 194.5,
      durationMinutes: 240,
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      category: 'Scenic Trail',
      scenicStopsVisited: 3,
    ),
    SearchHistoryModel(
      id: 'trip_2',
      title: 'Padma Bridge South Bypass',
      origin: 'Dhanmondi 27, Dhaka',
      destination: 'Mawa Fish Ghat & Overlook',
      originLat: 23.7461,
      originLng: 90.3742,
      destinationLat: 23.4707,
      destinationLng: 90.2676,
      distanceKm: 42.0,
      durationMinutes: 48,
      timestamp: DateTime.now().subtract(const Duration(days: 5)),
      category: 'Waterfront',
      scenicStopsVisited: 2,
    ),
    SearchHistoryModel(
      id: 'trip_3',
      title: 'Sonargaon Heritage Lane',
      origin: 'Banani 11, Dhaka',
      destination: 'Panam Nagar Ancient City',
      originLat: 23.7955,
      originLng: 90.4008,
      destinationLat: 23.6492,
      destinationLng: 90.5986,
      distanceKm: 28.0,
      durationMinutes: 36,
      timestamp: DateTime.now().subtract(const Duration(days: 8)),
      category: 'Heritage',
      scenicStopsVisited: 2,
    ),
  ];

  bool _showClearModal = false;
  List<SearchHistoryModel> _trips = List.from(initialTrips);
  StreamSubscription<QuerySnapshot>? _firestoreSubscription;

  bool get showClearModal => _showClearModal;
  List<SearchHistoryModel> get trips => _trips;

  HistoryController() {
    initFirestoreStream();
  }

  void initFirestoreStream() {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        _firestoreSubscription = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('trips')
            .orderBy('timestamp', descending: true)
            .snapshots()
            .listen((snapshot) {
          if (snapshot.docs.isNotEmpty) {
            final liveTrips = snapshot.docs.map((doc) {
              return SearchHistoryModel.fromMap(doc.data() as Map<String, dynamic>, id: doc.id);
            }).toList();
            _trips = [...liveTrips, ...initialTrips];
            notifyListeners();
          }
        }, onError: (e) {
          debugPrint('Firestore trips stream error: $e');
        });
      }
    } catch (e) {
      debugPrint('History Firestore init note: $e');
    }
  }

  void toggleClearModal(bool show) {
    _showClearModal = show;
    notifyListeners();
  }

  Future<void> addTrip(SearchHistoryModel trip) async {
    _trips.insert(0, trip);
    notifyListeners();

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('trips')
            .doc(trip.id)
            .set(trip.toMap());
      }
    } catch (e) {
      debugPrint('Error saving trip to Firestore: $e');
    }
  }

  Future<void> clearHistory() async {
    _trips.clear();
    notifyListeners();

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final docs = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('trips')
            .get();
        for (var doc in docs.docs) {
          await doc.reference.delete();
        }
      }
    } catch (e) {
      debugPrint('Error clearing Firestore trip history: $e');
    }
  }

  Future<void> removeTrip(String id) async {
    _trips.removeWhere((t) => t.id == id);
    notifyListeners();

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('trips')
            .doc(id)
            .delete();
      }
    } catch (e) {
      debugPrint('Error removing trip from Firestore: $e');
    }
  }

  @override
  void dispose() {
    _firestoreSubscription?.cancel();
    super.dispose();
  }
}
