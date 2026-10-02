import 'package:flutter/foundation.dart';
import '../models/poi_model.dart';

/// Discovery Controller for scenic cultural waypoints along corridors
class DiscoveryController extends ChangeNotifier {
  static const List<PoiModel> curatedPois = [
    PoiModel(
      id: 'poi_lalbagh',
      name: 'Lalbagh Fort & Mughal Gardens',
      category: 'Mughal Architecture',
      description: 'An incomplete 17th-century Mughal fort complex that stands proudly before the Buriganga River in southwestern Dhaka.',
      historicSignificance: 'Commissioned in 1678 by Mughal Prince Muhammad Azam during his vice-royalty of Bengal.',
      rating: 4.8,
      reviewCount: 3420,
      latitude: 23.7189,
      longitude: 90.3881,
      imageUrl: 'https://images.unsplash.com/photo-1588416936097-41850ab3d86d?w=800',
      detourMinutes: 8,
      detourDistanceKm: 1.8,
      amenities: ['Secure Parking', 'Restrooms', 'Museum Access', 'Prayer Room'],
      bestTimeToVisit: '4:00 PM – 6:00 PM (Golden Hour)',
    ),
    PoiModel(
      id: 'poi_sonargaon',
      name: 'Sonargaon Panam Nagar & Folk Art Museum',
      category: 'Ancient Bengal Capital',
      description: 'The ancient capital of Isa Khan and the Baro-Bhuiyan rulers, boasting a single cobblestone avenue lined with 52 colonial merchant mansions.',
      historicSignificance: 'Flourishing trade center along the historic Silk Road and riverine routes of Eastern Bengal.',
      rating: 4.9,
      reviewCount: 2180,
      latitude: 23.6492,
      longitude: 90.5986,
      imageUrl: 'https://images.unsplash.com/photo-1518684079-3c830dcef090?w=800',
      detourMinutes: 14,
      detourDistanceKm: 4.2,
      amenities: ['Artisan Crafts', 'Lakeside Walk', 'Cafe', 'EV Charging'],
      bestTimeToVisit: '9:00 AM – 11:30 AM',
    ),
    PoiModel(
      id: 'poi_padma_overlook',
      name: 'Padma Bridge River Overlook & Mawa Ghat',
      category: 'Scenic Waterfront',
      description: 'Spectacular vantage point overlooking the mighty Padma River, famous for authentic fried Ilish fish and boat expeditions.',
      historicSignificance: 'The gateway connecting 21 south-western districts with Dhaka.',
      rating: 4.9,
      reviewCount: 5410,
      latitude: 23.4735,
      longitude: 90.2625,
      imageUrl: 'https://images.unsplash.com/photo-1582510003544-4d00b7f74220?w=800',
      detourMinutes: 6,
      detourDistanceKm: 1.2,
      amenities: ['Fresh Fish Dining', 'Express Fuel', 'River Boat Tours', 'Rest Area'],
      bestTimeToVisit: '5:30 PM – 7:30 PM (Sunset)',
    ),
  ];

  List<PoiModel> _pois = List.from(curatedPois);
  PoiModel _activePoi = curatedPois.first;

  List<PoiModel> get pois => _pois;
  PoiModel get activePoi => _activePoi;

  void selectPoi(PoiModel poi) {
    _activePoi = poi;
    notifyListeners();
  }

  void selectPoiById(String id) {
    final found = _pois.firstWhere((p) => p.id == id, orElse: () => _activePoi);
    _activePoi = found;
    notifyListeners();
  }
}
