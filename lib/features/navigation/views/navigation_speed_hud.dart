import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../controllers/navigation_controller.dart';

/// Navigation Live Speed & Speed Limit HUD
class NavigationSpeedHud extends StatelessWidget {
  final NavigationController navCtrl;
  final bool isDark;

  const NavigationSpeedHud({
    super.key,
    required this.navCtrl,
    required this.isDark,
  });

  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color red = Color(0xFFDC2626);
  static const Color borderColor = Color(0xFFE2E8F0);

  @override
  Widget build(BuildContext context) {
    final speed = navCtrl.currentSpeedKmh.round();
    final limit = navCtrl.currentManeuver.speedLimitKmh.round();

    return Material(
      color: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              color: (isDark ? AppTheme.darkCard : Colors.white).withValues(alpha: 0.96),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppTheme.darkBorder : borderColor,
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  '$speed',
                  style: TextStyle(
                    fontSize: 31,
                    height: 1,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : textPrimary,
                    letterSpacing: -1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'KM/H',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white60 : textSecondary,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? AppTheme.darkCard : Colors.white,
              border: Border.all(color: const Color(0xFFEF4444), width: 2.2),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.10),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  '$limit',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'LIMIT',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                    color: red,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
