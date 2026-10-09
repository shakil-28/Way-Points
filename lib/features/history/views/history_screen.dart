import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/context_header.dart';
import '../../../core/utils/time_utils.dart';
import '../controllers/history_controller.dart';
import '../models/search_history_model.dart';

/// Redesigned Travel History & Expedition Analytics Screen with native custom diagram charts
class HistoryScreen extends StatefulWidget {
  final HistoryController? controller;
  final ValueChanged<SearchHistoryModel>? onReplayTrip;

  const HistoryScreen({
    super.key,
    this.controller,
    this.onReplayTrip,
  });

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _selectedFilter = 'All Trips';

  final List<String> _filterCategories = [
    'All Trips',
    'Scenic Trail',
    'Heritage',
    'Waterfront',
  ];

  @override
  Widget build(BuildContext context) {
    final histCtrl = widget.controller ?? context.watch<HistoryController>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardBackgroundColor = isDark ? AppTheme.darkCard : Colors.white;
    final primaryTextColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor = isDark ? Colors.white60 : const Color(0xFF64748B);
    final borderColor = isDark ? AppTheme.darkBorder : const Color(0xFFE2E8F0);

    final filteredTrips = histCtrl.trips.where((t) {
      if (_selectedFilter == 'All Trips') return true;
      return t.category.toLowerCase().contains(_selectedFilter.toLowerCase());
    }).toList();

    final totalKm = histCtrl.trips.fold<double>(0, (sum, t) => sum + t.distanceKm);
    final totalDurationMin = histCtrl.trips.fold<int>(0, (sum, t) => sum + t.durationMinutes);

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkCanvas : const Color(0xFFFAFBFC),
      body: SafeArea(
        child: Column(
          children: [
            // Top Context Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ContextHeader(
                title: 'Travel History',
                isDark: isDark,
                onBack: () => Navigator.of(context).maybePop(),
                onProfile: () {},
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ---------------------------------------------------------
                    // 1. ANALYTICS & DIAGRAMS DASHBOARD CARD
                    // ---------------------------------------------------------
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: cardBackgroundColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: borderColor),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
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
                                  const Text(
                                    'EXPEDITION STATS & ANALYTICS',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.0,
                                      color: AppTheme.primaryGreen,
                                    ),
                                  ),
                                ],
                              ),
                              if (histCtrl.trips.isNotEmpty)
                                GestureDetector(
                                  onTap: () => histCtrl.clearHistory(),
                                  child: const Text(
                                    'Clear Log',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.redAccent,
                                    ),
                                  ),
                                ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // 3 Metric Badges Grid
                          Row(
                            children: [
                              _buildMetricTile(
                                value: '${totalKm.toStringAsFixed(1)} km',
                                label: 'Total Distance',
                                icon: Symbols.distance,
                                isDark: isDark,
                                primaryTextColor: primaryTextColor,
                                secondaryTextColor: secondaryTextColor,
                              ),
                              const SizedBox(width: 8),
                              _buildMetricTile(
                                value: '${histCtrl.trips.length}',
                                label: 'Expeditions',
                                icon: Symbols.explore,
                                isDark: isDark,
                                primaryTextColor: primaryTextColor,
                                secondaryTextColor: secondaryTextColor,
                              ),
                              const SizedBox(width: 8),
                              _buildMetricTile(
                                value: TimeUtils.formatMinutes(totalDurationMin),
                                label: 'Driving Time',
                                icon: Symbols.schedule,
                                isDark: isDark,
                                primaryTextColor: primaryTextColor,
                                secondaryTextColor: secondaryTextColor,
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),
                          const Divider(height: 1),
                          const SizedBox(height: 16),

                          // Diagram 1: Weekly Drive Volume Bar Chart
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Weekly Distance Trend',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: primaryTextColor,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE6F7F0),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFFA3E6D2)),
                                ),
                                child: const Text(
                                  'Peak: 194.5 km',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryGreen,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          // Custom Bar Chart Painter
                          SizedBox(
                            height: 90,
                            child: CustomPaint(
                              painter: _WeeklyDistanceBarPainter(
                                isDark: isDark,
                                distances: const [28.0, 42.0, 15.0, 194.5, 30.0, 65.0, 12.0],
                                days: const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
                              ),
                              child: const SizedBox.expand(),
                            ),
                          ),

                          const SizedBox(height: 20),
                          const Divider(height: 1),
                          const SizedBox(height: 16),

                          // Diagram 2: Category Exploration Ring / Donut Chart
                          Row(
                            children: [
                              // Donut Ring Chart Painter
                              SizedBox(
                                width: 70,
                                height: 70,
                                child: CustomPaint(
                                  painter: _CategoryDonutPainter(
                                    percentages: const [0.55, 0.25, 0.20],
                                    colors: const [
                                      AppTheme.primaryGreen,
                                      Colors.amber,
                                      Colors.blueAccent,
                                    ],
                                  ),
                                  child: const Center(
                                    child: Icon(Symbols.donut_large, size: 20, color: AppTheme.primaryGreen),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Category Breakdown Legend
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Corridor Category Breakdown',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: primaryTextColor,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    _buildLegendRow('Scenic Trails', '55%', AppTheme.primaryGreen, primaryTextColor),
                                    const SizedBox(height: 4),
                                    _buildLegendRow('Waterfront & Ghats', '25%', Colors.amber, primaryTextColor),
                                    const SizedBox(height: 4),
                                    _buildLegendRow('Heritage Sites', '20%', Colors.blueAccent, primaryTextColor),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ---------------------------------------------------------
                    // 2. FILTER CATEGORY CHIPS
                    // ---------------------------------------------------------
                    SizedBox(
                      height: 34,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _filterCategories.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final cat = _filterCategories[index];
                          final isSelected = _selectedFilter == cat;

                          return ChoiceChip(
                            label: Text(
                              cat,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                color: isSelected
                                    ? Colors.white
                                    : (isDark ? Colors.white70 : const Color(0xFF1E293B)),
                              ),
                            ),
                            selected: isSelected,
                            selectedColor: AppTheme.primaryGreen,
                            backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
                            side: BorderSide(
                              color: isSelected
                                  ? AppTheme.primaryGreen
                                  : borderColor,
                            ),
                            onSelected: (_) {
                              setState(() {
                                _selectedFilter = cat;
                              });
                            },
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ---------------------------------------------------------
                    // 3. CHRONOLOGICAL EXPEDITION TIMELINE CARDS
                    // ---------------------------------------------------------
                    if (filteredTrips.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Column(
                            children: [
                              Icon(Symbols.history_toggle_off, size: 48, color: secondaryTextColor),
                              const SizedBox(height: 12),
                              Text('No trips match this filter category.', style: TextStyle(color: secondaryTextColor)),
                            ],
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredTrips.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final trip = filteredTrips[index];
                          return _buildTripTimelineCard(
                            trip: trip,
                            isDark: isDark,
                            cardBackgroundColor: cardBackgroundColor,
                            borderColor: borderColor,
                            primaryTextColor: primaryTextColor,
                            secondaryTextColor: secondaryTextColor,
                            onReplay: () {
                              if (widget.onReplayTrip != null) {
                                widget.onReplayTrip!(trip);
                              }
                            },
                          );
                        },
                      ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile({
    required String value,
    required String label,
    required IconData icon,
    required bool isDark,
    required Color primaryTextColor,
    required Color secondaryTextColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCanvas : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isDark ? AppTheme.darkBorder : const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: AppTheme.primaryGreen),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: primaryTextColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: secondaryTextColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendRow(String title, String percentage, Color color, Color textColor) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(title, style: TextStyle(fontSize: 11, color: textColor, fontWeight: FontWeight.w500)),
        const Spacer(),
        Text(percentage, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildTripTimelineCard({
    required SearchHistoryModel trip,
    required bool isDark,
    required Color cardBackgroundColor,
    required Color borderColor,
    required Color primaryTextColor,
    required Color secondaryTextColor,
    required VoidCallback onReplay,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Symbols.route, color: AppTheme.primaryGreen, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trip.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: primaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${trip.distanceKm.toStringAsFixed(1)} km • ${TimeUtils.formatMinutes(trip.durationMinutes)}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${trip.destination} • ${TimeUtils.formatTimestamp(trip.timestamp)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              OutlinedButton.icon(
                icon: const Icon(Symbols.replay, size: 14, color: AppTheme.primaryGreen),
                label: const Text('Replay', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  side: const BorderSide(color: AppTheme.primaryGreen),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: onReplay,
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 10),

          // Telemetry Badges & Fuel Economy
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Symbols.local_gas_station, size: 14, color: AppTheme.primaryGreen),
                  const SizedBox(width: 4),
                  Text(
                    '${trip.fuelEfficiencyKmL} km/L Fuel Economy',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: secondaryTextColor,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.amber.shade900.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber, width: 0.8),
                ),
                child: Row(
                  children: [
                    const Icon(Symbols.workspace_premium, size: 12, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      trip.badgeEarned,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Native Custom Painter for Weekly Driving Distance Trend Bar Chart
class _WeeklyDistanceBarPainter extends CustomPainter {
  final bool isDark;
  final List<double> distances;
  final List<String> days;

  _WeeklyDistanceBarPainter({
    required this.isDark,
    required this.distances,
    required this.days,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final maxDist = distances.reduce(math.max);
    final barWidth = 14.0;
    final spacing = (size.width - (distances.length * barWidth)) / (distances.length + 1);

    final bgPaint = Paint()
      ..color = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)
      ..style = PaintingStyle.fill;

    final activePaint = Paint()
      ..color = AppTheme.primaryGreen
      ..style = PaintingStyle.fill;

    final peakPaint = Paint()
      ..color = AppTheme.accentNeon
      ..style = PaintingStyle.fill;

    for (int i = 0; i < distances.length; i++) {
      final x = spacing + i * (barWidth + spacing);
      final heightRatio = (distances[i] / maxDist).clamp(0.15, 1.0);
      final barHeight = (size.height - 20) * heightRatio;
      final y = (size.height - 20) - barHeight;

      // Draw background bar slot
      final bgRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, 0, barWidth, size.height - 20),
        const Radius.circular(6),
      );
      canvas.drawRRect(bgRect, bgPaint);

      // Draw active distance bar
      final isPeak = distances[i] == maxDist;
      final activeRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, barWidth, barHeight),
        const Radius.circular(6),
      );
      canvas.drawRRect(activeRect, isPeak ? peakPaint : activePaint);

      // Draw day label text below bar
      final textPainter = TextPainter(
        text: TextSpan(
          text: days[i],
          style: TextStyle(
            fontSize: 9,
            fontWeight: isPeak ? FontWeight.bold : FontWeight.w500,
            color: isPeak ? AppTheme.primaryGreen : (isDark ? Colors.white60 : const Color(0xFF64748B)),
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x + (barWidth - textPainter.width) / 2, size.height - 14));
    }
  }

  @override
  bool shouldRepaint(covariant _WeeklyDistanceBarPainter oldDelegate) => true;
}

/// Native Custom Painter for Category Exploration Donut Ring Chart
class _CategoryDonutPainter extends CustomPainter {
  final List<double> percentages;
  final List<Color> colors;

  _CategoryDonutPainter({
    required this.percentages,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 6;
    const strokeWidth = 10.0;

    double startAngle = -math.pi / 2;

    for (int i = 0; i < percentages.length; i++) {
      final sweepAngle = 2 * math.pi * percentages[i];
      final paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle + 0.08,
        sweepAngle - 0.16,
        false,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _CategoryDonutPainter oldDelegate) => true;
}
