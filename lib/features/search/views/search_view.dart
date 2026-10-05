import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../controllers/place_search_controller.dart';

/// Top Cyber-Spatial Floating Search Bar with microphone utility & quick category chips
class SearchView extends StatefulWidget {
  final PlaceSearchController? controller;
  final ValueChanged<String>? onSearchSubmitted;
  final VoidCallback? onBackTap;

  const SearchView({
    super.key,
    this.controller,
    this.onSearchSubmitted,
    this.onBackTap,
  });

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    final searchCtrl = widget.controller ?? context.read<PlaceSearchController>();
    _textController = TextEditingController(text: searchCtrl.query.isEmpty ? 'Lalbagh Fort' : searchCtrl.query);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchCtrl = widget.controller ?? context.watch<PlaceSearchController>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final categories = [
      {'emoji': '🕌', 'label': 'Mosques', 'id': 'mosques'},
      {'emoji': '🌴', 'label': 'Scenic', 'id': 'scenic'},
      {'emoji': '🛍️', 'label': 'Bazaars', 'id': 'bazaars'},
      {'emoji': '🍛', 'label': 'Restaurants', 'id': 'food'},
      {'emoji': '⛽', 'label': 'Fuel/Gas', 'id': 'fuel'},
      {'emoji': '🏡', 'label': 'Resorts', 'id': 'resorts'},
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Floating pill search bar
        Container(
          height: 52,
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: isDark ? AppTheme.darkBorder : const Color(0xFFE2E8F0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              IconButton(
                icon: Icon(Symbols.arrow_back, size: 20, color: isDark ? Colors.white : const Color(0xFF0F172A)),
                onPressed: widget.onBackTap ?? () => Navigator.of(context).maybePop(),
              ),
              Expanded(
                child: TextField(
                  controller: _textController,
                  onChanged: (val) {
                    searchCtrl.onQueryChanged(val);
                  },
                  onSubmitted: widget.onSearchSubmitted,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search Bangladesh corridors, ghats...',
                    hintStyle: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
              if (_textController.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Symbols.close, size: 18, color: Colors.grey),
                  onPressed: () {
                    _textController.clear();
                    searchCtrl.clear();
                  },
                ),
              Container(width: 1, height: 20, color: isDark ? Colors.white24 : const Color(0xFFCBD5E1)),
              IconButton(
                icon: const Icon(Symbols.mic, size: 20, color: AppTheme.primaryGreen),
                tooltip: 'Voice Search',
                onPressed: () {},
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Horizontal Category Chips Row
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final cat = categories[index];
              final isSelected = searchCtrl.selectedCategory == cat['id'] || (searchCtrl.selectedCategory == 'all' && cat['id'] == 'scenic');

              return GestureDetector(
                onTap: () {
                  searchCtrl.selectCategory(cat['id']!);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFE6F7F0)
                        : (isDark ? AppTheme.darkCard : Colors.white),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.primaryGreen
                          : (isDark ? AppTheme.darkBorder : const Color(0xFFE2E8F0)),
                      width: isSelected ? 2.0 : 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(cat['emoji']!, style: const TextStyle(fontSize: 14)),
                      const SizedBox(width: 6),
                      Text(
                        cat['label']!,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                          color: isSelected ? AppTheme.primaryGreen : (isDark ? Colors.white70 : const Color(0xFF1E293B)),
                        ),
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 6),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppTheme.primaryGreen,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
