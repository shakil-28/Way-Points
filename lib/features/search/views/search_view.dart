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
  TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize text from the controller (available after mount when Provider is ready)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final ctrl = widget.controller ?? context.read<PlaceSearchController>();
      _textController.text = ctrl.query.isEmpty ? 'Lalbagh Fort' : ctrl.query;
    });
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

        const SizedBox(height: 12)
      ],
    );
  }
}
