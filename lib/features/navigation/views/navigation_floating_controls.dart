import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/theme/app_theme.dart';
import '../../map/controllers/map_controller.dart';
import '../controllers/navigation_controller.dart';

/// Navigation Floating Control Action Buttons (Compass, Audio Mute, Hazard Report)
class NavigationFloatingControls extends StatelessWidget {
  final NavigationController navCtrl;
  final MapController mapCtrl;
  final bool isDark;
  final bool isCompassAnimating;
  final VoidCallback onCompassTap;
  final VoidCallback onMuteTap;
  final VoidCallback onHazardTap;

  const NavigationFloatingControls({
    super.key,
    required this.navCtrl,
    required this.mapCtrl,
    required this.isDark,
    required this.isCompassAnimating,
    required this.onCompassTap,
    required this.onMuteTap,
    required this.onHazardTap,
  });

  static const Color red = Color(0xFFDC2626);
  static const Color amber = Color(0xFFD97706);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _buildFloatingButton(
          icon: Symbols.explore,
          onTap: onCompassTap,
          rotating: isCompassAnimating,
          isDark: isDark,
        ),
        const SizedBox(height: 10),
        _buildFloatingButton(
          icon: navCtrl.isMuted ? Symbols.volume_off : Symbols.volume_up,
          iconColor: navCtrl.isMuted ? red : (isDark ? Colors.white : const Color(0xFF334155)),
          onTap: onMuteTap,
          isDark: isDark,
        ),
        const SizedBox(height: 10),
        _buildFloatingButton(
          icon: Symbols.warning,
          iconColor: amber,
          onTap: onHazardTap,
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildFloatingButton({
    required IconData icon,
    required VoidCallback onTap,
    Color? iconColor,
    bool rotating = false,
    required bool isDark,
  }) {
    final effectiveColor = iconColor ?? (isDark ? Colors.white : const Color(0xFF334155));

    return AnimatedRotation(
      turns: rotating ? 0.5 : 0,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      child: Material(
        color: (isDark ? AppTheme.darkCard : Colors.white).withValues(alpha: 0.96),
        shape: const CircleBorder(),
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: isDark ? 0.35 : 0.18),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 48,
            height: 48,
            child: Icon(icon, size: 23, color: effectiveColor),
          ),
        ),
      ),
    );
  }
}
