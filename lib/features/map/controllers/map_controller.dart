import 'package:flutter/foundation.dart';
import '../../../core/config/app_config.dart';
import '../models/map_state_model.dart';

/// Interactive Map Controller governing viewport panning, zoom, layers, map modes, and waypoint focusing
class MapController extends ChangeNotifier {
  MapStateModel _state = const MapStateModel(
    centerLatitude: AppConfig.defaultLatitude,
    centerLongitude: AppConfig.defaultLongitude,
    zoomLevel: AppConfig.defaultZoom,
    layerMode: MapLayerMode.culturalOverlay,
    screenMode: MapScreenMode.explore,
  );

  MapStateModel get state => _state;
  MapScreenMode get screenMode => _state.screenMode;

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

  void setScreenMode(MapScreenMode mode) {
    _state = _state.copyWith(screenMode: mode);
    notifyListeners();
  }

  void showExplore() {
    _state = _state.copyWith(screenMode: MapScreenMode.explore);
    notifyListeners();
  }

  void showRoutePreview() {
    _state = _state.copyWith(screenMode: MapScreenMode.routePreview);
    notifyListeners();
  }

  void startNavigation() {
    _state = _state.copyWith(screenMode: MapScreenMode.navigation);
    notifyListeners();
  }

  void exitNavigation() {
    _state = _state.copyWith(screenMode: MapScreenMode.explore);
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
