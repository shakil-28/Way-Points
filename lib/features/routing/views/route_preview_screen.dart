import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/context_header.dart';
import '../../../core/utils/time_utils.dart';
import '../controllers/routing_controller.dart';
import '../../map/controllers/map_controller.dart';
import '../../map/views/map_view.dart';

/// Full-screen corridor preview with animated map, POI pins, route selector, and CTA.
class RoutePreviewScreen extends StatefulWidget {
  final VoidCallback onStartNavigation;
  final VoidCallback? onCancel;

  const RoutePreviewScreen({
    super.key,
    required this.onStartNavigation,
    this.onCancel,
  });

  @override
  State<RoutePreviewScreen> createState() => _RoutePreviewScreenState();
}

class _RoutePreviewScreenState extends State<RoutePreviewScreen>
    with SingleTickerProviderStateMixin {

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
    final routingCtrl = context.watch<RoutingController>();
    final mapCtrl = context.watch<MapController>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final selected = routingCtrl.selectedRoute;
    final altRoute = routingCtrl.routes.firstWhere(
      (r) => r.id != selected.id,
      orElse: () => routingCtrl.routes.last,
    );

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
          // ── Map background ──────────────────────────────────────────
          Positioned.fill(
            child: MapView(controller: mapCtrl),
          ),

          // ── Route SVG overlay ───────────────────────────────────────
          Positioned.fill(
            child: CustomPaint(
              size: Size.infinite,
              painter: _RoutePreviewPainter(
                selected: selected,
                alternate: altRoute,
                isDark: isDark,
                pulse: _pulseController.value,
              ),
            ),
          ),

          // ── POI marker pins ─────────────────────────────────────────
          _buildPoiPin(context, isDark, offsetFraction: const Offset(0.43, 0.62), icon: Symbols.local_cafe, label: 'Shitolokkha Rest', detour: '+2 min'),
          _buildPoiPin(context, isDark, offsetFraction: const Offset(0.62, 0.45), icon: Symbols.ev_station, label: 'Narsingdi EV'),
          _buildPoiPin(context, isDark, offsetFraction: const Offset(0.78, 0.30), icon: Symbols.park, label: 'Tea Garden View'),
          // -- Context Header --
          Positioned(
            top: 6,
            left: 16,
            right: 16,
            child: ContextHeader(
              title: 'Route Preview',
              isDark: isDark,
              onBack: () =>
                  widget.onCancel != null
                      ? widget.onCancel!()
                      : Navigator.of(context).maybePop(),
              onProfile: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Profile setup accessible from main menu.'),
                  behavior: SnackBarBehavior.floating,
                ),
              ),
            ),
          ),


          // ── Right-side map controls ─────────────────────────────────
          Positioned(
            right: 16,
            left: 16,
            bottom: MediaQuery.of(context).padding.bottom + 320,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _mapControlButton(
                  icon: Symbols.my_location,
                  onTap: () => mapCtrl.resetToDhakaCenter(),
                  isDark: isDark,
                ),
                const SizedBox(height: 8),
                _mapControlButton(
                  icon: Symbols.layers,
                  onTap: () {},
                  isDark: isDark,
                ),
              ],
            ),
          ),

          // ── Bottom card ─────────────────────────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _RoutePreviewBottomCard(
              selected: selected,
              altRoute: altRoute,
              routes: routingCtrl.routes,
              isDark: isDark,
              onSelectRoute: (route) => routingCtrl.selectRoute(route),
              onStart: widget.onStartNavigation,
              onWeatherTap: () {},
            ),
          ),
        ],
      ),
      ),
    );
  }

  // ── POI Pin Helper ────────────────────────────────────────────────

  Widget _buildPoiPin(
    BuildContext context,
    bool isDark, {
    required Offset offsetFraction,
    required IconData icon,
    required String label,
    String? detour,
  }) {
    return Positioned(
      left: offsetFraction.dx * (MediaQuery.of(context).size.width - 32) + 16,
      top: offsetFraction.dy * (MediaQuery.of(context).size.height - 200),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutBack,
        builder: (_, value, child) {
          return Transform.translate(
            offset: Offset(0, (1 - value) * 8),
            child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1c1b1e) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? const Color(0xFF363436)
                  : const Color(0xFFE2E8F0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.12),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 15, color: AppTheme.accentNeon),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
              if (detour != null) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1FAE5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    detour,
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF059669),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ── Status Pill ───────────────────────────────────────────────────

  Widget _statusPill(
    BuildContext context, {
    required IconData icon,
    required String label,
    Color? color,
    Color? bgColor,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: (bgColor ?? (isDark ? const Color(0xFF1c1b1e) : Colors.white))
            .withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (bgColor ?? (isDark ? const Color(0xFF363436) : const Color(0xFFE2E8F0)))
              .withValues(alpha: 0.8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color ?? (isDark ? AppTheme.accentNeon : const Color(0xFF2563EB))),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color ?? (isDark ? Colors.white : const Color(0xFF1E293B)),
            ),
          ),
        ],
      ),
    );
  }

  // ── Map Control Button ────────────────────────────────────────────

  Widget _mapControlButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: (isDark ? const Color(0xFF1c1b1e) : Colors.white).withValues(alpha: 0.92),
        shape: BoxShape.circle,
        border: Border.all(color: isDark ? const Color(0xFF363436) : const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, size: 20, color: isDark ? Colors.white70 : const Color(0xFF374151)),
        onPressed: onTap,
        padding: EdgeInsets.zero,
      ),
    );
  }
}

