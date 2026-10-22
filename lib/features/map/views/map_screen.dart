import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/circular_floating_button.dart';
import '../controllers/map_controller.dart';
import '../models/map_state_model.dart';
import '../../discovery/controllers/discovery_controller.dart';
import '../../discovery/views/poi_details_sheet.dart';
import '../../routing/views/route_preview_view.dart';
import '../../navigation/controllers/navigation_controller.dart';
import '../../navigation/views/navigation_overlay_view.dart';
import '../../navigation/views/navigation_bottom_sheet.dart';
import '../../navigation/views/navigation_poi_badge.dart';
import '../../location/controllers/location_controller.dart';
import '../../../core/config/app_routes.dart';
import 'map_view.dart';

/// Screen 3 & Core Navigation Hub: Home Explore Map with floating map controls positioned on the lower right
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
  bool _showPoiSheet = false; // Hidden by default in initial Explore mode
  bool _showNavSheet = false; // Hidden by default in Navigation mode until POI is tapped

  final DraggableScrollableController _navSheetController = DraggableScrollableController();
  final ValueNotifier<int> _navSnapIndex = ValueNotifier<int>(0);
  static const List<double> _navSnapSizes = <double>[0.25, 0.50, 0.80];

  @override
  void initState() {
    super.initState();
    _navSheetController.addListener(_handleNavSheetChanged);
  }

  @override
  void dispose() {
    _navSheetController.removeListener(_handleNavSheetChanged);
    _navSheetController.dispose();
    _navSnapIndex.dispose();
    super.dispose();
  }

  void _handleNavSheetChanged() {
    if (!_navSheetController.isAttached) return;

    final double extent = _navSheetController.size;

    int closestIndex = 0;
    double smallestDistance = double.infinity;

    for (int i = 0; i < _navSnapSizes.length; i++) {
      final double distance = (extent - _navSnapSizes[i]).abs();
      if (distance < smallestDistance) {
        smallestDistance = distance;
        closestIndex = i;
      }
    }

    if (_navSnapIndex.value != closestIndex) {
      _navSnapIndex.value = closestIndex;
    }
  }

  void _recenterToLiveLocation(MapController controller) {
    controller.setAutoFollow(true);
    final locationCtrl = context.read<LocationController>();
    if (locationCtrl.isLocationUpdated) {
      controller.panTo(locationCtrl.state.latitude, locationCtrl.state.longitude, zoom: 15.0);
    } else {
      locationCtrl.requestPermission().then((_) {
        if (locationCtrl.isLocationUpdated) {
          controller.panTo(locationCtrl.state.latitude, locationCtrl.state.longitude, zoom: 15.0);
        } else {
          controller.resetToDhakaCenter();
        }
      });
    }
  }

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
    final primaryTextColor = isDark ? Colors.white : AppTheme.textPrimary;
    final secondaryTextColor = isDark ? Colors.white60 : const Color(0xFF475569);
    final borderColor = isDark ? AppTheme.darkBorder : AppTheme.lightBorder;

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
                  if (mode == MapScreenMode.navigation) {
                    _showNavSheet = true;
                  } else {
                    _showPoiSheet = true;
                  }
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
                          AppStrings.whereToQuestion,
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

            // Lower Right Floating Tool Controls (Layers, Compass, Recenter)
            Positioned(
              right: 16,
              bottom: _showPoiSheet ? 280 : 100,
              child: Column(
                children: [
                  CircularFloatingButton(
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
                  CircularFloatingButton(
                    icon: Symbols.explore,
                    iconColor: AppTheme.primaryGreen,
                    isDark: isDark,
                    onTap: controller.zoomIn,
                  ),
                  const SizedBox(height: 12),
                  CircularFloatingButton(
                    icon: Symbols.my_location,
                    iconColor: AppTheme.primaryGreen,
                    isDark: isDark,
                    showActiveDot: true,
                    onTap: () => _recenterToLiveLocation(controller),
                  ),
                ],
              ),
            ),

            // Speed & Live Corridor Status Badge (Bottom Left)
            Positioned(
              left: 16,
              bottom: _showPoiSheet ? 280 : 100,
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

            // Bottom Draggable Discovery Sheet (Only shown when a POI pin is tapped)
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

            // Lower Right Floating Map Tool Controls (Recenter, Layers)
            Positioned(
              right: 16,
              bottom: 280,
              child: Column(
                children: [
                  CircularFloatingButton(
                    icon: Symbols.my_location,
                    iconColor: AppTheme.primaryGreen,
                    isDark: isDark,
                    onTap: () => _recenterToLiveLocation(controller),
                  ),
                  const SizedBox(height: 12),
                  CircularFloatingButton(
                    icon: Symbols.layers,
                    isDark: isDark,
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
                  setState(() {
                    _showNavSheet = false;
                  });
                  controller.startNavigation();
                },
              ),
            ),
          ],

          // -------------------------------------------------------------------
          // 3. ACTIVE NAVIGATION MODE OVERLAYS
          // -------------------------------------------------------------------
          if (mode == MapScreenMode.navigation) ...[
            // Simplified Top Turn Maneuver & Telemetry HUD Card
            Positioned(
              top: topPadding + 10,
              left: 0,
              right: 0,
              child: NavigationOverlayView(
                controller: navCtrl,
                onExit: () {
                  navCtrl.stopNavigation();
                  setState(() {
                    _showNavSheet = false;
                  });
                  controller.showExplore();
                },
              ),
            ),

            // Interactive Corridor Testing POI Badges along route
            Positioned(
              top: topPadding + 150,
              left: 16,
              child: NavigationPoiBadge(
                icon: Symbols.account_balance,
                label: 'Savar Monument (+8m)',
                iconColor: const Color(0xFF047857),
                showPulse: true,
                isDark: isDark,
                onTap: () {
                  setState(() {
                    _showNavSheet = true;
                  });
                },
              ),
            ),
            Positioned(
              top: topPadding + 210,
              right: 16,
              child: NavigationPoiBadge(
                icon: Symbols.mosque,
                label: 'Heritage Mosque (+5m)',
                iconColor: const Color(0xFF0F766E),
                isDark: isDark,
                onTap: () {
                  setState(() {
                    _showNavSheet = true;
                  });
                },
              ),
            ),
            Positioned(
              top: topPadding + 270,
              left: 24,
              child: NavigationPoiBadge(
                icon: Symbols.park,
                label: 'Bhawal Reserve (+12m)',
                iconColor: const Color(0xFF15803D),
                isDark: isDark,
                onTap: () {
                  setState(() {
                    _showNavSheet = true;
                  });
                },
              ),
            ),

            // Lower Right Floating Map Tool Controls (Hazard Report, Layers, Compass, Recenter)
            Positioned(
              right: 16,
              bottom: _showNavSheet ? 280 : 100,
              child: Column(
                children: [
                  // Hazard Report Button
                  CircularFloatingButton(
                    icon: Symbols.report_problem,
                    iconColor: Colors.amber,
                    isDark: isDark,
                    onTap: () => _showHazardReportSheet(context, isDark),
                  ),
                  const SizedBox(height: 12),
                  CircularFloatingButton(
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
                  CircularFloatingButton(
                    icon: Symbols.explore,
                    iconColor: AppTheme.primaryGreen,
                    isDark: isDark,
                    onTap: controller.zoomIn,
                  ),
                  const SizedBox(height: 12),
                  CircularFloatingButton(
                    icon: Symbols.my_location,
                    iconColor: AppTheme.primaryGreen,
                    isDark: isDark,
                    showActiveDot: true,
                    onTap: () => _recenterToLiveLocation(controller),
                  ),
                ],
              ),
            ),

            // Bottom Draggable Navigation Dashboard Sheet (Active when POI is tapped)
            if (_showNavSheet)
              Positioned.fill(
                child: DraggableScrollableSheet(
                  controller: _navSheetController,
                  initialChildSize: 0.25,
                  minChildSize: 0.25,
                  maxChildSize: 0.80,
                  snap: true,
                  snapSizes: _navSnapSizes,
                  snapAnimationDuration: const Duration(milliseconds: 260),
                  builder: (context, scrollController) {
                    return NavigationBottomSheet(
                      scrollController: scrollController,
                      navCtrl: navCtrl,
                      isDark: isDark,
                      currentSnapIndexListenable: _navSnapIndex,
                      snapSizes: _navSnapSizes,
                      onPitStopAdd: (title) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('$title added to route. Corridor metrics updated.'),
                            backgroundColor: AppTheme.primaryGreen,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      onConfirmExit: () {
                        setState(() {
                          _showNavSheet = false;
                        });
                      },
                    );
                  },
                ),
              ),
          ],
        ],
      ),
    );
  }

  void _showHazardReportSheet(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final hazards = [
          {'title': 'Police Checkpoint', 'icon': Symbols.local_police, 'color': Colors.blue},
          {'title': 'Heavy Traffic Congestion', 'icon': Symbols.traffic, 'color': Colors.amber},
          {'title': 'Road Construction / Detour', 'icon': Symbols.construction, 'color': Colors.orange},
          {'title': 'Accident / Vehicle Breakdown', 'icon': Symbols.car_crash, 'color': Colors.redAccent},
        ];

        return Material(
          color: isDark ? AppTheme.darkCard : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: Padding(
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
                  return ListTile(
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
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}
