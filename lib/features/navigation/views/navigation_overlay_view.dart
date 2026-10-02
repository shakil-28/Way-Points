import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/time_utils.dart';
import '../controllers/navigation_controller.dart';
import '../models/maneuver_model.dart';

/// Floating turn maneuver card with lane guide and current speed readout leveraging Provider
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

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Maneuver HUD Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1B1A1E) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Maneuver Icon
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.accentNeon, width: 2),
                    ),
                    child: Icon(
                      _getTurnIcon(maneuver.direction),
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Distance & Instruction
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
                            color: AppTheme.accentNeon,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          maneuver.instruction,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Simulated Speedometer
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.darkCard : AppTheme.lightCanvas,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${navCtrl.currentSpeedKmh.round()}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.accentNeon,
                          ),
                        ),
                        const Text(
                          'km/h',
                          style: TextStyle(fontSize: 9, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Bottom Trip Telemetry Capsule
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1B1A1E) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // ETA and distance remaining
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        TimeUtils.formatMinutes(navCtrl.remainingTimeMinutes),
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${navCtrl.remainingDistanceKm.toStringAsFixed(1)} km left',
                        style: TextStyle(fontSize: 11, color: isDark ? Colors.white54 : Colors.black45),
                      ),
                    ],
                  ),
                  // Sound mute & exit
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          navCtrl.isMuted ? Symbols.volume_off : Symbols.volume_up,
                          color: navCtrl.isMuted ? Colors.red : AppTheme.accentNeon,
                        ),
                        onPressed: navCtrl.toggleMute,
                      ),
                      IconButton(
                        icon: const Icon(Symbols.close, color: Colors.redAccent),
                        onPressed: onExit,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
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
