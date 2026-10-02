import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../controllers/map_controller.dart';
import 'map_view.dart';

class MapScreen extends StatelessWidget {
  final MapController? mapController;
  final VoidCallback? onSearchTap;
  final VoidCallback? onNavigateTap;
  final VoidCallback? onLayersTap;

  const MapScreen({
    super.key,
    this.mapController,
    this.onSearchTap,
    this.onNavigateTap,
    this.onLayersTap,
  });

  @override
  Widget build(BuildContext context) {
    final controller = mapController ?? context.watch<MapController>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // Background Vector Map
          Positioned.fill(
            child: MapView(
              controller: controller,
              onMarkerTap: (poiId) => controller.selectPoi(poiId),
            ),
          ),

          // Floating Top Search Bar
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            right: 16,
            child: GestureDetector(
              onTap: onSearchTap,
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkCard.withOpacity(0.92) : Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Icon(Symbols.search, color: AppTheme.accentNeon, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Where to? Search Bengal corridors...',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white54 : Colors.black45,
                        ),
                      ),
                    ),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Symbols.mic, size: 18, color: AppTheme.accentNeon),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Right Floating Map Tool Controls (Zoom in, Zoom out, Recenter, Traffic)
          Positioned(
            right: 16,
            bottom: 120,
            child: Column(
              children: [
                _buildMapButton(
                  icon: Symbols.add,
                  tooltip: 'Zoom in',
                  isDark: isDark,
                  onTap: controller.zoomIn,
                ),
                const SizedBox(height: 8),
                _buildMapButton(
                  icon: Symbols.remove,
                  tooltip: 'Zoom out',
                  isDark: isDark,
                  onTap: controller.zoomOut,
                ),
                const SizedBox(height: 8),
                _buildMapButton(
                  icon: Symbols.my_location,
                  tooltip: 'Recenter to Dhaka',
                  isDark: isDark,
                  onTap: controller.resetToDhakaCenter,
                  color: AppTheme.accentNeon,
                ),
                const SizedBox(height: 8),
                _buildMapButton(
                  icon: Symbols.traffic,
                  tooltip: 'Toggle Traffic Overlay',
                  isDark: isDark,
                  onTap: controller.toggleTraffic,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapButton({
    required IconData icon,
    required String tooltip,
    required bool isDark,
    required VoidCallback onTap,
    Color? color,
  }) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard.withOpacity(0.9) : Colors.white.withOpacity(0.9),
        shape: BoxShape.circle,
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, size: 20, color: color ?? (isDark ? Colors.white70 : Colors.black87)),
        tooltip: tooltip,
        onPressed: onTap,
        padding: EdgeInsets.zero,
      ),
    );
  }
}
