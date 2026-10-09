import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../controllers/map_controller.dart';
import '../models/map_state_model.dart';
import '../../discovery/controllers/discovery_controller.dart';
import '../../discovery/views/poi_details_sheet.dart';
import '../../routing/views/route_preview_view.dart';
import '../../navigation/controllers/navigation_controller.dart';
import '../../navigation/views/navigation_overlay_view.dart';
import '../../../core/config/app_routes.dart';
import 'map_view.dart';

/// Screen 3 & Core Navigation Hub: Home Explore Map rendering full screen without top header bars
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
  bool _showPoiSheet = true;

  @override
  Widget build(BuildContext context) {
    final controller = widget.mapController ?? context.watch<MapController>();
    final discoveryCtrl = context.watch<DiscoveryController>();
    final navCtrl = context.watch<NavigationController>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final mode = controller.screenMode;
    final topPadding = MediaQuery.of(context).padding.top;

    final cardBackgroundColor = isDark ? AppTheme.darkCard : Colors.white;
    final primaryTextColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor = isDark ? Colors.white60 : const Color(0xFF475569);
    final borderColor = isDark ? AppTheme.darkBorder : const Color(0xFFE2E8F0);

    return Scaffold(
      body: Stack(
        children: [
          // -------------------------------------------------------------------
          // 0. FULL-SCREEN BACKGROUND VECTOR MAP SUBSTRATE (Top = 0)
          // -------------------------------------------------------------------
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

          // -------------------------------------------------------------------
          // 1. EXPLORE MODE OVERLAYS
          // -------------------------------------------------------------------
          if (mode == MapScreenMode.explore) ...[
            // Floating Top Search Capsule
            Positioned(
              top: topPadding + 10,
              left: 16,
              right: 16,
              child: GestureDetector(
                onTap: widget.onSearchTap ?? () => context.go(AppRoutes.search),
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: cardBackgroundColor.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(color: borderColor),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.08),
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

            // Right Floating Tool Controls (Layers, Compass, Recenter)
            Positioned(
              right: 16,
              top: topPadding + 80,
              child: Column(
                children: [
                  _buildMapToolButton(
                    icon: Symbols.layers,
                    isDark: isDark,
                    cardBackgroundColor: cardBackgroundColor,
                    borderColor: borderColor,
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
                    cardBackgroundColor: cardBackgroundColor,
                    borderColor: borderColor,
                    onTap: controller.zoomIn,
                  ),
                  const SizedBox(height: 12),
                  _buildMapToolButton(
                    icon: Symbols.my_location,
                    iconColor: AppTheme.primaryGreen,
                    isDark: isDark,
                    cardBackgroundColor: cardBackgroundColor,
                    borderColor: borderColor,
                    showActiveDot: true,
                    onTap: controller.resetToDhakaCenter,
                  ),
                ],
              ),
            ),

            // Speed & Live Corridor Status Badge (Bottom Left)
            Positioned(
              left: 16,
              bottom: _showPoiSheet ? 260 : 30,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: cardBackgroundColor,
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

            // Bottom Draggable Discovery Sheet
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
                    controller.showRoutePreview();
                  },
                  onAddStop: () {
                    controller.showRoutePreview();
                  },
                ),
              ),
          ],

          // -------------------------------------------------------------------
          // 2. ROUTE PREVIEW MODE OVERLAYS
          // -------------------------------------------------------------------
          if (mode == MapScreenMode.routePreview) ...[
            // Route Options & Optimal Fuel Pills Row
            Positioned(
              top: topPadding + 10,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => controller.showExplore(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: cardBackgroundColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: borderColor),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.08),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(Symbols.arrow_back, size: 18, color: primaryTextColor),
                          const SizedBox(width: 6),
                          const Icon(Symbols.alt_route, size: 18, color: Colors.blueAccent),
                          const SizedBox(width: 6),
                          Text(
                            'Route Options',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: primaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6F7F0),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFA3E6D2)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Symbols.eco, size: 16, color: AppTheme.primaryGreen),
                        SizedBox(width: 6),
                        Text(
                          'OPTIMAL FUEL',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                            color: AppTheme.primaryGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Right Floating Map Tool Controls (Recenter, Layers)
            Positioned(
              right: 16,
              bottom: 280,
              child: Column(
                children: [
                  _buildMapToolButton(
                    icon: Symbols.my_location,
                    iconColor: AppTheme.primaryGreen,
                    isDark: isDark,
                    cardBackgroundColor: cardBackgroundColor,
                    borderColor: borderColor,
                    onTap: controller.resetToDhakaCenter,
                  ),
                  const SizedBox(height: 12),
                  _buildMapToolButton(
                    icon: Symbols.layers,
                    isDark: isDark,
                    cardBackgroundColor: cardBackgroundColor,
                    borderColor: borderColor,
                    onTap: () {
                      final nextMode = controller.state.layerMode == MapLayerMode.satellite
                          ? MapLayerMode.standard
                          : MapLayerMode.satellite;
                      controller.setLayerMode(nextMode);
                    },
                  ),
                ],
              ),
            ),

            // Bottom Route Preview Selection Overlay Sheet
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: RoutePreviewView(
                onStartNavigation: () {
                  if (!navCtrl.isNavigating) {
                    navCtrl.startNavigation();
                  }
                  controller.startNavigation();
                },
              ),
            ),
          ],

          // -------------------------------------------------------------------
          // 3. ACTIVE NAVIGATION MODE OVERLAYS
          // -------------------------------------------------------------------
          if (mode == MapScreenMode.navigation) ...[
            // Top Turn Maneuver HUD Card
            Positioned(
              top: topPadding + 10,
              left: 0,
              right: 0,
              child: NavigationOverlayView(
                controller: navCtrl,
                onExit: () {
                  navCtrl.stopNavigation();
                  controller.showExplore();
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMapToolButton({
    required IconData icon,
    required bool isDark,
    required Color cardBackgroundColor,
    required Color borderColor,
    required VoidCallback onTap,
    Color? iconColor,
    bool showActiveDot = false,
  }) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor),
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
