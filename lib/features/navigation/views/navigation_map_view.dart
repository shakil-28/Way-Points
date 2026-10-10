import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../map/controllers/map_controller.dart';
import '../../map/views/map_view.dart';

/// Navigation Map Substrate & Vector Route Painter
class NavigationMapView extends StatelessWidget {
  final MapController mapCtrl;
  final AnimationController pulseController;
  final bool isDark;

  const NavigationMapView({
    super.key,
    required this.mapCtrl,
    required this.pulseController,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        MapView(controller: mapCtrl),
        AnimatedBuilder(
          animation: pulseController,
          builder: (context, _) {
            return CustomPaint(
              size: Size.infinite,
              painter: _NavigationRoutePainter(
                pulse: pulseController.value,
                isDark: isDark,
              ),
            );
          },
        ),
      ],
    );
  }
}

class _NavigationRoutePainter extends CustomPainter {
  final double pulse;
  final bool isDark;

  _NavigationRoutePainter({
    required this.pulse,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double scaleX = size.width / 390;
    final double scaleY = size.height / 520;

    canvas.save();
    canvas.scale(scaleX, scaleY);

    final Path path = Path()
      ..moveTo(195, 520)
      ..lineTo(195, 390)
      ..lineTo(110, 300)
      ..lineTo(95, 170);

    final Paint outerPaint = Paint()
      ..color = const Color(0xFF065F46).withValues(alpha: 0.20)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 22
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, outerPaint);

    final Paint shadowPaint = Paint()
      ..color = const Color(0xFF047857).withValues(alpha: 0.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 17
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawPath(path, shadowPaint);

    final Paint routePaint = Paint()
      ..color = AppTheme.primaryGreen
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, routePaint);

    final Paint dashPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.95)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;
    _drawDashedPath(canvas, path, dashPaint, dashLength: 14, gapLength: 10);

    const Offset vehiclePos = Offset(195, 450);

    final double pulseRadius = 18.0 + (pulse * 14.0);
    final double pulseAlpha = (1.0 - pulse) * 0.35;
    canvas.drawCircle(
      vehiclePos,
      pulseRadius,
      Paint()
        ..color = const Color(0xFF10B981).withValues(alpha: pulseAlpha)
        ..style = PaintingStyle.fill,
    );

    canvas.drawCircle(
      vehiclePos,
      18,
      Paint()..color = const Color(0xFF10B981).withValues(alpha: 0.30),
    );
    canvas.drawCircle(
      vehiclePos,
      10,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      vehiclePos,
      7,
      Paint()
        ..color = AppTheme.primaryGreen
        ..style = PaintingStyle.fill,
    );

    final Path triangle = Path()
      ..moveTo(vehiclePos.dx, vehiclePos.dy - 6)
      ..lineTo(vehiclePos.dx - 4, vehiclePos.dy + 2)
      ..lineTo(vehiclePos.dx + 4, vehiclePos.dy + 2)
      ..close();
    canvas.drawPath(triangle, Paint()..color = Colors.white);

    canvas.restore();
  }

  void _drawDashedPath(
    Canvas canvas,
    Path path,
    Paint paint, {
    required double dashLength,
    required double gapLength,
  }) {
    for (final ui.PathMetric metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final double nextDistance =
            math.min(distance + dashLength, metric.length);
        canvas.drawPath(metric.extractPath(distance, nextDistance), paint);
        distance += dashLength + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _NavigationRoutePainter oldDelegate) =>
      oldDelegate.pulse != pulse || oldDelegate.isDark != isDark;
}
