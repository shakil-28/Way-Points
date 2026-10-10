import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/geoutils.dart';
import '../controllers/navigation_controller.dart';
import '../models/maneuver_model.dart';

/// Navigation Turn-by-Turn Maneuver HUD Card
class NavigationManeuverCard extends StatelessWidget {
  final NavigationController navCtrl;
  final bool isDark;

  const NavigationManeuverCard({
    super.key,
    required this.navCtrl,
    required this.isDark,
  });

  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color emerald = AppTheme.primaryGreen;
  static const Color emeraldLight = Color(0xFFECFDF5);
  static const Color borderColor = Color(0xFFE2E8F0);

  @override
  Widget build(BuildContext context) {
    final maneuver = navCtrl.currentManeuver;
    final icon = _maneuverIcon(maneuver.direction);

    return Material(
      color: Colors.transparent,
      elevation: 0,
      child: InkWell(
        onTap: () => navCtrl.nextManeuver(),
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
          decoration: BoxDecoration(
            color: (isDark ? AppTheme.darkCard : Colors.white).withValues(alpha: 0.98),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark ? AppTheme.darkBorder : borderColor,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.14),
                blurRadius: 22,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: emerald,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: emerald.withValues(alpha: 0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 34,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'In ${GeoUtils.formatDistance(maneuver.distanceMeters / 1000.0)}',
                          style: TextStyle(
                            fontSize: 26,
                            height: 1.05,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : textPrimary,
                            letterSpacing: -0.8,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          maneuver.streetName.isNotEmpty
                              ? maneuver.streetName
                              : maneuver.instruction,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.3,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white70 : textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 11),
              Container(
                height: 1,
                color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
              ),
              const SizedBox(height: 8),
              Row(
                children: <Widget>[
                  _buildLane(Symbols.straight, active: false, isDark: isDark),
                  const SizedBox(width: 4),
                  _buildLane(icon, active: true, isDark: isDark),
                  const SizedBox(width: 4),
                  _buildLane(Symbols.straight, active: true, isDark: isDark),
                  const SizedBox(width: 4),
                  _buildLane(Symbols.turn_right, active: false, isDark: isDark),
                  const Spacer(),
                  Flexible(
                    child: Text(
                      maneuver.laneIndicator.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white60 : textSecondary,
                        letterSpacing: 0.7,
                      ),
                    ),
                  ),
                ],
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

  Widget _buildLane(
    IconData icon, {
    required bool active,
    required bool isDark,
  }) {
    return Container(
      width: 34,
      height: 40,
      decoration: BoxDecoration(
        color: active
            ? (isDark ? emerald.withValues(alpha: 0.25) : emeraldLight)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: active
            ? Border.all(
                color: isDark ? emerald.withValues(alpha: 0.6) : const Color(0xFFA7F3D0),
              )
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            icon,
            size: 16,
            color: active
                ? (isDark ? const Color(0xFF6EE7B7) : const Color(0xFF047857))
                : (isDark ? Colors.white38 : const Color(0xFF94A3B8)),
          ),
          const SizedBox(height: 2),
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active ? emerald : (isDark ? Colors.white24 : const Color(0xFFCBD5E1)),
            ),
          ),
        ],
      ),
    );
  }
}
