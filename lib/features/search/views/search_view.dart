import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../controllers/place_search_controller.dart';

/// Reusable search bar and filter chips component leveraging Provider
class SearchView extends StatelessWidget {
  final PlaceSearchController? controller;
  final ValueChanged<String>? onSearchSubmitted;
  final VoidCallback? onFilterTap;

  const SearchView({
    super.key,
    this.controller,
    this.onSearchSubmitted,
    this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    final searchCtrl = controller ?? context.watch<PlaceSearchController>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final categories = [
      {'id': 'all', 'label': 'All Corridors'},
      {'id': 'cultural', 'label': 'Mughal & Heritage'},
      {'id': 'scenic', 'label': 'River & Tea Gardens'},
      {'id': 'heritage', 'label': 'Archaeological'},
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Floating pill search bar
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              const Icon(Symbols.search, size: 20, color: AppTheme.accentNeon),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  onChanged: searchCtrl.onQueryChanged,
                  onSubmitted: onSearchSubmitted,
                  decoration: InputDecoration(
                    hintText: 'Search Bangladesh corridors, ghats, forts...',
                    hintStyle: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              if (searchCtrl.query.isNotEmpty)
                GestureDetector(
                  onTap: searchCtrl.clear,
                  child: const Icon(Symbols.close, size: 18, color: Colors.grey),
                ),
              if (onFilterTap != null)
                IconButton(
                  icon: const Icon(Symbols.tune, size: 20),
                  onPressed: onFilterTap,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // Filter chips row
        SizedBox(
          height: 32,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final cat = categories[index];
              final isSelected = searchCtrl.selectedCategory == cat['id'];
              return ChoiceChip(
                label: Text(
                  cat['label']!,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : (isDark ? Colors.white70 : Colors.black87),
                  ),
                ),
                selected: isSelected,
                selectedColor: AppTheme.primaryGreen,
                backgroundColor: isDark ? AppTheme.darkCard : AppTheme.lightCard,
                side: BorderSide(
                  color: isSelected
                      ? AppTheme.accentNeon
                      : (isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
                ),
                onSelected: (_) => searchCtrl.selectCategory(cat['id']!),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              );
            },
          ),
        ),
      ],
    );
  }
}
