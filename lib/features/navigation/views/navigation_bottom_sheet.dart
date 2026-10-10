import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/time_utils.dart';
import '../controllers/navigation_controller.dart';

/// Navigation Draggable Bottom Dashboard Sheet with Corridor Pitstops & Trip Metrics
class NavigationBottomSheet extends StatelessWidget {
  final ScrollController scrollController;
  final NavigationController navCtrl;
  final bool isDark;
  final int currentSnapIndex;
  final List<double> snapSizes;
  final ValueChanged<String> onPitStopAdd;
  final VoidCallback onConfirmExit;

  const NavigationBottomSheet({
    super.key,
    required this.scrollController,
    required this.navCtrl,
    required this.isDark,
    required this.currentSnapIndex,
    required this.snapSizes,
    required this.onPitStopAdd,
    required this.onConfirmExit,
  });

  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color emerald = AppTheme.primaryGreen;
  static const Color emeraldLight = Color(0xFFECFDF5);
  static const Color red = Color(0xFFDC2626);
  static const Color borderColor = Color(0xFFE2E8F0);

  static const String _savarImageUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuDngf-X-AiUuQfyn-UfWzLzAQTfhhYZAeVQmbdwkGNP_6FeOTUBpNfDtGmTS0Sj1pBK163eWPcX3BAjuBFLZTmwDuoe37P-g8wnBvnLf7QACo2ho810tdMasgtFv5sVffY8SHapvlyDWj_0rU0gB4xaflxoq5_LxMOM7bGI3Havq6NXyy8EbuQTfjdn48mifvbAclu6oucPhaBtWEPJU3vA2G6ytAIqVx9m8NNH5nCtKdXq0GdRRUYnsw';

  static const String _baitulImageUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuCwrPskFT-6VdGPxkhjPuEDZ64zPTnq_TfEJvNQ7r_dn_Zk-uebve1efYx2sOY0qtjTKYpQk5E5LO8jQWKQhEXNNgHFr6Bntg_qA7fzjkww1vBtYZV4twrFJ1eQzc2Mn4Eg6WFiPU6RWm9rqRP2qrqATCBB4-4VRilr1j4zaP9e-TeSX-A0LeWu4FbtB0v3GNFUCr-MvNnSDQfhLFQUJe2xXAjmQ70F-kPzsIpUEG2uj_Ryumrwr23Xg';

  static const String _bhawalImageUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuBSg8mmqn2n4eNlVI3tfq70ee3LThq9q_vTvQrrF_rn2GkKAjZmHN0CihPZvKDh_f-xuz1O7NrRyo6OM5jdehpp33tGLYJJzY0Tm7ukS7oMmEsyb8bn_ne2FQhSf1mcsBtRKByvE5KDoRdkwCXLFuREtDGVogSLfdwUcejupNjAA2rEWKhAya6vx1xtc4IU9KaA-Pj98rPpzQB9FdSopGkiixJFa8kKtKQT487j8VlllZFT98o12y2uIQ';

  @override
  Widget build(BuildContext context) {
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
        snapSizes.length,
        (index) {
          final bool active = index == currentSnapIndex;
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
        onTap: () => onPitStopAdd(title),
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
                        border: Border.all(color: const Color(0xFFA3E6D2)),
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
          _buildEndButton(),
        ],
      ),
    );
  }

  Widget _buildEndButton() {
    return Material(
      color: red,
      borderRadius: BorderRadius.circular(30),
      elevation: 4,
      shadowColor: red.withValues(alpha: 0.28),
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: onConfirmExit,
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
}
