enum MapLayerMode {
  standard,
  satellite,
  culturalOverlay,
  trafficDensity,
}

/// Model encapsulating interactive map viewport, zoom, tilt, and route polylines
class MapStateModel {
  final double centerLatitude;
  final double centerLongitude;
  final double zoomLevel;
  final double bearing;
  final double tilt;
  final MapLayerMode layerMode;
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
      showTraffic: showTraffic ?? this.showTraffic,
      showPois: showPois ?? this.showPois,
      activePoiId: activePoiId ?? this.activePoiId,
    );
  }
}
// TODO Implement this library.