// ── Bottom Card ────────────────────────────────────────────────────────

class _RoutePreviewBottomCard extends StatelessWidget {
  final dynamic selected;
  final dynamic altRoute;
  final List<dynamic> routes;
  final bool isDark;
  final Function(dynamic) onSelectRoute;
  final VoidCallback onStart;
  final VoidCallback onWeatherTap;

  const _RoutePreviewBottomCard({
    required this.selected,
    required this.altRoute,
    required this.routes,
    required this.isDark,
    required this.onSelectRoute,
    required this.onStart,
    required this.onWeatherTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 0,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141315) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.12),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          const SizedBox(height: 16),

          // Selected route summary
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    TimeUtils.formatMinutes(selected.durationMinutes),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.accentNeon,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${selected.distanceKm.toStringAsFixed(0)} km  •  ETA ${TimeUtils.calculateEta(durationMinutes: selected.durationMinutes)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white60 : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFD1FAE5).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF059669).withValues(alpha: 0.3)),
                ),
                child: Text(
                  selected.trafficLevel.toUpperCase(),
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF059669)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Weather + waypoint strip
          Row(
            children: [
              Expanded(
                child: _infoChip(
                  context,
                  icon: Symbols.sunny,
                  iconColor: const Color(0xFFF59E0B),
                  text: '31°C Clear  •  Visibility 10 km',
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _infoChip(
                  context,
                  icon: Symbols.route,
                  iconColor: AppTheme.accentNeon,
                  text: 'Dhaka → Sonargaon → Destination',
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Route selector
          _RouteOptionCard(
            route: selected,
            isSelected: true,
            isDark: isDark,
            tag: const TagData('FASTEST', Color(0xFF059669), Color(0xFFD1FAE5)),
            onTap: () => onSelectRoute(selected),
          ),
          const SizedBox(height: 8),
          _RouteOptionCard(
            route: altRoute,
            isSelected: false,
            isDark: isDark,
            tag: TagData('+${(altRoute.durationMinutes - selected.durationMinutes)} MIN', const Color(0xFF64748B), const Color(0xFFF1F5F9)),
            onTap: () => onSelectRoute(altRoute),
          ),
          const SizedBox(height: 12),

          // POI teaser
          GestureDetector(
            onTap: onWeatherTap,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1c1b1e) : const Color(0xFFF8FAF9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? const Color(0xFF363436) : const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Icon(Symbols.explore, size: 18, color: const Color(0xFF2563EB)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '3 Rest stops and 2 scenic waypoints detected',
                      style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : const Color(0xFF475569)),
                    ),
                  ),
                  Text(
                    'View',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // CTA
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: onStart,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Symbols.navigation, size: 20, color: AppTheme.accentNeon),
                  SizedBox(width: 8),
                  Text(
                    'Start Navigation',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoChip(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String text,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1c1b1e) : const Color(0xFFF8FAF9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isDark ? const Color(0xFF363436) : const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 15, color: iconColor),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class TagData {
  final String label;
  final Color bgColor;
  final Color textColor;
  const TagData(this.label, this.bgColor, this.textColor);
}

class _RouteOptionCard extends StatelessWidget {
  final dynamic route;
  final bool isSelected;
  final bool isDark;
  final TagData tag;
  final VoidCallback onTap;

  const _RouteOptionCard({
    required this.route,
    required this.isSelected,
    required this.isDark,
    required this.tag,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF1c1b1e) : const Color(0xFFF0FDF4))
              : (isDark ? const Color(0xFF141315) : const Color(0xFFF8FAF9)),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppTheme.accentNeon : (isDark ? const Color(0xFF363436) : const Color(0xFFE2E8F0)),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: tag.bgColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                tag.label,
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: tag.textColor),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    route.title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    route.viaCorridor,
                    style: TextStyle(fontSize: 11, color: isDark ? Colors.white54 : const Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  TimeUtils.formatMinutes(route.durationMinutes),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.accentNeon),
                ),
                Text(
                  '${route.distanceKm.toStringAsFixed(0)} km',
                  style: TextStyle(fontSize: 11, color: isDark ? Colors.white38 : const Color(0xFF94A3B8)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Route path painter ─────────────────────────────────────────────────────────

class _RoutePreviewPainter extends CustomPainter {
  final dynamic selected;
  final dynamic alternate;
  final bool isDark;
  final double pulse;

  _RoutePreviewPainter({
    required this.selected,
    required this.alternate,
    required this.isDark,
    required this.pulse,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final altPath = Path();
    altPath.moveTo(size.width * 0.22, size.height * 0.85);
    altPath.cubicTo(
      size.width * 0.38, size.height * 0.68,
      size.width * 0.28, size.height * 0.48,
      size.width * 0.55, size.height * 0.35,
    );
    altPath.cubicTo(
      size.width * 0.72, size.height * 0.25,
      size.width * 0.80, size.height * 0.18,
      size.width * 0.90, size.height * 0.12,
    );
    final altDashPaint = Paint()
      ..color = (isDark ? const Color(0xFF504251) : const Color(0xFF94A3B8)).withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(altPath, altDashPaint);

    final mainPath = Path();
    mainPath.moveTo(size.width * 0.25, size.height * 0.82);
    mainPath.cubicTo(
      size.width * 0.40, size.height * 0.65,
      size.width * 0.35, size.height * 0.45,
      size.width * 0.55, size.height * 0.32,
    );
    mainPath.cubicTo(
      size.width * 0.72, size.height * 0.22,
      size.width * 0.80, size.height * 0.15,
      size.width * 0.88, size.height * 0.10,
    );

    canvas.drawPath(
      mainPath,
      Paint()
        ..color = AppTheme.accentNeon.withValues(alpha: isDark ? 0.25 : 0.18)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 16.0
        ..strokeCap = StrokeCap.round,
    );

    canvas.drawPath(
      mainPath,
      Paint()
        ..color = AppTheme.accentNeon
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0
        ..strokeCap = StrokeCap.round,
    );

    _drawChevrons(canvas, mainPath, size, isDark);

    final start = Offset(size.width * 0.25, size.height * 0.82);
    final waveR = 14.0 + (pulse * 28.0);
    canvas.drawCircle(
      start,
      waveR,
      Paint()
        ..color = AppTheme.accentNeon.withValues(alpha: (1.0 - pulse).clamp(0.0, 1.0) * 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );
    canvas.drawCircle(start, 8.0, Paint()..color = const Color(0xFF059669));
    canvas.drawCircle(start, 4.0, Paint()..color = Colors.white);

    final dest = Offset(size.width * 0.88, size.height * 0.10);
    canvas.drawCircle(dest, 10.0, Paint()..color = const Color(0xFF7C3AED));
    canvas.drawCircle(dest, 6.0, Paint()..color = Colors.white);
  }

  void _drawChevrons(Canvas canvas, Path path, Size size, bool isDark) {
    final steps = 8;
    for (int i = 1; i < steps; i++) {
      final t = i / steps;
      final p = _cubicPoint(t,
        p0: Offset(size.width * 0.25, size.height * 0.82),
        p1: Offset(size.width * 0.40, size.height * 0.65),
        p2: Offset(size.width * 0.35, size.height * 0.45),
        p3: Offset(size.width * 0.55, size.height * 0.32),
      );
      final pNext = _cubicPoint((i + 1) / steps,
        p0: Offset(size.width * 0.25, size.height * 0.82),
        p1: Offset(size.width * 0.40, size.height * 0.65),
        p2: Offset(size.width * 0.35, size.height * 0.45),
        p3: Offset(size.width * 0.55, size.height * 0.32),
      );
      final angle = _angle(p, pNext);
      _drawChevron(canvas, p, angle, isDark);
    }
    for (int i = 1; i < steps; i++) {
      final t = i / steps;
      final p = _cubicPoint(t,
        p0: Offset(size.width * 0.55, size.height * 0.32),
        p1: Offset(size.width * 0.72, size.height * 0.22),
        p2: Offset(size.width * 0.80, size.height * 0.15),
        p3: Offset(size.width * 0.88, size.height * 0.10),
      );
      final pNext = _cubicPoint((i + 1) / steps,
        p0: Offset(size.width * 0.55, size.height * 0.32),
        p1: Offset(size.width * 0.72, size.height * 0.22),
        p2: Offset(size.width * 0.80, size.height * 0.15),
        p3: Offset(size.width * 0.88, size.height * 0.10),
      );
      final angle = _angle(p, pNext);
      _drawChevron(canvas, p, angle, isDark);
    }
  }

  void _drawChevron(Canvas canvas, Offset pos, double angle, bool isDark) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.7)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final s = 5.0;
    final perp = angle + math.pi / 2;
    canvas.drawLine(
      pos + Offset(-s * math.cos(angle), -s * math.sin(angle)),
      pos + Offset(s * math.cos(angle), s * math.sin(angle)),
      paint,
    );
    canvas.drawLine(
      pos + Offset(-s * math.cos(angle) + s * 0.5 * math.cos(perp), -s * math.sin(angle) + s * 0.5 * math.sin(perp)),
      pos + Offset(-s * math.cos(angle) - s * 0.5 * math.cos(perp), -s * math.sin(angle) - s * 0.5 * math.sin(perp)),
      paint,
    );
  }

  Offset _cubicPoint(double t, {required Offset p0, required Offset p1, required Offset p2, required Offset p3}) {
    final u = 1 - t;
    return Offset(
      u * u * u * p0.dx + 3 * u * u * t * p1.dx + 3 * u * t * t * p2.dx + t * t * t * p3.dx,
      u * u * u * p0.dy + 3 * u * u * t * p1.dy + 3 * u * t * t * p2.dy + t * t * t * p3.dy,
    );
  }

  double _angle(Offset from, Offset to) {
    return math.atan2(to.dy - from.dy, to.dx - from.dx);
  }

  @override
  bool shouldRepaint(covariant _RoutePreviewPainter oldDelegate) =>
      oldDelegate.selected != selected ||
      oldDelegate.alternate != alternate ||
      oldDelegate.isDark != isDark ||
      oldDelegate.pulse != pulse;
}
