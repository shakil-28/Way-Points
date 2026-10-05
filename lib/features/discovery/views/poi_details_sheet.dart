import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../controllers/discovery_controller.dart';
import '../models/poi_model.dart';

/// Screen 3: Curated Corridor Discovery Draggable Sheet designed precisely according to HTML Specification
class PoiDetailsSheet extends StatefulWidget {
  final PoiModel? poi;
  final VoidCallback onAddStop;
  final VoidCallback onNavigateDirectly;
  final VoidCallback onClose;

  const PoiDetailsSheet({
    super.key,
    this.poi,
    required this.onAddStop,
    required this.onNavigateDirectly,
    required this.onClose,
  });

  @override
  State<PoiDetailsSheet> createState() => _PoiDetailsSheetState();
}

class _PoiDetailsSheetState extends State<PoiDetailsSheet> {
  String _selectedFavorite = 'Dhanmondi 27';

  final List<Map<String, dynamic>> _quickFavorites = [
    {'label': 'Home', 'icon': Symbols.home, 'color': AppTheme.primaryGreen},
    {'label': 'Work', 'icon': Symbols.work, 'color': Colors.blue},
    {'label': 'Dhanmondi 27', 'icon': Symbols.near_me, 'color': AppTheme.primaryGreen},
    {'label': "Cox's Bazar", 'icon': Symbols.beach_access, 'color': Colors.amber},
    {'label': 'Banani 11', 'icon': Symbols.restaurant, 'color': Colors.pink},
  ];

  @override
  Widget build(BuildContext context) {
    final activePoi = widget.poi ?? context.watch<DiscoveryController>().activePoi;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardBackgroundColor = isDark ? AppTheme.darkCard : Colors.white;
    final primaryTextColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor = isDark ? Colors.white60 : const Color(0xFF475569);
    final borderColor = isDark ? AppTheme.darkBorder : const Color(0xFFE2E8F0);

    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.25,
      maxChildSize: 0.90,
      snap: true,
      snapSizes: const [0.25, 0.55, 0.90],
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: cardBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                blurRadius: 30,
                offset: const Offset(0, -10),
              ),
            ],
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            children: [
              // Top drag handle bar
              Center(
                child: Container(
                  width: 48,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Quick Favorite Destination Chips Row
              SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _quickFavorites.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final fav = _quickFavorites[index];
                    final isSelected = _selectedFavorite == fav['label'];

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedFavorite = fav['label'] as String;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFE6F7F0)
                              : (isDark ? AppTheme.darkCanvas : Colors.white),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isSelected ? AppTheme.primaryGreen : borderColor,
                            width: isSelected ? 1.5 : 1.0,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              fav['icon'] as IconData,
                              size: 16,
                              color: isSelected ? AppTheme.primaryGreen : (fav['color'] as Color),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              fav['label'] as String,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                color: isSelected ? AppTheme.primaryGreen : primaryTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Section Header: Curated Corridor Discovery
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Symbols.auto_awesome, size: 20, color: AppTheme.primaryGreen),
                      const SizedBox(width: 8),
                      Text(
                        'Curated Corridor Discovery',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: primaryTextColor,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'NEARBY POI',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                      color: secondaryTextColor,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Rich POI Discovery Card
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkCanvas : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero Image with Overlays
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                          child: Image.network(
                            activePoi.imageUrl,
                            width: double.infinity,
                            height: 180,
                            fit: BoxFit.cover,
                          ),
                        ),
                        // Dark Gradient Overlay
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.8),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Top Badges
                        Positioned(
                          top: 12,
                          left: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryGreen,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              children: [
                                CircleAvatar(radius: 3, backgroundColor: AppTheme.accentNeon),
                                SizedBox(width: 6),
                                Text(
                                  'HISTORICAL LANDMARK',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFA3E6D2)),
                            ),
                            child: const Row(
                              children: [
                                Icon(Symbols.alt_route, size: 14, color: AppTheme.primaryGreen),
                                SizedBox(width: 4),
                                Text(
                                  '+10 MIN DETOUR',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryGreen,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Title & Location Overlay
                        Positioned(
                          bottom: 12,
                          left: 14,
                          right: 14,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                activePoi.name,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  shadows: [Shadow(color: Colors.black, blurRadius: 8)],
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  const Icon(Symbols.location_on, size: 14, color: AppTheme.accentNeon),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Lalbagh, Old Dhaka 1211 • ${activePoi.detourDistanceKm} km away',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white.withValues(alpha: 0.9),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // Content Padding Area
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // A Little History Section
                          const Row(
                            children: [
                              Icon(Symbols.menu_book, size: 16, color: AppTheme.primaryGreen),
                              SizedBox(width: 6),
                              Text(
                                'A LITTLE HISTORY',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.1,
                                  color: AppTheme.primaryGreen,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            activePoi.description,
                            style: TextStyle(
                              fontSize: 13,
                              color: primaryTextColor,
                              height: 1.4,
                            ),
                          ),

                          const SizedBox(height: 14),

                          // Review Quote Card
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDark ? AppTheme.darkCard : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: borderColor),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          '${activePoi.rating}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: primaryTextColor,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Row(
                                          children: List.generate(
                                            5,
                                                (i) => const Icon(Symbols.star, size: 14, color: Colors.amber),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          '(${activePoi.reviewCount} reviews)',
                                          style: TextStyle(fontSize: 11, color: secondaryTextColor),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE6F7F0),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: const Color(0xFFA3E6D2)),
                                      ),
                                      child: const Text(
                                        'Verified POI',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.primaryGreen,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(height: 16),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Symbols.format_quote, size: 16, color: secondaryTextColor),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '“A beautiful escape into history right in the heart of Old Dhaka!”',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontStyle: FontStyle.italic,
                                              color: primaryTextColor,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '— Rafid Ahmed',
                                            style: TextStyle(fontSize: 11, color: secondaryTextColor),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 14),

                          // Amenity Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              const Row(
                                children: [
                                  Icon(Symbols.local_parking, size: 16, color: AppTheme.primaryGreen),
                                  SizedBox(width: 4),
                                  Text('Parking Available', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
                                ],
                              ),
                              Container(width: 4, height: 4, decoration: BoxDecoration(color: borderColor, shape: BoxShape.circle)),
                              const Row(
                                children: [
                                  Icon(Symbols.schedule, size: 16, color: AppTheme.primaryGreen),
                                  SizedBox(width: 4),
                                  Text('Open • Closes 5 PM', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
                                ],
                              ),
                              Container(width: 4, height: 4, decoration: BoxDecoration(color: borderColor, shape: BoxShape.circle)),
                              const Row(
                                children: [
                                  Icon(Symbols.currency_exchange, size: 16, color: AppTheme.primaryGreen),
                                  SizedBox(width: 4),
                                  Text('৳20 Entry', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Primary Action CTA: Explore Route Detour
                          ElevatedButton(
                            onPressed: widget.onNavigateDirectly,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryGreen,
                              foregroundColor: Colors.white,
                              minimumSize: const Size.fromHeight(52),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                              elevation: 3,
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Symbols.directions, size: 22, color: Colors.white),
                                SizedBox(width: 8),
                                Text(
                                  'Explore Route Detour',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}
