import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/waypoint_logo.dart';
import 'package:material_symbols_icons/symbols.dart';

class ActiveNavigationScreen extends StatefulWidget {
  const ActiveNavigationScreen({super.key});

  @override
  State<ActiveNavigationScreen> createState() =>
      _ActiveNavigationScreenState();
}

class _ActiveNavigationScreenState extends State<ActiveNavigationScreen> {
  // ---------------------------------------------------------------------------
  // COLORS
  // ---------------------------------------------------------------------------

  static const Color backgroundColor = Color(0xFFF1F5F9);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color emerald = AppTheme.primaryGreen;
  static const Color emeraldLight = Color(0xFFECFDF5);
  static const Color red = Color(0xFFDC2626);
  static const Color amber = Color(0xFFD97706);

  // ---------------------------------------------------------------------------
  // STATE
  // ---------------------------------------------------------------------------

  bool _isMuted = false;
  bool _isCompassRotating = false;

  // Efficient snap indicator: updates without full setState on every frame.
  // Uses a ValueNotifier so only the dot row rebuilds.
  final ValueNotifier<int> _snapIndexNotifier = ValueNotifier<int>(1);

  // ---------------------------------------------------------------------------
  // IMAGE URLS
  // ---------------------------------------------------------------------------

  static const String mapImageUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuCZMyzhD2IZeAcxOX7ypbWhSOpJzOjkg-Gj3duou_ptTJVb-gbQpZB3Ng6PXaUvBHVQBQwPYreBge5j_Qry39i0mQ4P9uY-74JpYFvDiQxGcLJ7h9QVLmxakXkYWRkz-YFaCEVlA6DqdJfPLvFFpO38RYlpUePyceUOqqRwl-909dj_JzGDJ8gJ5G8vvMyfKCJTvsf0XPT6tqV4r8DXffqxn_OCJWAah9n9iWS1JT-XXIjmBNnet1Ivw';

  static const String savarImageUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuDngf-X-AiUuQfyn-UfWzLzAQTfhhYZAeVQmbdwkGNP_6FeOTUBpNfDtGmTS0Sj1pBK163eWPcX3BAjuBFLZTmwDuoe37P-g8wnBvnLf7QACo2ho810tdMasgtFv5sVffY8SHapvlyDWj_0rU0gB4xaflxoq5_LxMOM7bGI3Havq6NXyy8EbuQTfjdn48mifvbAclu6oucPhaBtWEPJU3vA2G6ytAIqVx9m8NNH5nCtKdXq0GdRRUYnsw';

  static const String baitulImageUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuCwrPskFT-6VdGPxkhjPuEDZ64zPTnqT_AfEJvNQ7r_dn_Zk-uebve1efYx2sOY0qtjTKYpQk5E5LO8jQWKQhEXNNgHFr6Bntg_qA7fzjkww1vBtYZV4twrFJ1eQzc2Mn4Eg6WFiPU6RWm9rqRP2qrqATCBB4-4VRilr1j4zaP9e-TeSX-A0LeWu4FbtB0v3GNFUCr-MvNnSDQfhLFQUJe2xXAjmQ70F-kPzsIpUEG2uj_Ryumrwr23Xg';

  static const String bhawalImageUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuBSg8mmqn2n4eNlVI3tfq70ee3LThq9q_vTvQrrF_rn2GkKAjZmHN0CihPZvKDh_f-xuz1O7NrRyo6OM5jdehpp33tGLYJJzY0Tm7ukS7oMmEsyb8bn_ne2FQhSf1mcsBtRKByvE5KDoRdkwCXLFuREtDGVogSLfdwUcejupNjAA2rEWKhAya6vx1xtc4IU9KaA-Pj98rPpzQB9FdSopGkiixJFa8kKtKQT487j8VlllZFT98o12y2uIQ';

  // ---------------------------------------------------------------------------
  // LIFECYCLE
  // ---------------------------------------------------------------------------

