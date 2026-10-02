import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../controllers/place_search_controller.dart';
import '../models/place_model.dart';
import 'search_view.dart';

class SearchScreen extends StatefulWidget {
  final PlaceSearchController? controller;
  final ValueChanged<PlaceModel> onPlaceSelected;

  const SearchScreen({
    super.key,
    this.controller,
    required this.onPlaceSelected,
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Corridors & Places'),
        leading: IconButton(
          icon: const Icon(Symbols.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: searchController,
          builder: (context, _) {
            final results = searchController.results;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                children: [
                  SearchView(controller: searchController),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'FOUND DESTINATIONS (${results.length})',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                          color: isDark ? Colors.white38 : Colors.black45,
                        ),
                      ),
                      const Text(
                        'Verified Coordinates',
                        style: TextStyle(fontSize: 11, color: AppTheme.accentNeon),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: results.isEmpty
                        ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Symbols.explore_off, size: 48, color: Colors.grey.shade600),
                          const SizedBox(height: 12),
                          const Text('No corridor destinations match your query.'),
                        ],
                      ),
                    )
                        : ListView.separated(
                      itemCount: results.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final place = results[index];
                        return Card(
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                place.imageUrl,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 50,
                                  height: 50,
                                  color: AppTheme.primaryGreen.withOpacity(0.2),
                                  child: const Icon(Symbols.landscape, color: AppTheme.accentNeon),
                                ),
                              ),
                            ),
                            title: Text(
                              place.title,
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                            ),
                            subtitle: Text(
                              place.subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.white60 : Colors.black54,
                              ),
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  place.distanceText,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: AppTheme.accentNeon,
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Symbols.star, size: 12, color: Colors.amber),
                                    const SizedBox(width: 2),
                                    Text('${place.rating}', style: const TextStyle(fontSize: 11)),
                                  ],
                                ),
                              ],
                            ),
                            onTap: () => widget.onPlaceSelected(place),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
