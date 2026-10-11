import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/time_utils.dart';
import '../controllers/navigation_controller.dart';

/// Navigation Draggable Bottom Sheet with adaptive UI across snap sizes (0.25, 0.50, 0.80)
/// - 0.25: Compact POI summary
/// - 0.50: Swipable PageView POI Card Carousel
/// - 0.80: Full POI Details Screen view (not card design) + rich metadata & trip metrics
class NavigationBottomSheet extends StatefulWidget {
  final ScrollController scrollController;
  final NavigationController navCtrl;
  final bool isDark;
  final ValueListenable<int> currentSnapIndexListenable;
  final List<double> snapSizes;
  final ValueChanged<String> onPitStopAdd;
  final VoidCallback onConfirmExit;

  const NavigationBottomSheet({
    super.key,
    required this.scrollController,
    required this.navCtrl,
    required this.isDark,
    required this.currentSnapIndexListenable,
    required this.snapSizes,
    required this.onPitStopAdd,
    required this.onConfirmExit,
  });

  @override
  State<NavigationBottomSheet> createState() => _NavigationBottomSheetState();
}

class _NavigationBottomSheetState extends State<NavigationBottomSheet> {
  late final PageController _pageController;
  int _selectedPoiIndex = 0;

  static const Color textPrimary = AppTheme.textPrimary;
  static const Color textSecondary = AppTheme.textSecondary;
  static const Color emerald = AppTheme.primaryGreen;
  static const Color red = Color(0xFFDC2626);
  static const Color borderColor = AppTheme.lightBorder;

  // Pitstop image URLs
  static const String _savarImageUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuDngf-X-AiUuQfyn-UfWzLzAQTfhhYZAeVQmbdwkGNP_6FeOTUBpNfDtGmTS0Sj1pBK163eWPcX3BAjuBFLZTmwDuoe37P-g8wnBvnLf7QACo2ho810tdMasgtFv5sVffY8SHapvlyDWj_0rU0gB4xaflxoq5_LxMOM7bGI3Havq6NXyy8EbuQTfjdn48mifvbAclu6oucPhaBtWEPJU3vA2G6ytAIqVx9m8NNH5nCtKdXq0GdRRUYnsw';

  static const String _baitulImageUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuCwrPskFT-6VdGPxkhjPuEDZ64zPTnq_TfEJvNQ7r_dn_Zk-uebve1efYx2sOY0qtjTKYpQk5E5LO8jQWKQhEXNNgHFr6Bntg_qA7fzjkww1vBtYZV4twrFJ1eQzc2Mn4Eg6WFiPU6RWm9rqRP2qrqATCBB4-4VRilr1j4zaP9e-TeSX-A0LeWu4FbtB0v3GNFUCr-MvNnSDQfhLFQUJe2xXAjmQ70F-kPzsIpUEG2uj_Ryumrwr23Xg';

  static const String _bhawalImageUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuBSg8mmqn2n4eNlVI3tfq70ee3LThq9q_vTvQrrF_rn2GkKAjZmHN0CihPZvKDh_f-xuz1O7NrRyo6OM5jdehpp33tGLYJJzY0Tm7ukS7oMmEsyb8bn_ne2FQhSf1mcsBtRKByvE5KDoRdkwCXLFuREtDGVogSLfdwUcejupNjAA2rEWKhAya6vx1xtc4IU9KaA-Pj98rPpzQB9FdSopGkiixJFa8kKtKQT487j8VlllZFT98o12y2uIQ';

