import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/widgets/circular_floating_button.dart';
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
        CircularFloatingButton(
          icon: Symbols.explore,
          onTap: onCompassTap,
          isDark: isDark,
          size: 48,
          iconSize: 23,
        ),
        const SizedBox(height: 10),
        CircularFloatingButton(
          icon: navCtrl.isMuted ? Symbols.volume_off : Symbols.volume_up,
          iconColor: navCtrl.isMuted ? red : (isDark ? Colors.white : const Color(0xFF334155)),
          onTap: onMuteTap,
          isDark: isDark,
          size: 48,
          iconSize: 23,
        ),
        const SizedBox(height: 10),
        CircularFloatingButton(
          icon: Symbols.warning,
          iconColor: amber,
          onTap: onHazardTap,
          isDark: isDark,
          size: 48,
          iconSize: 23,
        ),
      ],
    );
  }
}
