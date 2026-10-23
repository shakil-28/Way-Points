import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../features/hazards/controllers/hazard_controller.dart';
import '../../../features/location/controllers/location_controller.dart';

import '../controllers/map_controller.dart';
import '../models/map_state_model.dart';

/// Displays a real Google Map synchronized with live camera auto-follow, GPS marker, & hazard overlays
class MapView extends StatefulWidget {
  final MapController? controller;
  final ValueChanged<String>? onMarkerTap;

  const MapView({
    super.key,
    this.controller,
    this.onMarkerTap,
  });

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  GoogleMapController? _googleMapController;

  CameraPosition? _lastRequestedCamera;
  CameraPosition? _currentCameraPosition;

  MapController? _activeController;
  LocationController? _locationController;
  Set<Marker> _markers = <Marker>{};
  BitmapDescriptor? _customGpsIcon;
  bool _hasPannedToInitialGps = false;

  @override
  void initState() {
    super.initState();
    _loadCustomGpsIcon();
  }

  Future<void> _loadCustomGpsIcon() async {
    final icon = await _generateCustomGpsMarkerIcon();
    if (mounted) {
      setState(() {
        _customGpsIcon = icon;
      });
      _updateGpsMarker();
    }
  }

  /// Generates a compact custom WayPoint Bengal Emerald GPS marker
  Future<BitmapDescriptor> _generateCustomGpsMarkerIcon() async {
    const double size = 64.0;
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);

    const center = Offset(size / 2, size / 2);