  static final List<Map<String, dynamic>> _pitstops = [
    {
      'title': 'Savar Monument',
      'fullTitle': 'National Martyrs Monument (Jatiya Smriti Soudho)',
      'subtitle': 'Savar, Dhaka-Aricha Highway',
      'detour': '+8 min detour',
      'distance': '12.4 km ahead',
      'hours': '9:00 AM - 5:00 PM',
      'fee': 'Free Entry',
      'parking': 'Free Visitor Parking',
      'weather': '28°C • Sunny',
      'rating': '4.8 ★ (1,240 reviews)',
      'description': 'Designed by Syed Mainul Hossain, the 150-ft central monument consists of 7 pairs of triangular wall planes representing key chapters of the Bangladesh liberation movement.',
      'quote': '"A serene, majestic national memorial surrounded by 84 acres of beautifully manicured botanical gardens and reflection lakes."',
      'image': _savarImageUrl,
      'color': const Color(0xFFCFDDD7),
      'icon': Symbols.account_balance,
      'tags': ['National Monument', 'Scenic Walkway', 'Botanical Gardens'],
    },
    {
      'title': 'Baitul Mukarram',
      'fullTitle': 'Baitul Mukarram National Mosque',
      'subtitle': 'Topkhana Road, Dhaka Center',
      'detour': '+5 min detour',
      'distance': '18.2 km ahead',
      'hours': '5:00 AM - 10:00 PM',
      'fee': 'Free Entry',
      'parking': 'Street Parking Available',
      'weather': '29°C • Clear',
      'rating': '4.7 ★ (2,100 reviews)',
      'description': 'Designed by Abdul Husein M. Thariani in 1960, this national mosque resembles the Holy Kaaba in Mecca and features 8-story prayer halls accommodating 40,000 worshippers.',
      'quote': '"Stunning multi-tiered Islamic architecture with expansive serene prayer halls in the urban corridor."',
      'image': _baitulImageUrl,
      'color': const Color(0xFFDDE6D4),
      'icon': Symbols.mosque,
      'tags': ['Architecture', 'Islamic Heritage', 'City Landmark'],
    },
    {
      'title': 'Bhawal Reserve',
      'fullTitle': 'Bhawal National Park & Eco-Sanctuary',
      'subtitle': 'Gazipur, N3 Highway Corridor',
      'detour': '+12 min detour',
      'distance': '24.8 km ahead',
      'hours': '8:00 AM - 6:00 PM',
      'fee': '50 BDT / Person',
      'parking': 'Secure Visitor Parking',
      'weather': '27°C • Partially Cloudy',
      'rating': '4.6 ★ (890 reviews)',
      'description': 'Established in 1974 across 5,022 hectares of Sal tropical forest, Bhawal National Park offers canopy boardwalks, wildlife watchtowers, and picnic gazebos.',
      'quote': '"Lush Sal forest sanctuary providing a refreshing tropical green escape along the Dhaka-Mymensingh corridor."',
      'image': _bhawalImageUrl,
      'color': const Color(0xFFD7E4D3),
      'icon': Symbols.park,
      'tags': ['Sal Forest', 'Canopy Walk', 'Eco-Park'],
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.92);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: (widget.isDark ? AppTheme.darkCard : Colors.white).withValues(alpha: 0.985),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(
            color: widget.isDark ? AppTheme.darkBorder : borderColor,
            width: 0.9,
          ),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: widget.isDark ? 0.35 : 0.14),
            blurRadius: 22,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          // Drag Handle Bar
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 6),
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: widget.isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          // Content adaptively switching based on snap index
          // 0 = 0.25 (Compact Summary)
          // 1 = 0.50 (Card Carousel View)
          // 2 = 0.80 (Full Details Screen Layout)
          Expanded(
            child: ValueListenableBuilder<int>(
              valueListenable: widget.currentSnapIndexListenable,
              builder: (context, currentSnapIndex, _) {
                if (currentSnapIndex == 0) {
                  return _buildCompactSummaryView(context);
                } else if (currentSnapIndex == 1) {
                  return _buildCardCarouselView(context);
                } else {
                  return _buildFullDetailsScreenView(context);
                }
              },
            ),
          ),

          // Snap Indicator
          Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              2,
              16,
              math.max(10, bottomPadding + 4),
            ),
            child: ValueListenableBuilder<int>(
              valueListenable: widget.currentSnapIndexListenable,
              builder: (context, snapIndex, _) {
                return _buildSnapIndicator(widget.isDark, snapIndex);
              },
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 1. SNAP SIZE 0.25: COMPACT SUMMARY VIEW
  // ---------------------------------------------------------------------------

  Widget _buildCompactSummaryView(BuildContext context) {
    final activePoi = _pitstops[_selectedPoiIndex];

    return SingleChildScrollView(
      controller: widget.scrollController,
      physics: const ClampingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Row(
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    activePoi['image'] as String,
                    width: 58,
                    height: 58,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, error, stackTrace) => Container(
                      width: 58,
                      height: 58,
                      color: activePoi['color'] as Color,
                      child: Icon(activePoi['icon'] as IconData, size: 28, color: Colors.white),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 2,
                  left: 2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: emerald,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      activePoi['detour'] as String,
                      style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activePoi['title'] as String,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: widget.isDark ? Colors.white : textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${activePoi['subtitle']} • ${activePoi['distance']}',
                    style: TextStyle(
                      fontSize: 12,
                      color: widget.isDark ? Colors.white60 : textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            Material(
              color: emerald,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => widget.onPitStopAdd(activePoi['title'] as String),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      Icon(Symbols.add_location_alt, size: 16, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        'Add Stop',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 2. SNAP SIZE 0.50: SWIPABLE POI CARD CAROUSEL VIEW
  // ---------------------------------------------------------------------------

  Widget _buildCardCarouselView(BuildContext context) {
    return SingleChildScrollView(
      controller: widget.scrollController,
      physics: const ClampingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Symbols.explore, color: emerald, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Corridor Pitstops',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: widget.isDark ? Colors.white : textPrimary,
                      ),
                    ),
                  ],
                ),
                Text(
                  'Swipe ◄ ► (${_selectedPoiIndex + 1}/${_pitstops.length})',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryGreen,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 6),

          SizedBox(
            height: 295,
            child: PageView.builder(
              controller: _pageController,
              itemCount: _pitstops.length,
              onPageChanged: (index) {
                setState(() {
                  _selectedPoiIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final poi = _pitstops[index];
                final isSelected = index == _selectedPoiIndex;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: widget.isDark ? AppTheme.darkCanvas : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? emerald
                          : (widget.isDark ? AppTheme.darkBorder : borderColor),
                      width: isSelected ? 2.0 : 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: widget.isDark ? 0.25 : 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.network(
                                poi['image'] as String,
                                width: double.infinity,
                                height: 96,
                                fit: BoxFit.cover,
                                errorBuilder: (ctx, error, stackTrace) => Container(
                                  height: 96,
                                  color: poi['color'] as Color,
                                  child: Center(
                                    child: Icon(poi['icon'] as IconData, size: 36, color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 8,
                              left: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: emerald,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  poi['detour'] as String,
                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.65),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  poi['hours'] as String,
                                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        Text(
                          poi['title'] as String,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: widget.isDark ? Colors.white : textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${poi['subtitle']} • ${poi['distance']}',
                          style: TextStyle(
                            fontSize: 12,
                            color: widget.isDark ? Colors.white60 : textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 4),

                        Text(
                          poi['quote'] as String,
                          style: TextStyle(
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                            color: widget.isDark ? Colors.white70 : const Color(0xFF475569),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const Spacer(),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: (poi['tags'] as List<String>).take(2).map((t) {
                                    return Container(
                                      margin: const EdgeInsets.only(right: 6),
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE6F7F0),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: const Color(0xFFA3E6D2)),
                                      ),
                                      child: Text(
                                        t,
                                        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: emerald,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              icon: const Icon(Symbols.add_location_alt, size: 16),
                              label: const Text('Add Pitstop', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              onPressed: () => widget.onPitStopAdd(poi['title'] as String),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 3. SNAP SIZE 0.80: FULL POI DETAILS SCREEN VIEW
  // ---------------------------------------------------------------------------

  Widget _buildFullDetailsScreenView(BuildContext context) {
    final poi = _pitstops[_selectedPoiIndex];

    return SingleChildScrollView(
      controller: widget.scrollController,
      physics: const ClampingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Swipable Landmark Selector Chips Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(_pitstops.length, (index) {
                  final item = _pitstops[index];
                  final isSelected = index == _selectedPoiIndex;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      selected: isSelected,
                      label: Text(item['title'] as String),
                      selectedColor: emerald,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : (widget.isDark ? Colors.white70 : textPrimary),
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedPoiIndex = index;
                            if (_pageController.hasClients) {
                              _pageController.animateToPage(
                                index,
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeOut,
                              );
                            }
                          });
                        }
                      },
                    ),
                  );
                }),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Full-Width Hero Photo Header (Details Screen Layout)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Stack(
                children: [
                  Image.network(
                    poi['image'] as String,
                    width: double.infinity,
                    height: 180,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, error, stackTrace) => Container(
                      height: 180,
                      color: poi['color'] as Color,
                      child: Center(
                        child: Icon(poi['icon'] as IconData, size: 54, color: Colors.white),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.2),
                            Colors.black.withValues(alpha: 0.75),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: emerald,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        poi['detour'] as String,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        poi['rating'] as String,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.amberAccent),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 14,
                    left: 14,
                    right: 14,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          poi['fullTitle'] as String,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          poi['subtitle'] as String,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Quick Info Grid Row (Hours, Fee, Parking, Weather)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildInfoBadge(Symbols.schedule, poi['hours'] as String, widget.isDark),
                _buildInfoBadge(Symbols.confirmation_number, poi['fee'] as String, widget.isDark),
                _buildInfoBadge(Symbols.local_parking, poi['parking'] as String, widget.isDark),
                _buildInfoBadge(Symbols.wb_sunny, poi['weather'] as String, widget.isDark),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Heritage Description Narrative Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'HERITAGE & HISTORY',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                    color: widget.isDark ? Colors.white54 : textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  poi['description'] as String,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.45,
                    color: widget.isDark ? Colors.white : textPrimary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Driver Review Quote Block
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: widget.isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: widget.isDark ? AppTheme.darkBorder : borderColor),
              ),
              child: Row(
                children: [
                  const Icon(Symbols.format_quote, color: emerald, size: 24),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      poi['quote'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: widget.isDark ? Colors.white70 : const Color(0xFF334155),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Action CTAs Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: emerald,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      ),
                      icon: const Icon(Symbols.add_location_alt, size: 20),
                      label: const Text('Add Pitstop to Route', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      onPressed: () => widget.onPitStopAdd(poi['title'] as String),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton.filledTonal(
                  icon: const Icon(Symbols.share, size: 20),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Sharing ${poi['title']} location link!'),
                        backgroundColor: AppTheme.primaryGreen,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Trip Metrics Section in Full Details View
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildTripMetrics(widget.navCtrl, widget.isDark),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildInfoBadge(IconData icon, String text, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCanvas : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppTheme.darkBorder : borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: emerald),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSnapIndicator(bool isDark, int currentSnapIndex) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(
        widget.snapSizes.length,
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

  Widget _buildTripMetrics(NavigationController navCtrl, bool isDark) {
    final etaString = TimeUtils.calculateEta(
      durationMinutes: navCtrl.remainingTimeMinutes,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
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
        onTap: widget.onConfirmExit,
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
