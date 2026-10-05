import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import '../../../core/config/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../controllers/place_search_controller.dart';
import '../models/place_model.dart';
import 'search_view.dart';

/// Screen 4: Search & Autocomplete Screen designed precisely according to HTML Specification
class SearchScreen extends StatefulWidget {
  final PlaceSearchController? controller;
  final ValueChanged<PlaceModel>? onPlaceSelected;

  const SearchScreen({
    super.key,
    this.controller,
    this.onPlaceSelected,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  @override
  Widget build(BuildContext context) {
    final searchController = widget.controller ?? context.watch<PlaceSearchController>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgBackgroundColor = isDark ? AppTheme.darkCanvas : const Color(0xFFFAFBFC);
    final cardBackgroundColor = isDark ? AppTheme.darkCard : Colors.white;
    final primaryTextColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor = isDark ? Colors.white60 : const Color(0xFF475569);
    final borderColor = isDark ? AppTheme.darkBorder : const Color(0xFFE2E8F0);

    return Scaffold(
      backgroundColor: bgBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Input & Quick Filter Chips
              SearchView(
                controller: searchController,
                onBackTap: () => context.go(AppRoutes.map),
              ),

              const SizedBox(height: 16),

              // Autocomplete Suggestions Card ("Glass Corridor")
              Container(
                decoration: BoxDecoration(
                  color: cardBackgroundColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildSuggestionItem(
                      title: 'Lalbagh Fort, Lalbagh Road, Dhaka',
                      subtitle: 'Old Dhaka, 1211',
                      distance: '4.5 km',
                      duration: '15 min',
                      isHighlighted: true,
                      isDark: isDark,
                      primaryTextColor: primaryTextColor,
                      secondaryTextColor: secondaryTextColor,
                      onTap: () {
                        final place = searchController.results.first;
                        if (widget.onPlaceSelected != null) {
                          widget.onPlaceSelected!(place);
                        } else {
                          context.push(AppRoutes.routePreview);
                        }
                      },
                    ),
                    Divider(height: 1, color: borderColor),
                    _buildSuggestionItem(
                      title: 'Ahsan Manzil (Pink Palace)',
                      subtitle: 'Kumartoli, Old Dhaka',
                      distance: '5.8 km',
                      duration: '22 min',
                      isHighlighted: false,
                      isDark: isDark,
                      primaryTextColor: primaryTextColor,
                      secondaryTextColor: secondaryTextColor,
                      onTap: () => context.push(AppRoutes.routePreview),
                    ),
                    Divider(height: 1, color: borderColor),
                    _buildSuggestionItem(
                      title: 'Curzon Hall, University of Dhaka',
                      subtitle: 'High Court St, Ramna',
                      distance: '3.2 km',
                      duration: '10 min',
                      isHighlighted: false,
                      isDark: isDark,
                      primaryTextColor: primaryTextColor,
                      secondaryTextColor: secondaryTextColor,
                      onTap: () => context.push(AppRoutes.routePreview),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Curated Visual Mini-Banner ("Explore Lalbagh Gardens")
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkCard : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              CircleAvatar(radius: 3, backgroundColor: AppTheme.primaryGreen),
                              SizedBox(width: 6),
                              Text(
                                'MUGHAL HERITAGE CORRIDOR',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.8,
                                  color: AppTheme.primaryGreen,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Explore Lalbagh Gardens',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: primaryTextColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'South gate pedestrian route open today',
                            style: TextStyle(
                              fontSize: 12,
                              color: secondaryTextColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        'https://images.unsplash.com/photo-1588416936097-41850ab3d86d?w=400',
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Recent Destinations / History Area
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Symbols.history, size: 18, color: primaryTextColor),
                      const SizedBox(width: 6),
                      Text(
                        'RECENT TRIPS',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                          color: primaryTextColor,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Clear',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // List of Recent Trips
              Column(
                children: [
                  _buildRecentTripTile(
                    icon: Symbols.route,
                    title: 'Gulshan-2 Circle → Dhanmondi 27',
                    subtitle: 'Yesterday, 5:40 PM • 9.4 km',
                    isDark: isDark,
                    cardBackgroundColor: cardBackgroundColor,
                    borderColor: borderColor,
                    primaryTextColor: primaryTextColor,
                    secondaryTextColor: secondaryTextColor,
                    onTap: () => context.push(AppRoutes.routePreview),
                  ),
                  const SizedBox(height: 8),
                  _buildRecentTripTile(
                    icon: Symbols.local_cafe,
                    title: 'North End Coffee Roasters',
                    subtitle: 'Oct 28 • Banani 11',
                    isDark: isDark,
                    cardBackgroundColor: cardBackgroundColor,
                    borderColor: borderColor,
                    primaryTextColor: primaryTextColor,
                    secondaryTextColor: secondaryTextColor,
                    onTap: () => context.push(AppRoutes.routePreview),
                  ),
                  const SizedBox(height: 8),
                  _buildRecentTripTile(
                    icon: Symbols.local_airport,
                    title: 'Hazrat Shahjalal Intl. Airport (DAC)',
                    subtitle: 'Oct 24 • Kurmitola, Terminal 2',
                    isDark: isDark,
                    cardBackgroundColor: cardBackgroundColor,
                    borderColor: borderColor,
                    primaryTextColor: primaryTextColor,
                    secondaryTextColor: secondaryTextColor,
                    onTap: () => context.push(AppRoutes.routePreview),
                  ),
                ],
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionItem({
    required String title,
    required String subtitle,
    required String distance,
    required String duration,
    required bool isHighlighted,
    required bool isDark,
    required Color primaryTextColor,
    required Color secondaryTextColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: isHighlighted ? const Color(0xFFE6F7F0) : (isDark ? AppTheme.darkCanvas : const Color(0xFFF1F5F9)),
        child: Icon(
          Symbols.location_on,
          size: 18,
          color: isHighlighted ? AppTheme.primaryGreen : secondaryTextColor,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w600,
          color: primaryTextColor,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: secondaryTextColor),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            distance,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isHighlighted ? AppTheme.primaryGreen : primaryTextColor,
            ),
          ),
          Text(
            duration,
            style: TextStyle(fontSize: 11, color: secondaryTextColor),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildRecentTripTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
    required Color cardBackgroundColor,
    required Color borderColor,
    required Color primaryTextColor,
    required Color secondaryTextColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: ListTile(
        onTap: onTap,
        tileColor: cardBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: borderColor, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: CircleAvatar(
          radius: 18,
          backgroundColor: isDark ? AppTheme.darkCanvas : const Color(0xFFF1F5F9),
          child: Icon(icon, size: 18, color: secondaryTextColor),
        ),
        title: Text(
          title,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: primaryTextColor),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 11, color: secondaryTextColor),
        ),
        trailing: IconButton(
          icon: const Icon(Symbols.navigation, size: 18, color: AppTheme.primaryGreen),
          onPressed: onTap,
        ),
      ),
    );
  }
}
