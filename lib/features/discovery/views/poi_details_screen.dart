import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../controllers/discovery_controller.dart';
import '../models/poi_model.dart';

class PoiDetailsScreen extends StatelessWidget {
  final PoiModel? poi;
  final VoidCallback onAddStop;

  const PoiDetailsScreen({
    super.key,
    this.poi,
    required this.onAddStop,
  });

  @override
  Widget build(BuildContext context) {
    final activePoi = poi ?? context.watch<DiscoveryController>().activePoi;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Hero Image AppBar
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                activePoi.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black, blurRadius: 10)],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    activePoi.imageUrl,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.3),
                          Colors.transparent,
                          Colors.black.withOpacity(0.85),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content Details
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Detour Impact Highlight Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.accentNeon.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildMetric(
                          icon: Symbols.timer,
                          value: '+${activePoi.detourMinutes} min',
                          label: 'CORRIDOR DETOUR',
                        ),
                        Container(width: 1, height: 36, color: Colors.grey.withOpacity(0.3)),
                        _buildMetric(
                          icon: Symbols.distance,
                          value: '${activePoi.detourDistanceKm} km',
                          label: 'DEVIATION',
                        ),
                        Container(width: 1, height: 36, color: Colors.grey.withOpacity(0.3)),
                        _buildMetric(
                          icon: Symbols.star,
                          value: '${activePoi.rating}',
                          label: 'HERITAGE SCORE',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Historical Significance Section
                  Text(
                    'HISTORICAL SIGNIFICANCE',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    activePoi.historicSignificance,
                    style: const TextStyle(fontSize: 15, height: 1.5),
                  ),
                  const SizedBox(height: 20),

                  // Overview & Description
                  Text(
                    'SITE OVERVIEW',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    activePoi.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white70 : Colors.black87,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Best Time to Visit
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Symbols.sunny, color: Colors.amber),
                    title: const Text('Recommended Visit Timing', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(activePoi.bestTimeToVisit),
                  ),

                  const SizedBox(height: 10),
                  // Amenities
                  Text(
                    'ON-SITE AMENITIES',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: activePoi.amenities.map((a) {
                      return Chip(
                        label: Text(a, style: const TextStyle(fontSize: 12)),
                        avatar: const Icon(Symbols.check_circle, size: 16, color: AppTheme.accentNeon),
                        backgroundColor: isDark ? AppTheme.darkCard : AppTheme.lightCard,
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () {
                      onAddStop();
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Symbols.add_location_alt, size: 20, color: AppTheme.accentNeon),
                        SizedBox(width: 8),
                        Text('Add to Current Corridor Plan', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetric({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppTheme.accentNeon),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
