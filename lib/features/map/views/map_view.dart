import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../controllers/map_controller.dart';
import '../models/map_state_model.dart';

/// Vector Map View rendering realistic Bengal corridor geography:
/// Buriganga River bend, Padma estuary, Dhaka expressway overpass, route glow, and radar pulse.
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
  final String? activePoiId;

  _BengalMapPainter({
    required this.isDark,
    required this.zoom,
    required this.pulseVal,
    required this.layerMode,
    this.activePoiId,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Background terrain fill
    final bgPaint = Paint()
      ..color = isDark ? const Color(0xFF141315) : const Color(0xFFF1F5F3);
    canvas.drawRect(Offset.zero & size, bgPaint);

    // Subtle grid coordinates
    final gridPaint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withOpacity(0.04)
      ..strokeWidth = 1.0;

    const gridSize = 40.0;
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Buriganga & Meghna river system (curved organic bezier path)
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
      ..strokeWidth = 18.0
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(riverPath, riverPaint);

    // Main corridor route (Dhaka -> N1 Highway / Padma corridor)
    final routePath = Path();
    routePath.moveTo(size.width * 0.25, size.height * 0.82);
    routePath.lineTo(size.width * 0.45, size.height * 0.55);
    routePath.lineTo(size.width * 0.70, size.height * 0.38);
    routePath.lineTo(size.width * 0.85, size.height * 0.22);

    // Route Outer Glow
    final glowPaint = Paint()
      ..color = AppTheme.accentNeon.withOpacity(isDark ? 0.35 : 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12.0
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(routePath, glowPaint);

    // Route Solid Core
    final corePaint = Paint()
      ..color = AppTheme.accentNeon
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(routePath, corePaint);

    // Vehicle GPS Position & Radar Pulse Beacon
    final vehiclePos = Offset(size.width * 0.45, size.height * 0.55);

    // Radar pulse wave
    final waveRadius = 14.0 + (pulseVal * 32.0);
    final wavePaint = Paint()
      ..color = AppTheme.accentNeon.withOpacity((1.0 - pulseVal).clamp(0.0, 1.0) * 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(vehiclePos, waveRadius, wavePaint);

    // Center vehicle marker
    final vehiclePaint = Paint()..color = const Color(0xFF00FF87);
    canvas.drawCircle(vehiclePos, 8.0, vehiclePaint);
    final innerPaint = Paint()..color = isDark ? const Color(0xFF141315) : Colors.white;
    canvas.drawCircle(vehiclePos, 4.0, innerPaint);

    // Waypoint Landmark Markers
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
