import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/context_header.dart';
import '../../../core/utils/time_utils.dart';
import '../controllers/history_controller.dart';
import '../models/search_history_model.dart';

class HistoryScreen extends StatefulWidget {
  final HistoryController? controller;
  final ValueChanged<SearchHistoryModel>? onReplayTrip;

  const HistoryScreen({super.key, this.controller, this.onReplayTrip});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _activeFilter = 'All Trips';

  static const _filters = ['All Trips', 'Scenic Corridors', 'Daily Commutes', 'Saved Places'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkCanvas : const Color(0xFFFAFBFC),
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: Stack(
        children: [
          Consumer<HistoryController>(
            builder: (context, ctrl, _) {
              final trips = ctrl.trips;
              final totalKm = trips.fold<double>(0, (s, t) => s + t.distanceKm);
              final totalScenic = trips.fold<int>(0, (s, t) => s + t.scenicStopsVisited);

              return CustomScrollView(
                slivers: [
                  // ── Context Header ────────────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ContextHeader(
                        title: 'Travel History',
                        isDark: isDark,
                        onBack: () => Navigator.of(context).maybePop(),
                        onProfile: () => ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Profile setup accessible from main menu.'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _statsCard(trips.length, totalKm, totalScenic, isDark),
                    ),
                  ),
                  SliverToBoxAdapter(child: const SizedBox(height: 16)),

                  // ── Filter Chips ──────────────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _filterChips(isDark),
                    ),
                  ),
                  SliverToBoxAdapter(child: const SizedBox(height: 16)),

                  // ── Trip List (stable sliver tree - no conditional slivers) ──
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (trips.isEmpty) {
                          return _emptyState(isDark);
                        }
                        if (index < trips.length) {
                          return _tripCard(trips[index], isDark, index == 0, context);
                        }
                        if (index == trips.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
                            child: _snapshotFooter(totalKm, totalScenic, trips.length, isDark),
                          );
                        }
                        return const SizedBox(height: 24);
                      },
                      childCount: trips.isEmpty ? 1 : trips.length + 2,
                    ),
                  ),
                ],
              );
            },
          ),

          // ── Clear Confirmation Modal (overlay) ─────────────────
          Consumer<HistoryController>(
            builder: (context, ctrl, _) {
              if (!ctrl.showClearModal) return const SizedBox.shrink();
              return _clearModal(ctrl, context);
            },
          ),
        ],
      ),
      ),
    );
  }

  // ── Stats Card ─────────────────────────────────────────────────────────

  Widget _statsCard(int tripCount, double totalKm, int scenicCount, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1c1b1e) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? const Color(0xFF363436) : const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06), blurRadius: 12, offset: const Offset(0, 2)),
        ],
      ),
      child: Stack(
        children: [
          // Decorative glow
          Positioned(
            right: -24,
            top: -24,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryGreen.withValues(alpha: 0.07),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(color: AppTheme.primaryGreen, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'SPATIAL LOG & TELEMETRY',
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen, letterSpacing: 0.8),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  style: TextStyle(fontSize: 13, color: isDark ? Colors.white70 : const Color(0xFF475569)),
                  children: [
                    TextSpan(text: '$tripCount ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: isDark ? Colors.white : const Color(0xFF0F172A))),
                    TextSpan(text: 'trips recorded • '),
                    TextSpan(text: totalKm.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m.group(1)},'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: isDark ? Colors.white : const Color(0xFF0F172A))),
                    TextSpan(text: ' km traveled • '),
                    TextSpan(text: '$scenicCount ', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: AppTheme.primaryGreen)),
                    TextSpan(text: 'scenic corridors discovered'),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text('Monthly Velocity', style: TextStyle(fontSize: 11, color: isDark ? Colors.white.withValues(alpha: 0.4) : const Color(0xFF64748B))),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: AppTheme.primaryGreen.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: AppTheme.primaryGreen.withValues(alpha: 0.3))),
                    child: const Text('+14.2%', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen)),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Filter Chips ────────────────────────────────────────────────────────

  Widget _filterChips(bool isDark) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final filter = _filters[i];
          final active = filter == _activeFilter;
          return GestureDetector(
            onTap: () => setState(() => _activeFilter = filter),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: active ? AppTheme.primaryGreen : (isDark ? const Color(0xFF1c1b1e) : Colors.white),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: active ? AppTheme.primaryGreen : (isDark ? const Color(0xFF363436) : const Color(0xFFE2E8F0))),
                boxShadow: active
                    ? [BoxShadow(color: AppTheme.primaryGreen.withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 2))]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (filter == 'Scenic Corridors') ...[
                    const Icon(Symbols.alt_route, size: 14, color: Color(0xFF059669)),
                    const SizedBox(width: 4),
                  ],
                  if (filter == 'Saved Places') ...[
                    const Icon(Symbols.bookmark, size: 14, color: Color(0xFF059669)),
                    const SizedBox(width: 4),
                  ],
                  Text(
                    filter,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                      color: active ? Colors.white : (isDark ? Colors.white60 : const Color(0xFF374151)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Trip Card ───────────────────────────────────────────────────────────

  Widget _tripCard(SearchHistoryModel trip, bool isDark, bool isFirst, BuildContext ctx) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1c1b1e) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? const Color(0xFF363436) : const Color(0xFFE2E8F0)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left accent bar
          if (isFirst)
            Container(width: 3, height: 4, color: AppTheme.primaryGreen),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Icon circle
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.primaryGreen.withValues(alpha: 0.2)),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(Symbols.navigation, size: 22, color: AppTheme.primaryGreen),
                      Positioned(
                        right: 2,
                        bottom: 2,
                        child: Container(width: 10, height: 10, decoration: const BoxDecoration(color: AppTheme.primaryGreen, shape: BoxShape.circle),),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Title + metadata
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trip.title,
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF0F172A)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${_formatDate(trip.timestamp)} • ${trip.distanceKm.toStringAsFixed(1)} km • ${TimeUtils.formatMinutes(trip.durationMinutes)}',
                        style: TextStyle(fontSize: 11, color: isDark ? Colors.white.withValues(alpha: 0.4) : const Color(0xFF64748B)),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          _tag(ctx, Symbols.filter_vintage, '+${trip.scenicStopsVisited} Corridor Detour', AppTheme.primaryGreen, isDark),
                          _tag(ctx, Symbols.eco, '${(trip.fuelEfficiencyKmL / 18.4 * 100).round()}% Eco-Pace', const Color(0xFF059669), isDark),
                          if (trip.badgeEarned.isNotEmpty)
                            _tag(ctx, Symbols.workspace_premium, trip.badgeEarned, const Color(0xFFF59E0B), isDark),
                        ],
                      ),
                    ],
                  ),
                ),
                // Replay button
                _replayBtn(ctx),
              ],
            ),
          ),
          // Telemetry strip
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 14),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0f0e10) : const Color(0xFFF8FAF9),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: isDark ? const Color(0xFF363436) : const Color(0xFFF1F5F9)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Symbols.speed, size: 15, color: Color(0xFF059669)),
                    const SizedBox(width: 4),
                    Text(
                      'Avg: ${(trip.distanceKm / trip.durationMinutes * 60).toStringAsFixed(0)} km/h',
                      style: TextStyle(fontSize: 11, color: isDark ? Colors.white60 : const Color(0xFF475569)),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Symbols.cloud_done, size: 15, color: Color(0xFF2563EB)),
                    const SizedBox(width: 4),
                    Text('Clear • 29°C', style: TextStyle(fontSize: 11, color: isDark ? Colors.white.withValues(alpha: 0.4) : const Color(0xFF64748B))),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tag(BuildContext context, IconData icon, String label, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 3),
          Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }

  Widget _replayBtn(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () {
        // pulse animation feedback
      },
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(color: const Color(0xFFF1F5F9), shape: BoxShape.circle),
        child: Icon(Symbols.near_me, size: 18, color: isDark ? Colors.white70 : const Color(0xFF64748B)),
      ),
    );
  }

  // ── Snapshot Footer ────────────────────────────────────────────────────

  Widget _snapshotFooter(double totalKm, int scenicCount, int tripCount, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1c1b1e) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF363436) : const Color(0xFFE2E8F0)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Symbols.insights, size: 18, color: AppTheme.primaryGreen),
              const SizedBox(width: 8),
              Text('Exploration Snapshot', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF0F172A))),
              const Spacer(),
              Text('Top Sector: Savar West', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen, letterSpacing: 0.5)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _statTile((totalKm / (tripCount > 0 ? tripCount : 1)).toStringAsFixed(1), 'Km / Trip Avg', isDark),
              const SizedBox(width: 10),
              _statTile('$scenicCount', 'Stops Logged', isDark),
              const SizedBox(width: 10),
              _statTile('100%', 'GPS Precision', isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statTile(String value, String label, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: isDark ? const Color(0xFF0f0e10) : const Color(0xFFF8FAF9), borderRadius: BorderRadius.circular(12), border: Border.all(color: isDark ? const Color(0xFF363436) : const Color(0xFFF1F5F9))),
        child: Column(
          children: [
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen, letterSpacing: -0.5)),
            const SizedBox(height: 2),
            Text(
              'Start navigating to log your first scenic corridor journey.',
              style: TextStyle(fontSize: 13, color: isDark ? Colors.white.withValues(alpha: 0.4) : const Color(0xFF64748B)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ── Empty State ─────────────────────────────────────────────────────────

  Widget _emptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(color: AppTheme.primaryGreen.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: const Icon(Symbols.explore, size: 32, color: AppTheme.primaryGreen),
            ),
            const SizedBox(height: 16),
            Text('Your Trail is Fresh', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF0F172A))),
            const SizedBox(height: 6),
            Text(
              'Start navigating to log your first scenic corridor journey.',
              style: TextStyle(fontSize: 13, color: isDark ? Colors.white.withValues(alpha: 0.4) : const Color(0xFF64748B)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ── Clear Button ────────────────────────────────────────────────────────

  Widget _clearAllBtn(bool isDark) {
    return GestureDetector(
      onTap: () => (widget.controller ?? context.read<HistoryController>()).toggleClearModal(true),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1B1E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFFECACA)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Symbols.delete_sweep, size: 14, color: Color(0xFFDC2626)),
            SizedBox(width: 4),
            Text('Clear All', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFFDC2626))),
          ],
        ),
      ),
    );
  }

  // ── Clear Modal ─────────────────────────────────────────────────────────

  Widget _clearModal(HistoryController ctrl, BuildContext ctx) {
    final isDark = Theme.of(ctx).brightness == Brightness.dark;
    return Container(
      color: Colors.black.withValues(alpha: 0.5),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 24, offset: const Offset(0, 8))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(width: 40, height: 40, decoration: BoxDecoration(color: const Color(0xFFFEE2E2), shape: BoxShape.circle), child: const Icon(Symbols.warning, size: 22, color: Color(0xFFDC2626))),
                  const SizedBox(width: 12),
                  Text('Clear Travel History?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF0F172A))),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'This will permanently purge all ${ctrl.trips.length} logged trips and telemetry. Saved places remain intact.',
                style: const TextStyle(fontSize: 13, color: Color(0xFF475569)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => ctrl.toggleClearModal(false),
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: const Text('Cancel', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        ctrl.clearHistory();
                        ctrl.toggleClearModal(false);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: const Text('Clear Everything', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
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

  String _formatDate(DateTime dt) {
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }
}
