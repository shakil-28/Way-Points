import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../controllers/map_controller.dart';
import '../models/map_state_model.dart';

/// Vector Map View rendering realistic Bengal corridor geography and live GPS location marker
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

class _MapViewState extends State<MapView> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeController = widget.controller ?? context.watch<MapController>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: Listenable.merge([activeController, _pulseController]),
      builder: (context, _) {
        final state = activeController.state;

        return ClipRect(
          child: CustomPaint(
            painter: _BengalMapPainter(
              isDark: isDark,
              zoom: state.zoomLevel,
              pulseVal: _pulseController.value,
              layerMode: state.layerMode,
              screenMode: state.screenMode,
              activePoiId: state.activePoiId,
            ),
            child: const SizedBox.expand(),
          ),
        );
      },
    );
  }
}

class _BengalMapPainter extends CustomPainter {
  final bool isDark;
  final double zoom;
  final double pulseVal;
  final MapLayerMode layerMode;
  final MapScreenMode screenMode;
  final String? activePoiId;

  _BengalMapPainter({
    required this.isDark,
    required this.zoom,
    required this.pulseVal,
    required this.layerMode,
    required this.screenMode,
    this.activePoiId,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Terrain Base Fill
    Color bgColor;
    if (layerMode == MapLayerMode.satellite) {
      bgColor = isDark ? const Color(0xFF0F1B15) : const Color(0xFF1E3A2F);
    } else {
      bgColor = isDark ? const Color(0xFF141315) : const Color(0xFFF1F5F3);
    }
    canvas.drawRect(Offset.zero & size, Paint()..color = bgColor);

    // 2. Subtle Grid Lines
    final gridPaint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.04)
      ..strokeWidth = 1.0;

    const gridSize = 40.0;
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // 3. Buriganga & Meghna River Network
    final riverPath = Path();
    riverPath.moveTo(size.width * 0.1, size.height * 0.15);
    riverPath.cubicTo(
      size.width * 0.35, size.height * 0.3,
      size.width * 0.2, size.height * 0.65,
      size.width * 0.55, size.height * 0.85,
    );
    riverPath.quadraticBezierTo(
      size.width * 0.75, size.height * 0.95,
      size.width * 0.95, size.height * 0.9,
    );

    final riverPaint = Paint()
      ..color = isDark ? const Color(0xFF0D2538) : const Color(0xFFCCE4F7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20.0
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(riverPath, riverPaint);

    // 4. Secondary Road Network Streets
    final streetPaint = Paint()
      ..color = (isDark ? Colors.white12 : Colors.black12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final streetPath = Path();
    streetPath.moveTo(0, size.height * 0.35);
    streetPath.lineTo(size.width, size.height * 0.35);
    streetPath.moveTo(size.width * 0.6, 0);
    streetPath.lineTo(size.width * 0.6, size.height);
    canvas.drawPath(streetPath, streetPaint);

    // 5. Active Navigation / Route Polylines (ONLY rendered in routePreview or navigation mode)
    if (screenMode == MapScreenMode.routePreview || screenMode == MapScreenMode.navigation) {
      final routePath = Path();
      routePath.moveTo(size.width * 0.25, size.height * 0.82);
      routePath.lineTo(size.width * 0.45, size.height * 0.55);
      routePath.lineTo(size.width * 0.70, size.height * 0.38);
      routePath.lineTo(size.width * 0.85, size.height * 0.22);

      // Route Outer Glow
      final glowPaint = Paint()
        ..color = AppTheme.primaryGreen.withValues(alpha: isDark ? 0.35 : 0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14.0
        ..strokeCap = StrokeCap.round;
      canvas.drawPath(routePath, glowPaint);

      // Route Solid Core (Sapphire / Emerald)
      final corePaint = Paint()
        ..color = const Color(0xFF0051D5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6.0
        ..strokeCap = StrokeCap.round;
      canvas.drawPath(routePath, corePaint);
    }

    // 6. Live GPS Location Marker (CENTERED on map when navigation not started / in explore mode)
    final gpsCenterPos = Offset(size.width * 0.50, size.height * 0.44);

    // Pulsing outer radar halo ring 1
    final waveRadius1 = 20.0 + (pulseVal * 36.0);
    final wavePaint1 = Paint()
      ..color = AppTheme.primaryGreen.withValues(alpha: (1.0 - pulseVal).clamp(0.0, 1.0) * 0.35)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(gpsCenterPos, waveRadius1, wavePaint1);

    // Pulsing outer radar halo ring 2
    final waveRadius2 = 10.0 + (pulseVal * 20.0);
    final wavePaint2 = Paint()
      ..color = AppTheme.primaryGreen.withValues(alpha: (1.0 - pulseVal).clamp(0.0, 1.0) * 0.5)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(gpsCenterPos, waveRadius2, wavePaint2);

    // Directional heading cone pointer above location dot
    final conePath = Path();
    conePath.moveTo(gpsCenterPos.dx, gpsCenterPos.dy - 22);
    conePath.lineTo(gpsCenterPos.dx - 7, gpsCenterPos.dy - 8);
    conePath.lineTo(gpsCenterPos.dx + 7, gpsCenterPos.dy - 8);
    conePath.close();

    final conePaint = Paint()..color = AppTheme.primaryGreen;
    canvas.drawPath(conePath, conePaint);

    // White outer ring badge
    final outerRingPaint = Paint()..color = Colors.white;
    canvas.drawCircle(gpsCenterPos, 12.0, outerRingPaint);

    final borderRingPaint = Paint()
      ..color = AppTheme.primaryGreen.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    canvas.drawCircle(gpsCenterPos, 12.0, borderRingPaint);

    // Center deep emerald live GPS dot
    final gpsDotPaint = Paint()..color = AppTheme.primaryGreen;
    canvas.drawCircle(gpsCenterPos, 6.0, gpsDotPaint);

    // 7. Waypoint Landmark Markers
    _drawMarker(canvas, Offset(size.width * 0.25, size.height * 0.82), 'Lalbagh Fort', isDark);
    _drawMarker(canvas, Offset(size.width * 0.70, size.height * 0.38), 'Padma Overlook', isDark);
    _drawMarker(canvas, Offset(size.width * 0.85, size.height * 0.22), 'Meghna Ghat', isDark);
  }

  void _drawMarker(Canvas canvas, Offset offset, String label, bool isDark) {
    final markerPaint = Paint()
      ..color = const Color(0xFF025939)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(offset, 6.0, markerPaint);

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(offset, 6.0, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _BengalMapPainter oldDelegate) => true;
}
