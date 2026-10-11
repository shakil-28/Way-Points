import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/geoutils.dart';
import '../controllers/navigation_controller.dart';
import '../models/maneuver_model.dart';

/// Sleek, Compact, and Non-Clipping Turn-by-Turn Maneuver HUD Card
class NavigationManeuverCard extends StatelessWidget {
  final NavigationController navCtrl;
  final bool isDark;

  const NavigationManeuverCard({
    super.key,
    required this.navCtrl,
    required this.isDark,
  });

  static const Color textPrimary = AppTheme.textPrimary;
  static const Color textSecondary = AppTheme.textSecondary;
  static const Color emerald = AppTheme.primaryGreen;
  static const Color borderColor = AppTheme.lightBorder;

  String _cleanInstruction(String text) {
    return text.replaceAll(RegExp(r'^In \d+\s*(meters|m|km),\s*', caseSensitive: false), '');
  }

  @override
  Widget build(BuildContext context) {
    final maneuver = navCtrl.currentManeuver;
    final icon = _maneuverIcon(maneuver.direction);
    final cleanText = _cleanInstruction(maneuver.instruction);

    return Material(
      color: Colors.transparent,
      elevation: 0,
      child: InkWell(
        onTap: () => navCtrl.nextManeuver(),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: (isDark ? AppTheme.darkCard : Colors.white).withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? AppTheme.darkBorder : borderColor,
              width: 1.2,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: <Widget>[
              // Compact Turn Icon Badge
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: emerald,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: emerald.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),

              // Distance Countdown & Clean Maneuver Instruction
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'IN ${GeoUtils.formatDistance(maneuver.distanceMeters / 1000.0).toUpperCase()}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      cleanText,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                        color: isDark ? Colors.white : textPrimary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Lane Indicator Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark ? AppTheme.darkBorder : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(icon, size: 14, color: AppTheme.primaryGreen),
                    const SizedBox(width: 4),
                    Text(
                      maneuver.laneIndicator.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white70 : textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _maneuverIcon(TurnDirection direction) {
    switch (direction) {
      case TurnDirection.turnLeft:
        return Symbols.turn_left;
      case TurnDirection.slightLeft:
        return Symbols.turn_slight_left;
      case TurnDirection.turnRight:
        return Symbols.turn_right;
      case TurnDirection.slightRight:
        return Symbols.turn_slight_right;
      case TurnDirection.sharpRight:
        return Symbols.turn_sharp_right;
      case TurnDirection.uTurn:
        return Symbols.u_turn_left;
      case TurnDirection.merge:
        return Symbols.merge;
      case TurnDirection.exitRoundabout:
        return Symbols.roundabout_right;
      case TurnDirection.arrive:
        return Symbols.location_on;
      case TurnDirection.straight:
        return Symbols.straight;
    }
  }
}
