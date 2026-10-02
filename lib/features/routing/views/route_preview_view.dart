import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/time_utils.dart';
import '../../../core/utils/geoutils.dart';
import '../controllers/routing_controller.dart';
import '../models/route_model.dart';

/// Modal bottom sheet / card displaying corridor choices, tolls, distance, and start button
class RoutePreviewView extends StatelessWidget {
  final RoutingController? controller;
  final VoidCallback onStartNavigation;
  final VoidCallback? onCancel;

  const RoutePreviewView({
    super.key,
    this.controller,
    required this.onStartNavigation,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final routingCtrl = controller ?? context.watch<RoutingController>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: routingCtrl,
      builder: (context, _) {
        final selected = routingCtrl.selectedRoute;

        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkCard : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 24,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top handle
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.black12,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Selected route header & ETA
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          TimeUtils.formatMinutes(selected.durationMinutes),
                          style: theme.textTheme.displayLarge?.copyWith(
                            fontSize: 26,
                            color: AppTheme.accentNeon,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${GeoUtils.formatDistance(selected.distanceKm)} • ETA ${TimeUtils.calculateEta(durationMinutes: selected.durationMinutes)}',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.accentNeon.withOpacity(0.3)),
                      ),
                      child: Text(
                        selected.trafficLevel.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.accentNeon,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Route choices carousel/list
                ...routingCtrl.routes.map((route) {
                  final isSelected = route.id == selected.id;
                  return GestureDetector(
                    onTap: () => routingCtrl.selectRoute(route),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isDark ? const Color(0xFF262428) : const Color(0xFFE8F5EE))
                            : (isDark ? AppTheme.darkCanvas : AppTheme.lightCanvas),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.accentNeon
                              : (isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
                          width: isSelected ? 1.5 : 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            route.isScenic ? Symbols.park : Symbols.alt_route,
                            color: isSelected ? AppTheme.accentNeon : Colors.grey,
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  route.title,
                                  style: TextStyle(
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  route.viaCorridor,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark ? Colors.white60 : Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${route.durationMinutes}m',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              Text(
                                '৳${route.estimatedTollBdt.round()} toll',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark ? Colors.white38 : Colors.black38,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 12),

                // Start Navigation CTA
                ElevatedButton(
                  onPressed: onStartNavigation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 2,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Symbols.navigation, size: 20, color: AppTheme.accentNeon),
                      SizedBox(width: 8),
                      Text(
                        'Start Turn-by-Turn Navigation',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
