import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../history/controllers/history_controller.dart';
import '../../map/controllers/map_controller.dart';
import '../../routing/controllers/routing_controller.dart';
import '../controllers/place_search_controller.dart';
import '../models/autocomplete_prediction_model.dart';
import '../models/place_model.dart';
import 'search_view.dart';

/// Production-ready Google Maps–Style Autocomplete Search Screen
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
  Future<void> _handlePredictionSelected(
    BuildContext context,
    PlaceSearchController searchCtrl,
    AutocompletePredictionModel prediction,
  ) async {
    FocusScope.of(context).unfocus();
    final routingCtrl = context.read<RoutingController>();
    final mapCtrl = context.read<MapController>();
    final messenger = ScaffoldMessenger.of(context);

    final resolvedPlace = await searchCtrl.selectPrediction(prediction);

    if (!mounted) return;

    if (resolvedPlace != null) {
      routingCtrl.fetchLiveDirections(
        destLat: resolvedPlace.latitude,
        destLng: resolvedPlace.longitude,
      );
      mapCtrl.showRoutePreview();
      if (widget.onPlaceSelected != null) {
        widget.onPlaceSelected!(resolvedPlace);
      }
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Text(searchCtrl.errorMessage ?? 'Could not resolve place details. Please try another place.'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _handleCuratedPlaceSelected(BuildContext context, PlaceModel place) {
    FocusScope.of(context).unfocus();
    context.read<RoutingController>().fetchLiveDirections(
      destLat: place.latitude,
      destLng: place.longitude,
    );
    context.read<MapController>().showRoutePreview();
    if (widget.onPlaceSelected != null) {
      widget.onPlaceSelected!(place);
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchController = widget.controller ?? context.watch<PlaceSearchController>();
    final historyController = context.watch<HistoryController>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgBackgroundColor = isDark ? AppTheme.darkCanvas : const Color(0xFFFAFBFC);
    final cardBackgroundColor = isDark ? AppTheme.darkCard : Colors.white;
    final primaryTextColor = isDark ? Colors.white : AppTheme.textPrimary;
    final secondaryTextColor = isDark ? Colors.white60 : const Color(0xFF475569);
    final borderColor = isDark ? AppTheme.darkBorder : AppTheme.lightBorder;

    final predictionsList = searchController.predictions;
    final curatedList = searchController.curatedDestinations;
    final recentTrips = historyController.trips;
    final isQueryActive = searchController.query.length >= 2;

    return Scaffold(
      backgroundColor: bgBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Floating Search Bar & Category Filter Chips
                  SearchView(
                    controller: searchController,
                    onBackTap: () {
                      FocusScope.of(context).unfocus();
                      final fallback = curatedList.isNotEmpty ? curatedList.first : PlaceSearchController.allDestinations.first;
                      _handleCuratedPlaceSelected(context, fallback);
                    },
                  ),

                  const SizedBox(height: 16),

                  // -------------------------------------------------------------
                  // 1. LIVE GOOGLE MAPS AUTOCOMPLETE PREDICTIONS LIST (When typing)
                  // -------------------------------------------------------------
                  if (isQueryActive) ...[
                    if (searchController.isLoading)
                      Container(
                        height: 120,
                        decoration: BoxDecoration(
                          color: cardBackgroundColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: borderColor),
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(color: AppTheme.primaryGreen),
                        ),
                      )
                    else if (searchController.errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cardBackgroundColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: borderColor),
                        ),
                        child: Column(
                          children: [
                            const Icon(Symbols.error, color: Colors.redAccent, size: 32),
                            const SizedBox(height: 8),
                            Text(
                              searchController.errorMessage!,
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 13, color: primaryTextColor),
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryGreen,
                                foregroundColor: Colors.white,
                              ),
                              icon: const Icon(Symbols.refresh, size: 16),
                              label: const Text('Retry Search'),
                              onPressed: searchController.retrySearch,
                            ),
                          ],
                        ),
                      )
                    else if (predictionsList.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: cardBackgroundColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: borderColor),
                        ),
                        child: Column(
                          children: [
                            const Icon(Symbols.search_off, size: 36, color: Colors.grey),
                            const SizedBox(height: 8),
                            Text(
                              'No matching places found for "${searchController.query}"',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: primaryTextColor),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Try searching for another town, address, or landmark.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 12, color: secondaryTextColor),
                            ),
                          ],
                        ),
                      )
                    else
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
                          children: predictionsList.map((prediction) {
                            final isLast = prediction == predictionsList.last;
                            return Column(
                              children: [
                                Material(
                                  color: Colors.transparent,
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                    leading: CircleAvatar(
                                      radius: 18,
                                      backgroundColor: isDark ? AppTheme.darkCanvas : const Color(0xFFF1F5F9),
                                      child: const Icon(Symbols.location_on, size: 18, color: AppTheme.primaryGreen),
                                    ),
                                    title: Text(
                                      prediction.primaryText,
                                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: primaryTextColor),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    subtitle: Text(
                                      prediction.secondaryText,
                                      style: TextStyle(fontSize: 12, color: secondaryTextColor),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    trailing: const Icon(Symbols.north_west, size: 16, color: Colors.grey),
                                    onTap: () => _handlePredictionSelected(context, searchController, prediction),
                                  ),
                                ),
                                if (!isLast) Divider(height: 1, color: borderColor),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                  ],

                  // -------------------------------------------------------------
                  // 2. CURATED BENGAL DISCOVERY DESTINATIONS (When query is empty)
                  // -------------------------------------------------------------
                  if (!isQueryActive) ...[
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
                        children: curatedList.take(4).map((place) {
                          final isLast = place == curatedList.take(4).last;
                          return Column(
                            children: [
                              Material(
                                color: Colors.transparent,
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                  leading: CircleAvatar(
                                    radius: 18,
                                    backgroundColor: isDark ? AppTheme.darkCanvas : const Color(0xFFE6F7F0),
                                    child: const Icon(Symbols.explore, size: 18, color: AppTheme.primaryGreen),
                                  ),
                                  title: Text(
                                    place.title,
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: primaryTextColor),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: Text(
                                    place.subtitle,
                                    style: TextStyle(fontSize: 12, color: secondaryTextColor),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  trailing: Text(
                                    place.distanceText,
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
                                  ),
                                  onTap: () => _handleCuratedPlaceSelected(context, place),
                                ),
                              ),
                              if (!isLast) Divider(height: 1, color: borderColor),
                            ],
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Curated Visual Mini-Banner ("Explore Lalbagh Gardens")
                    GestureDetector(
                      onTap: () {
                        final place = curatedList.first;
                        _handleCuratedPlaceSelected(context, place);
                      },
                      child: Container(
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
                    ),

                    const SizedBox(height: 20),

                    // Recent Destinations / History Area connected to HistoryController
                    if (recentTrips.isNotEmpty) ...[
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
                            onPressed: () {
                              historyController.clearHistory();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Recent trip search history cleared.'),
                                  backgroundColor: AppTheme.primaryGreen,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
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

                      Column(
                        children: recentTrips.map((trip) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Material(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                              child: ListTile(
                                onTap: () {
                                  final place = PlaceModel(
                                    id: trip.id,
                                    title: trip.title,
                                    subtitle: trip.destination,
                                    category: 'cultural',
                                    latitude: trip.destinationLat,
                                    longitude: trip.destinationLng,
                                  );
                                  _handleCuratedPlaceSelected(context, place);
                                },
                                tileColor: cardBackgroundColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: BorderSide(color: borderColor, width: 1),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                                leading: CircleAvatar(
                                  radius: 18,
                                  backgroundColor: isDark ? AppTheme.darkCanvas : const Color(0xFFF1F5F9),
                                  child: Icon(Symbols.route, size: 18, color: secondaryTextColor),
                                ),
                                title: Text(
                                  trip.title,
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: primaryTextColor),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  '${trip.origin} → ${trip.destination} • ${trip.distanceKm} km',
                                  style: TextStyle(fontSize: 11, color: secondaryTextColor),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: const Icon(Symbols.navigation, size: 18, color: AppTheme.primaryGreen),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],

                  const SizedBox(height: 16),
                ],
              ),
            ),

            // Resolving Place Details Loading Overlay
            if (searchController.isResolvingDetails)
              Container(
                color: Colors.black.withValues(alpha: 0.4),
                child: const Center(
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: AppTheme.primaryGreen),
                          SizedBox(height: 16),
                          Text(
                            'Resolving location coordinates...',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
