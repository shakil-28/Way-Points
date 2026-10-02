import 'package:flutter/foundation.dart';
import '../../../core/config/app_config.dart';
import '../models/map_state_model.dart';

/// Interactive Map Controller governing viewport panning, zoom, layers, and waypoint focusing
class MapController extends ChangeNotifier {
  MapStateModel _state = const MapStateModel(
    centerLatitude: AppConfig.defaultLatitude,
    centerLongitude: AppConfig.defaultLongitude,
    zoomLevel: AppConfig.defaultZoom,
    layerMode: MapLayerMode.culturalOverlay,
  );

  MapStateModel get state => _state;

  void zoomIn() {
    _state = _state.copyWith(zoomLevel: (_state.zoomLevel + 1.0).clamp(5.0, 20.0));
    notifyListeners();
  }

  void zoomOut() {
    _state = _state.copyWith(zoomLevel: (_state.zoomLevel - 1.0).clamp(5.0, 20.0));
    notifyListeners();
  }

  void panTo(double lat, double lon, {double? zoom}) {
    _state = _state.copyWith(
      centerLatitude: lat,
      centerLongitude: lon,
      zoomLevel: zoom ?? _state.zoomLevel,
    );
    notifyListeners();
  }

  void setLayerMode(MapLayerMode mode) {
    _state = _state.copyWith(layerMode: mode);
    notifyListeners();
  }

  void toggleTraffic() {
    _state = _state.copyWith(showTraffic: !_state.showTraffic);
    notifyListeners();
  }

  void togglePois() {
    _state = _state.copyWith(showPois: !_state.showPois);
    notifyListeners();
  }

  void selectPoi(String? poiId) {
    _state = _state.copyWith(activePoiId: poiId);
    notifyListeners();
  }

  void resetToDhakaCenter() {
    panTo(AppConfig.defaultLatitude, AppConfig.defaultLongitude, zoom: 13.5);
  }
}
