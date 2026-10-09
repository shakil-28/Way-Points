import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/time_utils.dart';
import '../controllers/navigation_controller.dart';
import '../models/maneuver_model.dart';

/// Simplified & Clean Navigation Top HUD Card with Maneuver Instruction, Speedometer, Distance/ETA, and Exit Action
class NavigationOverlayView extends StatelessWidget {
  final NavigationController? controller;
  final VoidCallback onExit;

  const NavigationOverlayView({
    super.key,
    this.controller,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    final navCtrl = controller ?? context.watch<NavigationController>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: navCtrl,
      builder: (context, _) {
        final maneuver = navCtrl.currentManeuver;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1B1A1E) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.12),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top Row: Maneuver Icon, Instruction & Speedometer
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Maneuver Turn Direction Icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.accentNeon, width: 1.5),
                    ),
                    child: Icon(
                      _getTurnIcon(maneuver.direction),
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Distance Countdown & Next Turn Instruction
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'IN ${maneuver.distanceMeters} METERS',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            color: AppTheme.primaryGreen,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          maneuver.instruction,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Speedometer & Speed Limit Badge Column
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark ? AppTheme.darkCard : AppTheme.lightCanvas,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '${navCtrl.currentSpeedKmh.round()}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryGreen,
                              ),
                            ),
                            const Text(
                              'km/h',
                              style: TextStyle(fontSize: 8, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Speed Limit Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red.shade900.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.redAccent, width: 1.2),
                        ),
                        child: Text(
                          'LIMIT ${maneuver.speedLimitKmh.round()}',
                          style: const TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: Colors.redAccent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 10),
              Divider(height: 1, color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
              const SizedBox(height: 8),

              // Bottom Row: Duration Left, Distance Left & Exit Action Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        TimeUtils.formatMinutes(navCtrl.remainingTimeMinutes),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '•  ${navCtrl.remainingDistanceKm.toStringAsFixed(1)} km left',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white70 : const Color(0xFF475569),
                        ),
                      ),
                    ],
                  ),

                  // Exit Navigation Button
                  IconButton(
                    icon: const Icon(Symbols.close, color: Colors.redAccent, size: 20),
                    tooltip: 'Exit Navigation',
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(4),
                    onPressed: onExit,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _getTurnIcon(TurnDirection direction) {
    switch (direction) {
      case TurnDirection.slightRight:
      case TurnDirection.turnRight:
      case TurnDirection.sharpRight:
        return Symbols.turn_right;
      case TurnDirection.slightLeft:
      case TurnDirection.turnLeft:
        return Symbols.turn_left;
      case TurnDirection.uTurn:
        return Symbols.u_turn_left;
      case TurnDirection.arrive:
        return Symbols.flag;
      case TurnDirection.straight:
      default:
        return Symbols.straight;
    }
  }
}