  @override
  void dispose() {
    _snapIndexNotifier.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // === FIXED MAP BACKGROUND ===
            Positioned.fill(
              child: _buildNavigationMap(),
            ),

            // === FIXED HEADER ===
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildContextHeader(),
            ),

            // === FIXED MANEUVER CARD ===
            Positioned(
              top: 68,
              left: 16,
              right: 16,
              child: _buildManeuverCard(),
            ),

            // === FIXED POI BADGES ===
            Positioned(
              top: 210,
              left: 16,
              child: _buildPoiBadge(
                icon: Symbols.account_balance,
                label: 'Martyrs Memorial',
                iconColor: const Color(0xFF047857),
                showPulse: true,
              ),
            ),
            Positioned(
              top: 280,
              right: 16,
              child: _buildPoiBadge(
                icon: Symbols.mosque,
                label: 'Heritage Mosque',
                iconColor: const Color(0xFF0F766E),
              ),
            ),

            // === FIXED SPEED HUD ===
            Positioned(
              left: 16,
              bottom: 16,
              child: _buildSpeedHud(),
            ),

            // === FIXED FLOATING CONTROLS ===
            Positioned(
              right: 16,
              bottom: 16,
              child: _buildFloatingControls(),
            ),

            // === DRAGGABLE BOTTOM SHEET (anchored to bottom) ===
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: DraggableScrollableSheet(
                initialChildSize: 0.25,
                minChildSize: 0.10,
                maxChildSize: 0.80,
                snap: true,
                snapSizes: const [0.10, 0.25, 0.50, 0.80],
                expand: false,
                builder: (context, scrollController) {
                  return NotificationListener<
                      DraggableScrollableNotification>(
                    onNotification: (notification) {
                      // Clamp to nearest snap index only when settled
                      // within tolerance. Tolerance 0.03 = ~3% of screen.
                      final sizes = const [0.10, 0.25, 0.50, 0.80];
                      int newIndex = 0;
                      for (int i = 0; i < sizes.length; i++) {
                        if ((notification.extent - sizes[i]).abs() < 0.03) {
                          newIndex = i;
                          break;
                        }
                      }
                      if (newIndex != _snapIndexNotifier.value) {
                        _snapIndexNotifier.value = newIndex;
                      }
                      return false;
                    },
                    child: _buildBottomDashboardWithController(
                        scrollController),
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

  Widget _buildContextHeader() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0), width: 0.5),
        ),
      ),
      child: Row(
        children: [
          _roundActionBtn(
            icon: Symbols.arrow_back,
            onTap: () => Navigator.of(context).maybePop(),
          ),
          const SizedBox(width: 8),
          const WayPointLogo(size: 24, tintColor: AppTheme.accentNeon),
          const SizedBox(width: 8),
          const Expanded(
            child: Center(
              child: Text(
                'Active Navigation',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          _roundActionBtn(
            icon: Symbols.person,
            onTap: () {},
            isProfile: true,
          ),
        ],
      ),
    );
  }

  Widget _roundActionBtn({
    required IconData icon,
    required VoidCallback onTap,
    bool isProfile = false,
  }) {
    if (isProfile) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFE2E8F0),
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: const Icon(
          Symbols.person,
          size: 20,
          color: textSecondary,
        ),
      );
    }
    return Material(
      color: Colors.white,
      shape: const CircleBorder(
          side: BorderSide(color: Color(0xFFE2E8F0))),
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.06),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child:
            const SizedBox(width: 40, height: 40, child: Icon(Icons.close, size: 20)),
      ),
    );
  }
              style: TextStyle(
                  fontSize: 30,
                  height: 1,
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                  letterSpacing: -1.2,
                ),
              ),
              Text(
                'KM/H',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF64748B),
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(color: const Color(0xFFEF4444), width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.10),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '60',
                style: TextStyle(
                  fontSize: 12,
                  height: 1,
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                ),
              ),
              Text(
                'LIMIT',
                style: TextStyle(
                  fontSize: 7,
                  height: 1,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFDC2626),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // FLOATING CONTROLS
  // ---------------------------------------------------------------------------

  Widget _buildFloatingControls() {
    return Column(
      children: [
        _buildFloatingButton(
          icon: Symbols.explore,
          onTap: _handleCompass,
          rotating: _isCompassRotating,
        ),
        const SizedBox(height: 10),
        _buildFloatingButton(
          icon: _isMuted ? Symbols.volume_off : Symbols.volume_up,
          iconColor: _isMuted ? red : const Color(0xFF334155),
          onTap: () => setState(() => _isMuted = !_isMuted),
        ),
        const SizedBox(height: 10),
        _buildFloatingButton(
          icon: Symbols.warning,
          iconColor: amber,
          onTap: _showHazardDialog,
        ),
      ],
    );
  }

  Widget _buildFloatingButton({
    required IconData icon,
    required VoidCallback onTap,
    Color iconColor = const Color(0xFF334155),
    bool rotating = false,
  }) {
    return AnimatedRotation(
      turns: rotating ? 0.5 : 0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      child: Material(
        color: Colors.white.withOpacity(0.96),
        shape: const CircleBorder(),
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.18),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: const SizedBox(
            width: 44,
            height: 44,
            child: Icon(icon, size: 22),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // BOTTOM DASHBOARD
  // ---------------------------------------------------------------------------

  Widget _buildBottomDashboardWithController(ScrollController scrollController) {
    return Column(
      children: [
        // Scrollable dashboard content
        Expanded(
          child: SingleChildScrollView(
            controller: scrollController,
            physics: const BouncingScrollPhysics(),
            child: _buildBottomDashboard(),
          ),
        ),
        // Fixed snap indicator dots
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: ValueListenableBuilder<int>(
            valueListenable: _snapIndexNotifier,
            builder: (context, snapIndex, _) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  4,
                  (index) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: snapIndex == index ? 18 : 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: snapIndex == index
                            ? emerald
                            : const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBottomDashboard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.97),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: const Border(
          top: BorderSide(color: Color(0xFFE2E8F0), width: 0.9),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        children: [
          // Grabber handle
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 12),
          // Section title
          _buildRouteSectionHeader(),
          const SizedBox(height: 10),
          // Pit-stop carousel
          _buildPitStopCarousel(),
          const SizedBox(height: 12),
          // Trip metrics
          _buildTripMetrics(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildRouteSectionHeader() {
    return Row(
      children: [
        const Icon(Symbols.explore, color: emerald, size: 18),
        const SizedBox(width: 6),
        const Text(
          'Along Your Route',
          style: TextStyle(
            fontSize: 16,
            height: 1.3,
            fontWeight: FontWeight.w700,
            color: textPrimary,
            letterSpacing: -0.2,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: emeraldLight,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFA7F3D0).withOpacity(0.65)),
          ),
          child: const Text(
            '3 PITSTOPS',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Color(0xFF047857),
              letterSpacing: 0.8,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPitStopCarousel() {
    return SizedBox(
      height: 160,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          _buildPitStopCard(
            imageUrl: savarImageUrl,
            detour: '+8 min detour',
            title: 'Savar Monument',
            subtitle: 'Martyrs Memorial',
          ),
          const SizedBox(width: 10),
          _buildPitStopCard(
            imageUrl: baitulImageUrl,
            detour: '+5 min detour',
            title: 'Baitul Mukarram',
            subtitle: 'Heritage Mosque',
          ),
          const SizedBox(width: 10),
          _buildPitStopCard(
            imageUrl: bhawalImageUrl,
            detour: '+12 min detour',
            title: 'Bhawal Reserve',
            subtitle: 'Eco-Park Sanctuary',
          ),
          const SizedBox(width: 10),
        ],
      ),
    );
  }

  Widget _buildPitStopCard({
    required String imageUrl,
    required String detour,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0).withOpacity(0.85)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: double.infinity,
                  height: 88,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.high,
                    errorBuilder: (_, __, ___) {
                      return Container(
                        color: const Color(0xFFF1F5F9),
                        child: const Icon(
                          Symbols.image,
                          color: Color(0xFF94A3B8),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                top: 6,
                left: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: emerald,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.10),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: Text(
                    detour,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                _buildAddLocationButton(title: title),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddLocationButton({required String title}) {
    return Material(
      color: emeraldLight,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$title added as a pitstop'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFA7F3D0).withOpacity(0.7)),
          ),
          child: const Icon(
            Symbols.add_location_alt,
            size: 16,
            color: Color(0xFF047857),
          ),
        ),
      ),
    );
  }

  Widget _buildTripMetrics() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0).withOpacity(0.85)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      '15 min',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 3,
                      height: 3,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      '5.2 km',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Text(
                      'ETA 5:15 PM',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF047857),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD1FAE5),
                          borderRadius: BorderRadius.circular(3),
                          border: Border.all(color: const Color(0xFFA7F3D0)),
                        ),
                        child: const Text(
                          'FASTEST ROUTE',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF065F46),
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _buildEndButton(),
        ],
      ),
    );
  }

  Widget _buildEndButton() {
    return Material(
      color: red,
      borderRadius: BorderRadius.circular(24),
      elevation: 5,
      shadowColor: red.withOpacity(0.30),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: _endNavigation,
        child: const SizedBox(
          height: 42,
          width: 84,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Symbols.close, color: Colors.white, size: 18),
              SizedBox(width: 4),
              Text(
                'End',
                style: TextStyle(
                  fontSize: 14,
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
  // INTERACTIONS
  // ---------------------------------------------------------------------------

  void _handleCompass() {
    setState(() => _isCompassRotating = true);
    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      setState(() => _isCompassRotating = false);
    });
  }

  void _showHazardDialog() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 18),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Symbols.warning,
                  color: amber,
                  size: 26,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Report a Hazard',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Would you like to report a road hazard at your current location?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: textSecondary,
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Hazard reported'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: amber,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),
                  child: const Text(
                    'Report Hazard',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _endNavigation() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'End Navigation?',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          content: const Text(
            'End navigation guidance and return to overview?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.of(context).maybePop();
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
// ROUTE PAINTER
// =============================================================================

class _NavigationRoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Scale from original 390×520 coordinate system to actual canvas size
    final double scaleX = size.width / 390;
    final double scaleY = size.height / 520;

    canvas.save();
    canvas.scale(scaleX, scaleY);

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

    // Route shadow
    final Paint shadowPaint = Paint()
      ..color = const Color(0xFF047857).withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 17
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawPath(path, shadowPaint);

    // Main route line (using AppTheme.primaryGreen)
    final Paint routePaint = Paint()
      ..color = AppTheme.primaryGreen
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, routePaint);

    // White dashed center line
    final Paint dashPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.95)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;
    _drawDashedPath(canvas, path, dashPaint, dashLength: 14, gapLength: 10);

    // Vehicle beacon
    const Offset vehiclePos = Offset(195, 450);
    canvas.drawCircle(vehiclePos, 18, Paint()..color = const Color(0xFF10B981).withOpacity(0.30));
    canvas.drawCircle(vehiclePos, 10, Paint()..color = Colors.white..style = PaintingStyle.fill);
    canvas.drawCircle(vehiclePos, 7, Paint()..color = AppTheme.primaryGreen..style = PaintingStyle.fill);

    // Direction triangle
    final Path triangle = Path()
      ..moveTo(vehiclePos.dx, vehiclePos.dy - 6)
      ..lineTo(vehiclePos.dx - 4, vehiclePos.dy + 2)
      ..lineTo(vehiclePos.dx + 4, vehiclePos.dy + 2)
      ..close();
    canvas.drawPath(triangle, Paint()..color = Colors.white);

    canvas.restore();
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint,
      {required double dashLength, required double gapLength}) {
    for (final PathMetric metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final double nextDistance = math.min(distance + dashLength, metric.length);
        canvas.drawPath(metric.extractPath(distance, nextDistance), paint);
        distance += dashLength + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
