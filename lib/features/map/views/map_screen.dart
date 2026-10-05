import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../controllers/map_controller.dart';
import '../models/map_state_model.dart';
import '../../discovery/controllers/discovery_controller.dart';
import '../../discovery/views/poi_details_sheet.dart';
import '../../../core/config/app_routes.dart';
import 'map_view.dart';

/// Screen 3: Home & Discovery Map Page designed precisely according to HTML Specification
class MapScreen extends StatefulWidget {
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
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  bool _showPoiSheet = false;

  @override
  Widget build(BuildContext context) {
    final controller = widget.mapController ?? context.watch<MapController>();
    final discoveryCtrl = context.watch<DiscoveryController>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardBackgroundColor = isDark ? AppTheme.darkCard : Colors.white;
    final primaryTextColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor = isDark ? Colors.white60 : const Color(0xFF475569);
    final borderColor = isDark ? AppTheme.darkBorder : const Color(0xFFE2E8F0);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
          // Background Vector Map Substrate
          Positioned.fill(
            child: MapView(
              controller: controller,
              onMarkerTap: (poiId) {
                controller.selectPoi(poiId);
                discoveryCtrl.selectPoiById(poiId);
                setState(() {
                  _showPoiSheet = true;
                });
              },
            ),
          ),

          // Floating Top Search Bar on Map
          Positioned(
            top: 12,
            left: 16,
            right: 16,
            child: GestureDetector(
              onTap: widget.onSearchTap ?? () => context.go(AppRoutes.search),
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkCard : Colors.white,
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: borderColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Icon(Symbols.search, color: AppTheme.primaryGreen, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Where to in Dhaka?',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: secondaryTextColor,
                        ),
                      ),
                    ),
                    Icon(Symbols.mic, size: 20, color: secondaryTextColor),
                    const SizedBox(width: 8),
                    Container(width: 1, height: 20, color: borderColor),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE6F7F0),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFA3E6D2)),
                      ),
                      child: const Text(
                        'LIVE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Right Floating Map Tool Controls (Layers, Compass, Recenter)
          Positioned(
            right: 16,
            top: 140,
            child: Column(
              children: [
                _buildMapToolButton(
                  icon: Symbols.layers,
                  isDark: isDark,
                  onTap: () {
                    final nextMode = controller.state.layerMode == MapLayerMode.satellite
                        ? MapLayerMode.standard
                        : MapLayerMode.satellite;
                    controller.setLayerMode(nextMode);
                  },
                ),
                const SizedBox(height: 12),
                _buildMapToolButton(
                  icon: Symbols.explore,
                  iconColor: AppTheme.primaryGreen,
                  isDark: isDark,
                  onTap: controller.zoomIn,
                ),
                const SizedBox(height: 12),
                _buildMapToolButton(
                  icon: Symbols.my_location,
                  iconColor: AppTheme.primaryGreen,
                  isDark: isDark,
                  showActiveDot: true,
                  onTap: controller.resetToDhakaCenter,
                ),
              ],
            ),
          ),

          // Speed & Live Corridor Status Badge (Bottom Left on Map)
          Positioned(
            left: 16,
            bottom: _showPoiSheet ? 260 : 30,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '38 KM/H',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: primaryTextColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6F7F0),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFA3E6D2)),
                    ),
                    child: const Text(
                      'MIRPUR FLYOVER FLOW',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Draggable POI Discovery Sheet Overlay
          if (_showPoiSheet)
            Positioned.fill(
              child: PoiDetailsSheet(
                poi: discoveryCtrl.activePoi,
                onClose: () {
                  setState(() {
                    _showPoiSheet = false;
                  });
                },
                onNavigateDirectly: () {
                  context.push(AppRoutes.routePreview);
                },
                onAddStop: () {
                  context.push(AppRoutes.routePreview);
                },
              ),
            ),
        ],
      ),
      ),
    );
  }

  Widget _buildMapToolButton({
    required IconData icon,
    required bool isDark,
    required VoidCallback onTap,
    Color? iconColor,
    bool showActiveDot = false,
  }) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: isDark ? AppTheme.darkBorder : const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.1),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          IconButton(
            icon: Icon(icon, size: 22, color: iconColor ?? (isDark ? Colors.white70 : const Color(0xFF1E293B))),
            onPressed: onTap,
          ),
          if (showActiveDot)
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
