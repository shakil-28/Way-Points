import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../theme/app_theme.dart';
import 'circular_floating_button.dart';

class ContextHeader extends StatelessWidget {
  final String title;
  final bool isDark;
  final VoidCallback onBack;
  final VoidCallback onProfile;

  const ContextHeader({
    super.key,
    required this.title,
    required this.isDark,
    required this.onBack,
    required this.onProfile,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: Row(
        children: <Widget>[
          CircularFloatingButton(
            icon: Symbols.arrow_back,
            onTap: onBack,
            isDark: isDark,
            size: 44,
            iconSize: 21,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Flexible(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppTheme.textPrimary,
                        letterSpacing: -0.2,
                        shadows: <Shadow>[
                          Shadow(
                            color: (isDark ? Colors.black : Colors.white)
                                .withValues(alpha: 0.95),
                            blurRadius: 10,
                            offset: const Offset(0, 1),
                          ),
                          Shadow(
                            color: Colors.black.withValues(
                                alpha: isDark ? 0.70 : 0.22),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 4),
          CircularFloatingButton(
            icon: Symbols.person,
            onTap: onProfile,
            isDark: isDark,
            size: 44,
            iconSize: 21,
            isProfile: true,
          ),
        ],
      ),
    );
  }
}
