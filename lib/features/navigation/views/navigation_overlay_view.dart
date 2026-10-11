import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/time_utils.dart';
import '../controllers/navigation_controller.dart';
import '../models/maneuver_model.dart';

/// Sleek, Compact, and Non-Clipping Navigation Top HUD Card
class NavigationOverlayView extends StatelessWidget {
  final NavigationController? controller;
  final VoidCallback onExit;

  const NavigationOverlayView({
    super.key,
    this.controller,
    required this.onExit,
  });

  String _cleanInstruction(String text) {
    return text.replaceAll(RegExp(r'^In \d+\s*(meters|m|km),\s*', caseSensitive: false), '');
  }

  @override
  Widget build(BuildContext context) {
    final navCtrl = controller ?? context.watch<NavigationController>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: navCtrl,
      builder: (context, _) {
        final maneuver = navCtrl.currentManeuver;
        final cleanText = _cleanInstruction(maneuver.instruction);

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: (isDark ? AppTheme.darkCard : Colors.white).withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Compact Turn Icon Badge
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryGreen.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  _getTurnIcon(maneuver.direction),
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),

              // Distance Countdown & Clean Next Turn Instruction
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'IN ${maneuver.distanceMeters.round()} M',
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
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                        color: isDark ? Colors.white : AppTheme.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Speed & Distance Summary Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkCanvas : AppTheme.lightCanvas,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${navCtrl.currentSpeedKmh.round()} km/h',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                    Text(
                      '${TimeUtils.formatMinutes(navCtrl.remainingTimeMinutes)} left',
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark ? Colors.white60 : AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 6),

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
