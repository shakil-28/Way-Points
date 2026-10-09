enum MapLayerMode {
  standard,
  satellite,
  culturalOverlay,
  trafficDensity,
}

enum MapScreenMode {
  explore,
  routePreview,
  navigation,
}

/// Model encapsulating interactive map viewport, zoom, tilt, screen mode, and route polylines
class MapStateModel {
  final double centerLatitude;
  final double centerLongitude;
  final double zoomLevel;
  final double bearing;
  final double tilt;
  final MapLayerMode layerMode;
  final MapScreenMode screenMode;
  final bool showTraffic;
  final bool showPois;
  final String? activePoiId;

  const MapStateModel({
    required this.centerLatitude,
    required this.centerLongitude,
    this.zoomLevel = 13.5,
    this.bearing = 0.0,
    this.tilt = 45.0,
    this.layerMode = MapLayerMode.standard,
    this.screenMode = MapScreenMode.explore,
    this.showTraffic = true,
    this.showPois = true,
    this.activePoiId,
  });

  MapStateModel copyWith({
    double? centerLatitude,
    double? centerLongitude,
    double? zoomLevel,
    double? bearing,
    double? tilt,
    MapLayerMode? layerMode,
    MapScreenMode? screenMode,
    bool? showTraffic,
    bool? showPois,
    String? activePoiId,
  }) {
    return MapStateModel(
      centerLatitude: centerLatitude ?? this.centerLatitude,
      centerLongitude: centerLongitude ?? this.centerLongitude,
      zoomLevel: zoomLevel ?? this.zoomLevel,
      bearing: bearing ?? this.bearing,
      tilt: tilt ?? this.tilt,
      layerMode: layerMode ?? this.layerMode,
      screenMode: screenMode ?? this.screenMode,
      showTraffic: showTraffic ?? this.showTraffic,
      showPois: showPois ?? this.showPois,
      activePoiId: activePoiId ?? this.activePoiId,
    );
  }
}
