import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/context_header.dart';
import '../../map/controllers/map_controller.dart';
import '../controllers/navigation_controller.dart';
import 'navigation_map_view.dart';
import 'navigation_maneuver_card.dart';
import 'navigation_speed_hud.dart';
import 'navigation_poi_badge.dart';
import 'navigation_floating_controls.dart';
import 'navigation_bottom_sheet.dart';

/// Screen 7: Active Turn-by-Turn Navigation Screen Orchestrator
class ActiveNavigationScreen extends StatefulWidget {
  const ActiveNavigationScreen({super.key});

  @override
  State<ActiveNavigationScreen> createState() => _ActiveNavigationScreenState();
}

class _ActiveNavigationScreenState extends State<ActiveNavigationScreen>
    with SingleTickerProviderStateMixin {
  static const Color backgroundColor = Color(0xFFF1F5F9);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color red = Color(0xFFDC2626);
  static const Color amber = Color(0xFFD97706);

  static const double _headerTop = 12;
  static const double _headerHeight = 54;
  static const double _maneuverGap = 12;

  static const List<double> _snapSizes = <double>[0.10, 0.25, 0.50, 0.80];

  late final AnimationController _pulseController;
  final DraggableScrollableController _sheetController = DraggableScrollableController();
  final ValueNotifier<double> _sheetExtent = ValueNotifier<double>(0.25);
  int _currentSnapIndex = 1;
  bool _isCompassAnimating = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _sheetController.addListener(_handleSheetChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final navCtrl = context.read<NavigationController>();
        if (!navCtrl.isNavigating) {
          navCtrl.startNavigation();
        }
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _sheetController.removeListener(_handleSheetChanged);
    _sheetController.dispose();
    _sheetExtent.dispose();
    super.dispose();
  }

  void _handleSheetChanged() {
    if (!_sheetController.isAttached) return;

    final double extent = _sheetController.size;
    _sheetExtent.value = extent;

    int closestIndex = 0;
    double smallestDistance = double.infinity;

    for (int i = 0; i < _snapSizes.length; i++) {
      final double distance = (extent - _snapSizes[i]).abs();
      if (distance < smallestDistance) {
        smallestDistance = distance;
        closestIndex = i;
      }
    }

    if (closestIndex != _currentSnapIndex && smallestDistance < 0.04 && mounted) {
      setState(() => _currentSnapIndex = closestIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    final navCtrl = context.watch<NavigationController>();
    final mapCtrl = context.watch<MapController>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkCanvas : backgroundColor,
      body: SafeArea(
        bottom: false,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            // 1. Vector Map Substrate & Route Overlay
            Positioned.fill(
              child: NavigationMapView(
                mapCtrl: mapCtrl,
                pulseController: _pulseController,
                isDark: isDark,
              ),
            ),

            // Top gradient protection
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const <double>[0, 0.18, 0.50, 1],
                      colors: <Color>[
                        (isDark ? Colors.black : Colors.white).withValues(alpha: 0.28),
                        Colors.transparent,
                        Colors.transparent,
                        (isDark ? Colors.black : Colors.black).withValues(alpha: 0.12),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // 2. Floating Context Header
            Positioned(
              top: _headerTop,
              left: 16,
              right: 16,
              height: _headerHeight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ContextHeader(
                  title: 'Active Navigation',
                  isDark: isDark,
                  onBack: () => _confirmExitNavigation(),
                  onProfile: _showProfilePlaceholder,
                ),
              ),
            ),

            // 3. Maneuver HUD Card
            Positioned(
              top: _headerTop + _headerHeight + _maneuverGap,
              left: 16,
              right: 16,
              child: NavigationManeuverCard(navCtrl: navCtrl, isDark: isDark),
            ),

            // 4. POI Corridor Callout Badges
            Positioned(
              top: _headerTop + _headerHeight + 180,
              left: 16,
              child: NavigationPoiBadge(
                icon: Symbols.account_balance,
                label: 'Martyrs Memorial',
                iconColor: const Color(0xFF047857),
                showPulse: true,
                isDark: isDark,
              ),
            ),
            Positioned(
              top: _headerTop + _headerHeight + 250,
              right: 16,
              child: NavigationPoiBadge(
                icon: Symbols.mosque,
                label: 'Heritage Mosque',
                iconColor: const Color(0xFF0F766E),
                isDark: isDark,
              ),
            ),

            // 5. Speed HUD & Floating Controls
            Positioned(
              left: 16,
              bottom: 0,
              child: ValueListenableBuilder<double>(
                valueListenable: _sheetExtent,
                builder: (context, extent, child) {
                  final double sheetH = MediaQuery.sizeOf(context).height * extent;
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: math.max(16, sheetH + 12),
                    ),
                    child: child,
                  );
                },
                child: NavigationSpeedHud(navCtrl: navCtrl, isDark: isDark),
              ),
            ),

            Positioned(
              right: 16,
              bottom: 280,
              child: NavigationFloatingControls(
                navCtrl: navCtrl,
                mapCtrl: mapCtrl,
                isDark: isDark,
                isCompassAnimating: _isCompassAnimating,
                onCompassTap: () => _handleCompass(mapCtrl),
                onMuteTap: () => _toggleMute(navCtrl),
                onHazardTap: _showHazardDialog,
              ),
            ),

            // 6. Bottom-Anchored Draggable Sheet
            Positioned.fill(
              child: DraggableScrollableSheet(
                controller: _sheetController,
                initialChildSize: 0.25,
                minChildSize: 0.10,
                maxChildSize: 0.80,
                snap: true,
                snapSizes: _snapSizes,
                snapAnimationDuration: const Duration(milliseconds: 260),
                builder: (context, scrollController) {
                  return NavigationBottomSheet(
                    scrollController: scrollController,
                    navCtrl: navCtrl,
                    isDark: isDark,
                    currentSnapIndex: _currentSnapIndex,
                    snapSizes: _snapSizes,
                    onPitStopAdd: _handlePitStopAdd,
                    onConfirmExit: _confirmExitNavigation,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleCompass(MapController mapCtrl) {
    if (_isCompassAnimating) return;

    setState(() => _isCompassAnimating = true);
    mapCtrl.resetToDhakaCenter();

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        setState(() => _isCompassAnimating = false);
      }
    });
  }

  void _toggleMute(NavigationController navCtrl) {
    navCtrl.toggleMute();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          navCtrl.isMuted ? 'Voice guidance muted' : 'Voice guidance enabled',
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 900),
      ),
    );
  }

  void _handlePitStopAdd(String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$title added to route. Corridor metrics updated.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showProfilePlaceholder() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile setup accessible from main menu.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showHazardDialog() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Symbols.warning,
                    color: amber,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Report a Hazard',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Would you like to report a road hazard at your current location?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: textSecondary,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Hazard reported. Telemetry corridor updated.',
                            ),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: amber,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Report Hazard',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmExitNavigation() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'End Navigation?',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          content: const Text(
            'End navigation guidance and return to overview?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                if (mounted) {
                  context.read<NavigationController>().stopNavigation();
                  Navigator.of(context).maybePop();
                }
              },
              style: FilledButton.styleFrom(backgroundColor: red),
              child: const Text('End Navigation'),
            ),
          ],
        );
      },
    );
  }
}
