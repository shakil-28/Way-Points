import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../map/views/map_screen.dart';
import '../../search/views/search_screen.dart';
import '../../history/views/history_screen.dart';
import '../../settings/views/settings_screen.dart';

/// Main shell with IndexedStack tab architecture + custom bottom nav bar.
///
/// Tab order: Explore (map) | Search | History | Settings
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 1; // Search is active by default in this design

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          const MapScreen(),
          SearchScreen(onPlaceSelected: (_) {}),
          const HistoryScreen(),
          const SettingsScreen(),
        ],
      ),
      bottomNavigationBar: WayPointBottomNavBar(
        currentIndex: _currentIndex,
        isDark: Theme.of(context).brightness == Brightness.dark,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}

/// Pill-shaped floating bottom navigation bar with backdrop blur and animated dot indicator.
class WayPointBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool isDark;

  const WayPointBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.only(
        left: 24,
        right: 24,
        bottom: 24,
      ),
      child: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 448,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 16,
                sigmaY: 16,
              ),
              child: Container(
                height: 64,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1C1B1E).withValues(alpha: 0.95)
                      : Colors.white.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF363436)
                        : const Color(0xFFE2E8F0),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.10),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _NavItem(
                      icon: Symbols.explore,
                      label: 'Explore',
                      isSelected: currentIndex == 0,
                      isDark: isDark,
                      onTap: () => onTap(0),
                    ),
                    _NavItem(
                      icon: Symbols.search,
                      label: 'Search',
                      isSelected: currentIndex == 1,
                      isDark: isDark,
                      onTap: () => onTap(1),
                    ),
                    _NavItem(
                      icon: Symbols.history,
                      label: 'History',
                      isSelected: currentIndex == 2,
                      isDark: isDark,
                      onTap: () => onTap(2),
                    ),
                    _NavItem(
                      icon: Symbols.settings,
                      label: 'Settings',
                      isSelected: currentIndex == 3,
                      isDark: isDark,
                      onTap: () => onTap(3),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });
  static const Color _activeColor = Color(0xFF025939);
  static const Color _inactiveColor = Color(0xFF64748B);
  static const Color _darkInactiveColor = Color(0xFF94A3B8);


  @override
  Widget build(BuildContext context) {
    final color = isSelected
        ? _activeColor
        : (isDark ? _darkInactiveColor : _inactiveColor);

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: SizedBox(
            height: 56,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: color,
                  fill: isSelected ? 1 : 0,
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  maxLines: 1,
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    height: 1.2,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 2),
                AnimatedScale(
                  scale: isSelected ? 1 : 0.5,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  child: AnimatedOpacity(
                    opacity: isSelected ? 1 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: _activeColor,
                        shape: BoxShape.circle,
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: _activeColor.withValues(alpha: isDark ? 0.4 : 0.20),
                                  blurRadius: 3,
                                ),
                              ]
                            : null,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
