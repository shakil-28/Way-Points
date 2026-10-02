import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/time_utils.dart';
import '../controllers/history_controller.dart';
import '../models/search_history_model.dart';

class HistoryScreen extends StatelessWidget {
  final HistoryController? controller;
  final ValueChanged<SearchHistoryModel>? onReplayTrip;

  const HistoryScreen({
    super.key,
    this.controller,
    this.onReplayTrip,
  });

  @override
  Widget build(BuildContext context) {
    final histCtrl = controller ?? context.watch<HistoryController>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Navigated Corridors'),
        actions: [
          IconButton(
            icon: const Icon(Symbols.delete_sweep),
            tooltip: 'Clear History',
            onPressed: () => histCtrl.clearHistory(),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: histCtrl,
        builder: (context, _) {
          final trips = histCtrl.trips;

          if (trips.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Symbols.history,
                    size: 48,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'No previous journeys recorded yet.',
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: trips.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final trip = trips[index];

              return Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Symbols.route,
                      color: AppTheme.accentNeon,
                      size: 24,
                    ),
                  ),
                  title: Text(
                    trip.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        '${trip.distanceKm.toStringAsFixed(1)} km • '
                            '${TimeUtils.formatMinutes(trip.durationMinutes)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? Colors.white60
                              : Colors.black54,
                        ),
                      ),
                      Text(
                        '${trip.destination} • '
                            '${TimeUtils.formatTimestamp(trip.timestamp)}',
                        style: TextStyle(
                          fontSize: 10,
                          color: isDark
                              ? Colors.white38
                              : Colors.black38,
                        ),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(
                      Symbols.replay,
                      color: AppTheme.accentNeon,
                    ),
                    tooltip: 'Replay Corridor',
                    onPressed: () {
                      onReplayTrip?.call(trip);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}