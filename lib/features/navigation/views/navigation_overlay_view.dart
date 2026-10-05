import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/time_utils.dart';
import '../controllers/navigation_controller.dart';
import '../models/maneuver_model.dart';

/// PRD Screen 6: Floating Turn Maneuver Card with Speed Limit Badge, Road Hazard Picker Control, and Telemetry
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
                    color: Colors.black.withValues(alpha: 0.22),
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
                  const SizedBox(width: 14),

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
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Speedometer & Speed Limit Badge Row
                  Column(
                    children: [
                      // Current Speed readout
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
                                color: AppTheme.accentNeon,
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

                      // Speed Limit Badge (PRD Screen 6)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red.shade900.withValues(alpha: 0.2),
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
            ),

            const SizedBox(height: 8),

            // Bottom Trip Telemetry & Quick Hazard Control Capsule
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1B1A1E) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // ETA, Distance, & Battery/Signal metrics
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        TimeUtils.formatMinutes(navCtrl.remainingTimeMinutes),
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          Text(
                            '${navCtrl.remainingDistanceKm.toStringAsFixed(1)} km left',
                            style: TextStyle(fontSize: 11, color: isDark ? Colors.white54 : Colors.black45),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Symbols.battery_charging_90, size: 12, color: AppTheme.accentNeon),
                          const SizedBox(width: 2),
                          const Text('92%', style: TextStyle(fontSize: 10, color: Colors.grey)),
                          const SizedBox(width: 6),
                          const Icon(Symbols.signal_cellular_4_bar, size: 12, color: AppTheme.accentNeon),
                          const Text(' 5G', style: TextStyle(fontSize: 10, color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),

                  // Actions: Report Hazard / Mute / Exit
                  Row(
                    children: [
                      // Hazard Report Picker Button (PRD Screen 6)
                      IconButton(
                        icon: const Icon(Symbols.report_problem, color: Colors.amber, size: 20),
                        tooltip: 'Report Hazard / Police',
                        onPressed: () => _showHazardReportSheet(context, isDark),
                      ),
                      IconButton(
                        icon: Icon(
                          navCtrl.isMuted ? Symbols.volume_off : Symbols.volume_up,
                          color: navCtrl.isMuted ? Colors.red : AppTheme.accentNeon,
                          size: 20,
                        ),
                        onPressed: navCtrl.toggleMute,
                      ),
                      IconButton(
                        icon: const Icon(Symbols.close, color: Colors.redAccent, size: 20),
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

  void _showHazardReportSheet(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final hazards = [
          {'title': 'Police Checkpoint', 'icon': Symbols.local_police, 'color': Colors.blue},
          {'title': 'Heavy Traffic Congestion', 'icon': Symbols.traffic, 'color': Colors.amber},
          {'title': 'Road Construction / Detour', 'icon': Symbols.construction, 'color': Colors.orange},
          {'title': 'Accident / Vehicle Breakdown', 'icon': Symbols.car_crash, 'color': Colors.redAccent},
        ];

        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'REPORT HIGHWAY HAZARD',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                  color: isDark ? Colors.white54 : Colors.black54,
                ),
              ),
              const SizedBox(height: 14),
              ...hazards.map((h) {
                return Material(
                  color: Colors.transparent,
                  child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: (h['color'] as Color).withValues(alpha: 0.15),
                    child: Icon(h['icon'] as IconData, color: h['color'] as Color, size: 20),
                  ),
                  title: Text(h['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  trailing: const Icon(Symbols.arrow_forward_ios, size: 14),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Reported "${h['title']}" to WayPoint corridor drivers!'),
                        backgroundColor: AppTheme.primaryGreen,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  ),
                );
              }),
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
