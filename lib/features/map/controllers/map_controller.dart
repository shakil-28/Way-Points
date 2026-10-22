import 'package:flutter/foundation.dart';
import '../../../core/config/app_config.dart';
import '../models/map_state_model.dart';

/// Interactive Map Controller governing viewport panning, auto-follow camera, zoom, layers, and map modes
class MapController extends ChangeNotifier {
  MapStateModel _state = const MapStateModel(
    centerLatitude: AppConfig.defaultLatitude,
    centerLongitude: AppConfig.defaultLongitude,
    zoomLevel: AppConfig.defaultZoom,
    layerMode: MapLayerMode.culturalOverlay,
    screenMode: MapScreenMode.explore,
  );

  bool _isAutoFollowEnabled = true;

  MapStateModel get state => _state;
  MapScreenMode get screenMode => _state.screenMode;
  bool get isAutoFollowEnabled => _isAutoFollowEnabled;

  void setAutoFollow(bool enabled) {
    if (_isAutoFollowEnabled != enabled) {
      _isAutoFollowEnabled = enabled;
      notifyListeners();
    }
  }

  void zoomIn() {
    _state = _state.copyWith(zoomLevel: (_state.zoomLevel + 1.0).clamp(5.0, 20.0));
    notifyListeners();
  }

  void zoomOut() {
    _state = _state.copyWith(zoomLevel: (_state.zoomLevel - 1.0).clamp(5.0, 20.0));
    notifyListeners();
  }

  void panTo(double lat, double lon, {double? zoom, double? bearing, double? tilt}) {
    _state = _state.copyWith(
      centerLatitude: lat,
      centerLongitude: lon,
      zoomLevel: zoom ?? _state.zoomLevel,
      bearing: bearing ?? _state.bearing,
      tilt: tilt ?? _state.tilt,
    );
    notifyListeners();
  }

  void updateCamera({
    required double lat,
    required double lon,
    required double zoom,
    double? bearing,
    double? tilt,
  }) {
    _state = _state.copyWith(
      centerLatitude: lat,
      centerLongitude: lon,
      zoomLevel: zoom,
      bearing: bearing ?? _state.bearing,
      tilt: tilt ?? _state.tilt,
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
    _isAutoFollowEnabled = true;
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
    _isAutoFollowEnabled = false;
    panTo(AppConfig.defaultLatitude, AppConfig.defaultLongitude, zoom: 13.5, bearing: 0.0, tilt: 0.0);
  }
}