    // Outer neon glow halo ring
    final glowPaint = Paint()
      ..color = AppTheme.accentNeon.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 28.0, glowPaint);

    // Outer neon border ring
    final borderPaint = Paint()
      ..color = AppTheme.accentNeon
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(center, 20.0, borderPaint);

    // Emerald inner badge
    final emeraldPaint = Paint()
      ..color = AppTheme.primaryGreen
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 18.0, emeraldPaint);

    // Directional navigation triangle chevron (heading arrow)
    final arrowPath = Path()
      ..moveTo(center.dx, center.dy - 10)
      ..lineTo(center.dx - 6, center.dy + 5)
      ..lineTo(center.dx, center.dy + 2)
      ..lineTo(center.dx + 6, center.dy + 5)
      ..close();
    final arrowPaint = Paint()..color = Colors.white;
    canvas.drawPath(arrowPath, arrowPaint);

    // Center white core dot
    final corePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 3.5, corePaint);

    final picture = pictureRecorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    if (byteData == null) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
    }

    return BitmapDescriptor.bytes(byteData.buffer.asUint8List());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _activeController = widget.controller ?? context.read<MapController>();
    final newLocationCtrl = context.read<LocationController>();
    if (_locationController != newLocationCtrl) {
      _locationController?.removeListener(_updateGpsMarker);
      _locationController = newLocationCtrl;
      _locationController?.addListener(_updateGpsMarker);
    }
  }

  @override
  void didUpdateWidget(covariant MapView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != widget.controller) {
      _activeController =
          widget.controller ?? context.read<MapController>();
    }
  }

  CameraPosition _cameraFromState(MapStateModel state) {
    return CameraPosition(
      target: LatLng(
        state.centerLatitude,
        state.centerLongitude,
      ),
      zoom: state.zoomLevel,
      bearing: state.bearing,
      tilt: state.tilt,
    );
  }

  bool _sameCamera(CameraPosition? a, CameraPosition b) {
    if (a == null) return false;

    return (a.target.latitude - b.target.latitude).abs() < 0.00001 &&
        (a.target.longitude - b.target.longitude).abs() < 0.00001 &&
        (a.zoom - b.zoom).abs() < 0.01 &&
        (a.bearing - b.bearing).abs() < 0.1 &&
        (a.tilt - b.tilt).abs() < 0.1;
  }

  void _syncCamera(MapStateModel state) {
    final mapController = _googleMapController;
    if (mapController == null) return;

    final desiredCamera = _cameraFromState(state);

    if (_sameCamera(_lastRequestedCamera, desiredCamera)) {
      return;
    }

    _lastRequestedCamera = desiredCamera;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || _googleMapController == null) return;

      try {
        await _googleMapController!.animateCamera(
          CameraUpdate.newCameraPosition(desiredCamera),
        );
      } catch (error) {
        debugPrint('Unable to update Google Maps camera: $error');
      }
    });
  }

  MapType _getMapType(MapLayerMode mode) {
    switch (mode) {
      case MapLayerMode.satellite:
        return MapType.hybrid;

      case MapLayerMode.standard:
      case MapLayerMode.culturalOverlay:
      case MapLayerMode.trafficDensity:
        return MapType.normal;
    }
  }

  void _updateGpsMarker() {
    final locationCtrl = _locationController;
    if (locationCtrl == null || !mounted) return;
    
    if (locationCtrl.isLocationUpdated) {
      final state = locationCtrl.state;
      final gpsPosition = LatLng(state.latitude, state.longitude);

      // Check proximity hazard warnings as driver moves
      context.read<HazardController>().checkProximityAlerts(
        driverLat: state.latitude,
        driverLng: state.longitude,
      );
      
      setState(() {
        _markers = {
          Marker(
            markerId: const MarkerId('gps_location'),
            position: gpsPosition,
            icon: _customGpsIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
            infoWindow: const InfoWindow(title: 'Live WayPoint Location'),
            anchor: const Offset(0.5, 0.5),
            rotation: state.heading,
          ),
        };
      });

      // Auto-pan camera to keep moving GPS marker centered in auto-follow mode
      if (_activeController != null) {
        if (!_hasPannedToInitialGps) {
          _hasPannedToInitialGps = true;
          _activeController!.updateCamera(
            lat: state.latitude,
            lon: state.longitude,
            zoom: 15.0,
          );
        } else if (_activeController!.isAutoFollowEnabled) {
          _activeController!.updateCamera(
            lat: state.latitude,
            lon: state.longitude,
            zoom: _activeController!.state.zoomLevel,
            bearing: state.heading,
          );
        }
      }
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _googleMapController = controller;

    final state = _activeController!.state;
    final initialCamera = _cameraFromState(state);

    _lastRequestedCamera = initialCamera;
    _currentCameraPosition = initialCamera;
    
    _updateGpsMarker();
  }

  void _onCameraMove(CameraPosition position) {
    _currentCameraPosition = position;
  }

  void _onCameraIdle() {
    final position = _currentCameraPosition;
    final controller = _activeController;

    if (position == null || controller == null) return;

    _lastRequestedCamera = position;

    controller.updateCamera(
      lat: position.target.latitude,
      lon: position.target.longitude,
      zoom: position.zoom,
      bearing: position.bearing,
      tilt: position.tilt,
    );
  }

  @override
  void dispose() {
    _locationController?.removeListener(_updateGpsMarker);
    _googleMapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mapController =
        widget.controller ?? context.watch<MapController>();
    final hazardController = context.watch<HazardController>();

    final hazardMarkers = hazardController.hazards.map((h) {
      return Marker(
        markerId: MarkerId('haz_${h.id}'),
        position: LatLng(h.latitude, h.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          h.type == 'police'
              ? BitmapDescriptor.hueAzure
              : (h.type == 'traffic' ? BitmapDescriptor.hueOrange : BitmapDescriptor.hueRed),
        ),
        infoWindow: InfoWindow(
          title: '⚠️ ${h.title}',
          snippet: 'Reported by ${h.reportedBy}',
        ),
      );
    }).toSet();

    final allMapMarkers = {..._markers, ...hazardMarkers};

    return AnimatedBuilder(
      animation: mapController,
      builder: (childContext, child) {
        final state = mapController.state;

        _syncCamera(state);

        return GoogleMap(
          initialCameraPosition: _cameraFromState(state),

          onMapCreated: _onMapCreated,
          onCameraMove: _onCameraMove,
          onCameraIdle: _onCameraIdle,

          mapType: _getMapType(state.layerMode),

          trafficEnabled: state.showTraffic ||
              state.layerMode == MapLayerMode.trafficDensity,

          myLocationEnabled: false,
          myLocationButtonEnabled: false,
          
          markers: allMapMarkers,

          compassEnabled: true,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          rotateGesturesEnabled: true,
          scrollGesturesEnabled: true,
          zoomGesturesEnabled: true,
          tiltGesturesEnabled: true,

          padding: EdgeInsets.zero,
        );
      },
    );
  }
}
