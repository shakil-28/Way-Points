import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/geoutils.dart';
import '../../../core/utils/time_utils.dart';
import '../../map/controllers/map_controller.dart';
import '../../map/views/map_view.dart';
import '../controllers/navigation_controller.dart';
import '../models/maneuver_model.dart';

/// Screen 7: Active Turn-by-Turn Navigation Screen with live maneuver cards,
/// corridor vector map substrate, animated vehicle route painter, and draggable bottom dashboard.
class ActiveNavigationScreen extends StatefulWidget {
  const ActiveNavigationScreen({super.key});

  @override
  State<ActiveNavigationScreen> createState() => _ActiveNavigationScreenState();
}

class _ActiveNavigationScreenState extends State<ActiveNavigationScreen>
    with SingleTickerProviderStateMixin {
  // ---------------------------------------------------------------------------
  // DESIGN CONSTANTS & COLORS
  // ---------------------------------------------------------------------------

  static const Color backgroundColor = Color(0xFFF1F5F9);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color emerald = AppTheme.primaryGreen;
  static const Color emeraldLight = Color(0xFFECFDF5);
  static const Color red = Color(0xFFDC2626);
  static const Color amber = Color(0xFFD97706);
  static const Color borderColor = Color(0xFFE2E8F0);

  static const double _headerHeight = 56;
  static const double _maneuverGap = 10;

  static const List<double> _snapSizes = <double>[0.10, 0.25, 0.50, 0.80];

  // ---------------------------------------------------------------------------
  // PITSTOP IMAGE ASSETS (CULTURAL / CORRIDOR ASSETS)
  // ---------------------------------------------------------------------------

  static const String _savarImageUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuDngf-X-AiUuQfyn-UfWzLzAQTfhhYZAeVQmbdwkGNP_6FeOTUBpNfDtGmTS0Sj1pBK163eWPcX3BAjuBFLZTmwDuoe37P-g8wnBvnLf7QACo2ho810tdMasgtFv5sVffY8SHapvlyDWj_0rU0gB4xaflxoq5_LxMOM7bGI3Havq6NXyy8EbuQTfjdn48mifvbAclu6oucPhaBtWEPJU3vA2G6ytAIqVx9m8NNH5nCtKdXq0GdRRUYnsw';

  static const String _baitulImageUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuCwrPskFT-6VdGPxkhjPuEDZ64zPTnq_TfEJvNQ7r_dn_Zk-uebve1efYx2sOY0qtjTKYpQk5E5LO8jQWKQhEXNNgHFr6Bntg_qA7fzjkww1vBtYZV4twrFJ1eQzc2Mn4Eg6WFiPU6RWm9rqRP2qrqATCBB4-4VRilr1j4zaP9e-TeSX-A0LeWu4FbtB0v3GNFUCr-MvNnSDQfhLFQUJe2xXAjmQ70F-kPzsIpUEG2uj_Ryumrwr23Xg';

  static const String _bhawalImageUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuBSg8mmqn2n4eNlVI3tfq70ee3LThq9q_vTvQrrF_rn2GkKAjZmHN0CihPZvKDh_f-xuz1O7NrRyo6OM5jdehpp33tGLYJJzY0Tm7ukS7oMmEsyb8bn_ne2FQhSf1mcsBtRKByvE5KDoRdkwCXLFuREtDGVogSLfdwUcejupNjAA2rEWKhAya6vx1xtc4IU9KaA-Pj98rPpzQB9FdSopGkiixJFa8kKtKQT487j8VlllZFT98o12y2uIQ';

  // ---------------------------------------------------------------------------
  // STATE & CONTROLLERS
  // ---------------------------------------------------------------------------

  late final AnimationController _pulseController;
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();
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

    if (closestIndex != _currentSnapIndex &&
        smallestDistance < 0.04 &&
        mounted) {
      setState(() => _currentSnapIndex = closestIndex);
    }
  }

  // ---------------------------------------------------------------------------
  // BUILD METHOD
  // ---------------------------------------------------------------------------

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
            // -----------------------------------------------------------------
            // 1. FIXED VECTOR MAP SUBSTRATE & ROUTE OVERLAY
            // -----------------------------------------------------------------
            Positioned.fill(
              child: _buildNavigationMap(mapCtrl, isDark),
            ),

            // Top gradient protection for HUD legibility
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const <double>[0, 0.18, 0.50, 1],
                      colors: <Color>[
                        (isDark ? Colors.black : Colors.white)
                            .withValues(alpha: 0.28),
                        Colors.transparent,
                        Colors.transparent,
                        (isDark ? Colors.black : Colors.black)
                            .withValues(alpha: 0.12),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // -----------------------------------------------------------------
            // 2. FIXED CONTEXT HEADER
            // -----------------------------------------------------------------
            Positioned(
              top: 0,
              left: 12,
              right: 12,
              height: _headerHeight,
              child: _buildContextHeader(isDark),
            ),

            // -----------------------------------------------------------------
            // 3. FIXED MANEUVER HUD CARD
            // -----------------------------------------------------------------
            Positioned(
              top: _headerHeight + _maneuverGap,
              left: 16,
              right: 16,
              child: _buildManeuverCard(navCtrl, isDark),
            ),

            // -----------------------------------------------------------------
            // 4. FIXED POI CALLOUT BADGES ALONG CORRIDOR
            // -----------------------------------------------------------------
            Positioned(
              top: _headerHeight + 175,
              left: 16,
              child: _buildPoiBadge(
                icon: Symbols.account_balance,
                label: 'Martyrs Memorial',
                iconColor: const Color(0xFF047857),
                showPulse: true,
                isDark: isDark,
              ),
            ),
            Positioned(
              top: _headerHeight + 245,
              right: 16,
              child: _buildPoiBadge(
                icon: Symbols.mosque,
                label: 'Heritage Mosque',
                iconColor: const Color(0xFF0F766E),
                isDark: isDark,
              ),
            ),

            // -----------------------------------------------------------------
            // 5. SPEED HUD & FLOATING CONTROLS (DIRECT CHILDREN OF STACK)
            // Sized and padded safely above the draggable sheet
            // -----------------------------------------------------------------
            Positioned(
              left: 16,
              bottom: 0,
              child: ValueListenableBuilder<double>(
                valueListenable: _sheetExtent,
                builder: (context, extent, child) {
                  final double sheetH =
                      MediaQuery.sizeOf(context).height * extent;
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: math.max(16, sheetH + 12),
                    ),
                    child: child,
                  );
                },
                child: _buildSpeedHud(navCtrl, isDark),
              ),
            ),

            Positioned(
              right: 16,
              bottom: 0,
              child: ValueListenableBuilder<double>(
                valueListenable: _sheetExtent,
                builder: (context, extent, child) {
                  final double sheetH =
                      MediaQuery.sizeOf(context).height * extent;
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: math.max(16, sheetH + 12),
                    ),
                    child: child,
                  );
                },
                child: _buildFloatingControls(navCtrl, mapCtrl, isDark),
              ),
            ),

            // -----------------------------------------------------------------
            // 6. BOTTOM-ANCHORED DRAGGABLE SHEET
            // -----------------------------------------------------------------
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
                  return _buildBottomSheet(
                    scrollController,
                    navCtrl,
                    isDark,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HEADER
  // ---------------------------------------------------------------------------

  Widget _buildContextHeader(bool isDark) {
    return SizedBox(
      height: 56,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Left: Back button
          Positioned(
            left: 10,
            child: _roundActionButton(
              icon: Symbols.arrow_back,
              onTap: () => _confirmExitNavigation(),
              isDark: isDark,
            ),
          ),

          // Center: Title
          Center(
            child: Text(
              'Active Navigation',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : textPrimary,
                letterSpacing: -0.2,
              ),
            ),
          ),

          // Right: Profile button
          Positioned(
            right: 10,
            child: _roundActionButton(
              icon: Symbols.person,
              onTap: _showProfilePlaceholder,
              isProfile: true,
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _roundActionButton({
    required IconData icon,
    required VoidCallback onTap,
    bool isProfile = false,
    required bool isDark,
  }) {
    final bgColor = isProfile
        ? (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0))
        : (isDark ? AppTheme.darkCard : Colors.white);

    return Material(
      color: bgColor,
      shape: CircleBorder(
        side: BorderSide(
          color: isProfile
              ? (isDark ? AppTheme.darkBorder : Colors.white)
              : (isDark ? AppTheme.darkBorder : borderColor),
          width: isProfile ? 2 : 1,
        ),
      ),
      elevation: isProfile ? 0 : 1,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 38,
          height: 38,
          child: Icon(
            icon,
            size: 20,
            color: isProfile
                ? (isDark ? Colors.white70 : textSecondary)
                : (isDark ? Colors.white : textPrimary),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // NAVIGATION MAP SUBSTRATE & ROUTE OVERLAY
  // ---------------------------------------------------------------------------

  Widget _buildNavigationMap(MapController mapCtrl, bool isDark) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        // Realistic Bengal geographic vector map substrate
        MapView(controller: mapCtrl),

        // Animated turn-by-turn navigation glowing path & beacon
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, _) {
            return CustomPaint(
              size: Size.infinite,
              painter: _NavigationRoutePainter(
                pulse: _pulseController.value,
                isDark: isDark,
              ),
            );
          },
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // MANEUVER CARD
  // ---------------------------------------------------------------------------

  Widget _buildManeuverCard(NavigationController navCtrl, bool isDark) {
    final maneuver = navCtrl.currentManeuver;
    final icon = _maneuverIcon(maneuver.direction);

    return Material(
      color: Colors.transparent,
      elevation: 0,
      child: InkWell(
        onTap: () => navCtrl.nextManeuver(),
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
          decoration: BoxDecoration(
            color: (isDark ? AppTheme.darkCard : Colors.white)
                .withValues(alpha: 0.98),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark ? AppTheme.darkBorder : borderColor,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.14),
                blurRadius: 22,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: emerald,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: emerald.withValues(alpha: 0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 34,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'In ${GeoUtils.formatDistance(maneuver.distanceMeters / 1000.0)}',
                          style: TextStyle(
                            fontSize: 26,
                            height: 1.05,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : textPrimary,
                            letterSpacing: -0.8,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          maneuver.streetName.isNotEmpty
                              ? maneuver.streetName
                              : maneuver.instruction,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.3,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white70 : textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 11),
              Container(
                height: 1,
                color: isDark
                    ? const Color(0xFF334155)
                    : const Color(0xFFF1F5F9),
              ),
              const SizedBox(height: 8),
              Row(
                children: <Widget>[
                  _buildLane(Symbols.straight, active: false, isDark: isDark),
                  const SizedBox(width: 4),
                  _buildLane(
                    icon,
                    active: true,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 4),
                  _buildLane(Symbols.straight, active: true, isDark: isDark),
                  const SizedBox(width: 4),
                  _buildLane(Symbols.turn_right, active: false, isDark: isDark),
                  const Spacer(),
                  Flexible(
                    child: Text(
                      maneuver.laneIndicator.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white60 : textSecondary,
                        letterSpacing: 0.7,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _maneuverIcon(TurnDirection direction) {
    switch (direction) {
      case TurnDirection.turnLeft:
        return Symbols.turn_left;
      case TurnDirection.slightLeft:
        return Symbols.turn_slight_left;
      case TurnDirection.turnRight:
        return Symbols.turn_right;
      case TurnDirection.slightRight:
        return Symbols.turn_slight_right;
      case TurnDirection.sharpRight:
        return Symbols.turn_sharp_right;
      case TurnDirection.uTurn:
        return Symbols.u_turn_left;
      case TurnDirection.merge:
        return Symbols.merge;
      case TurnDirection.exitRoundabout:
        return Symbols.roundabout_right;
      case TurnDirection.arrive:
        return Symbols.location_on;
      case TurnDirection.straight:
        return Symbols.straight;
    }
  }

  Widget _buildLane(
    IconData icon, {
    required bool active,
    required bool isDark,
  }) {
    return Container(
      width: 34,
      height: 40,
      decoration: BoxDecoration(
        color: active
            ? (isDark
                ? emerald.withValues(alpha: 0.25)
                : emeraldLight)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: active
            ? Border.all(
                color: isDark
                    ? emerald.withValues(alpha: 0.6)
                    : const Color(0xFFA7F3D0),
              )
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            icon,
            size: 16,
            color: active
                ? (isDark ? const Color(0xFF6EE7B7) : const Color(0xFF047857))
                : (isDark ? Colors.white38 : const Color(0xFF94A3B8)),
          ),
          const SizedBox(height: 2),
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active
                  ? emerald
                  : (isDark ? Colors.white24 : const Color(0xFFCBD5E1)),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // POI CORRIDOR BADGES
  // ---------------------------------------------------------------------------

  Widget _buildPoiBadge({
    required IconData icon,
    required String label,
    required Color iconColor,
    bool showPulse = false,
    required bool isDark,
  }) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: (isDark ? AppTheme.darkCard : Colors.white)
              .withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: (isDark ? AppTheme.darkBorder : borderColor)
                .withValues(alpha: 0.9),
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.10),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (showPulse) ...<Widget>[
              const DecoratedBox(
                decoration: BoxDecoration(
                  color: emerald,
                  shape: BoxShape.circle,
                ),
                child: SizedBox(width: 8, height: 8),
              ),
              const SizedBox(width: 6),
            ],
            Icon(icon, size: 18, color: iconColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SPEED HUD
  // ---------------------------------------------------------------------------

  Widget _buildSpeedHud(NavigationController navCtrl, bool isDark) {
    final speed = navCtrl.currentSpeedKmh.round();
    final limit = navCtrl.currentManeuver.speedLimitKmh.round();

    return Material(
      color: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              color: (isDark ? AppTheme.darkCard : Colors.white)
                  .withValues(alpha: 0.96),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppTheme.darkBorder : borderColor,
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  '$speed',
                  style: TextStyle(
                    fontSize: 31,
                    height: 1,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : textPrimary,
                    letterSpacing: -1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'KM/H',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white60 : textSecondary,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? AppTheme.darkCard : Colors.white,
              border: Border.all(color: const Color(0xFFEF4444), width: 2.2),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.10),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  '$limit',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'LIMIT',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                    color: red,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // FLOATING HUD CONTROLS
  // ---------------------------------------------------------------------------

  Widget _buildFloatingControls(
    NavigationController navCtrl,
    MapController mapCtrl,
    bool isDark,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _buildFloatingButton(
          icon: Symbols.explore,
          onTap: () => _handleCompass(mapCtrl),
          rotating: _isCompassAnimating,
          isDark: isDark,
        ),
        const SizedBox(height: 10),
        _buildFloatingButton(
          icon: navCtrl.isMuted ? Symbols.volume_off : Symbols.volume_up,
          iconColor: navCtrl.isMuted ? red : (isDark ? Colors.white : const Color(0xFF334155)),
          onTap: () => _toggleMute(navCtrl),
          isDark: isDark,
        ),
        const SizedBox(height: 10),
        _buildFloatingButton(
          icon: Symbols.warning,
          iconColor: amber,
          onTap: _showHazardDialog,
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildFloatingButton({
    required IconData icon,
    required VoidCallback onTap,
    Color? iconColor,
    bool rotating = false,
    required bool isDark,
  }) {
    final effectiveColor = iconColor ?? (isDark ? Colors.white : const Color(0xFF334155));

    return AnimatedRotation(
      turns: rotating ? 0.5 : 0,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      child: Material(
        color: (isDark ? AppTheme.darkCard : Colors.white).withValues(alpha: 0.96),
        shape: const CircleBorder(),
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: isDark ? 0.35 : 0.18),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 48,
            height: 48,
            child: Icon(icon, size: 23, color: effectiveColor),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // DRAGGABLE BOTTOM SHEET & CORRIDOR PITSTOPS
  // ---------------------------------------------------------------------------

  Widget _buildBottomSheet(
    ScrollController scrollController,
    NavigationController navCtrl,
    bool isDark,
  ) {
    final double bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: (isDark ? AppTheme.darkCard : Colors.white).withValues(alpha: 0.985),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(
            color: isDark ? AppTheme.darkBorder : borderColor,
            width: 0.9,
          ),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.14),
            blurRadius: 22,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          Expanded(
            child: CustomScrollView(
              controller: scrollController,
              physics: const ClampingScrollPhysics(),
              slivers: <Widget>[
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate(<Widget>[
                      _buildRouteSectionHeader(isDark),
                      const SizedBox(height: 12),
                      _buildPitStopCarousel(isDark),
                      const SizedBox(height: 14),
                      _buildTripMetrics(navCtrl, isDark),
                    ]),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              0,
              16,
              math.max(10, bottomPadding + 6),
            ),
            child: _buildSnapIndicator(isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildSnapIndicator(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(
        _snapSizes.length,
        (index) {
          final bool active = index == _currentSnapIndex;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              width: active ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: active
                    ? emerald
                    : (isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1)),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRouteSectionHeader(bool isDark) {
    return Row(
      children: <Widget>[
        const Icon(Symbols.explore, color: emerald, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Along Your Route',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : textPrimary,
              letterSpacing: -0.2,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isDark
                ? emerald.withValues(alpha: 0.25)
                : emeraldLight,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? emerald.withValues(alpha: 0.5)
                  : const Color(0xFFA7F3D0),
            ),
          ),
          child: const Text(
            '3 PITSTOPS',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: Color(0xFF047857),
              letterSpacing: 0.8,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPitStopCarousel(bool isDark) {
    return SizedBox(
      height: 178,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const ClampingScrollPhysics(),
        padding: EdgeInsets.zero,
        children: <Widget>[
          _buildPitStopCard(
            imageUrl: _savarImageUrl,
            imageColor: const Color(0xFFCFDDD7),
            icon: Symbols.account_balance,
            detour: '+8 min detour',
            title: 'Savar Monument',
            subtitle: 'Martyrs Memorial',
            isDark: isDark,
          ),
          const SizedBox(width: 12),
          _buildPitStopCard(
            imageUrl: _baitulImageUrl,
            imageColor: const Color(0xFFDDE6D4),
            icon: Symbols.mosque,
            detour: '+5 min detour',
            title: 'Baitul Mukarram',
            subtitle: 'Heritage Mosque',
            isDark: isDark,
          ),
          const SizedBox(width: 12),
          _buildPitStopCard(
            imageUrl: _bhawalImageUrl,
            imageColor: const Color(0xFFD7E4D3),
            icon: Symbols.park,
            detour: '+12 min detour',
            title: 'Bhawal Reserve',
            subtitle: 'Eco-Park Sanctuary',
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildPitStopCard({
    required String imageUrl,
    required Color imageColor,
    required IconData icon,
    required String detour,
    required String title,
    required String subtitle,
    required bool isDark,
  }) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCanvas : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : borderColor,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 7,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          Stack(
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrl,
                  width: double.infinity,
                  height: 96,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: imageColor,
                      child: Center(
                        child: Icon(
                          icon,
                          size: 44,
                          color: const Color(0xFF44735F),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: emerald,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: Text(
                    detour,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white60 : textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _buildAddLocationButton(title, isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddLocationButton(String title, bool isDark) {
    return Material(
      color: isDark
          ? emerald.withValues(alpha: 0.25)
          : emeraldLight,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () => _handlePitStopAdd(title),
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isDark
                  ? emerald.withValues(alpha: 0.5)
                  : const Color(0xFFA7F3D0),
            ),
          ),
          child: const Icon(
            Symbols.add_location_alt,
            size: 18,
            color: Color(0xFF047857),
          ),
        ),
      ),
    );
  }

  Widget _buildTripMetrics(NavigationController navCtrl, bool isDark) {
    final etaString = TimeUtils.calculateEta(
      durationMinutes: navCtrl.remainingTimeMinutes,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : borderColor,
        ),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(
                      '${navCtrl.remainingTimeMinutes} min',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${navCtrl.remainingDistanceKm.toStringAsFixed(1)} km',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white70 : const Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 7,
                  runSpacing: 4,
                  children: <Widget>[
                    Text(
                      'ETA $etaString',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF047857),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD1FAE5),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: const Color(0xFFA7F3D0)),
                      ),
                      child: const Text(
                        'FASTEST ROUTE',
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF065F46),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _buildEndButton(navCtrl),
        ],
      ),
    );
  }

  Widget _buildEndButton(NavigationController navCtrl) {
    return Material(
      color: red,
      borderRadius: BorderRadius.circular(30),
      elevation: 4,
      shadowColor: red.withValues(alpha: 0.28),
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: () => _confirmExitNavigation(),
        child: const SizedBox(
          height: 48,
          width: 96,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Symbols.close, color: Colors.white, size: 20),
              SizedBox(width: 5),
              Text(
                'End',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // USER ACTIONS & DIALOGS
  // ---------------------------------------------------------------------------

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

// =============================================================================
// VECTOR ROUTE PAINTER (ACTIVE TURN-BY-TURN CORRIDOR GLOW & BEACON)
// =============================================================================

class _NavigationRoutePainter extends CustomPainter {
  final double pulse;
  final bool isDark;

  _NavigationRoutePainter({
    required this.pulse,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double scaleX = size.width / 390;
    final double scaleY = size.height / 520;

    canvas.save();
    canvas.scale(scaleX, scaleY);

    // Realistic navigation route polyline path
    final Path path = Path()
      ..moveTo(195, 520)
      ..lineTo(195, 390)
      ..lineTo(110, 300)
      ..lineTo(95, 170);

    // Outer road casing
    final Paint outerPaint = Paint()
      ..color = const Color(0xFF065F46).withValues(alpha: 0.20)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 22
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, outerPaint);

    // Glowing route shadow
    final Paint shadowPaint = Paint()
      ..color = const Color(0xFF047857).withValues(alpha: 0.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 17
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawPath(path, shadowPaint);

    // Main emerald route line
    final Paint routePaint = Paint()
      ..color = AppTheme.primaryGreen
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, routePaint);

    // Dashed center line
    final Paint dashPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.95)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;
    _drawDashedPath(canvas, path, dashPaint, dashLength: 14, gapLength: 10);

    // Vehicle beacon position
    const Offset vehiclePos = Offset(195, 450);

    // Radar pulse wave
    final double pulseRadius = 18.0 + (pulse * 14.0);
    final double pulseAlpha = (1.0 - pulse) * 0.35;
    canvas.drawCircle(
      vehiclePos,
      pulseRadius,
      Paint()
        ..color = const Color(0xFF10B981).withValues(alpha: pulseAlpha)
        ..style = PaintingStyle.fill,
    );

    // Vehicle beacon outer glow & white core
    canvas.drawCircle(
      vehiclePos,
      18,
      Paint()..color = const Color(0xFF10B981).withValues(alpha: 0.30),
    );
    canvas.drawCircle(
      vehiclePos,
      10,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      vehiclePos,
      7,
      Paint()
        ..color = AppTheme.primaryGreen
        ..style = PaintingStyle.fill,
    );

    // Vehicle direction triangle heading upward along route
    final Path triangle = Path()
      ..moveTo(vehiclePos.dx, vehiclePos.dy - 6)
      ..lineTo(vehiclePos.dx - 4, vehiclePos.dy + 2)
      ..lineTo(vehiclePos.dx + 4, vehiclePos.dy + 2)
      ..close();
    canvas.drawPath(triangle, Paint()..color = Colors.white);

    canvas.restore();
  }

  void _drawDashedPath(
    Canvas canvas,
    Path path,
    Paint paint, {
    required double dashLength,
    required double gapLength,
  }) {
    for (final ui.PathMetric metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final double nextDistance =
            math.min(distance + dashLength, metric.length);
        canvas.drawPath(metric.extractPath(distance, nextDistance), paint);
        distance += dashLength + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _NavigationRoutePainter oldDelegate) =>
      oldDelegate.pulse != pulse || oldDelegate.isDark != isDark;
}
