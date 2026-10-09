import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../theme/app_theme.dart';

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
          _headerBtn(icon: Symbols.arrow_back, onTap: onBack, isDark: isDark),
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
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
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
          _headerBtn(
            icon: Symbols.person,
            onTap: onProfile,
            isDark: isDark,
            isProfile: true,
          ),
        ],
      ),
    );
  }

  static Widget _headerBtn({
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
    bool isProfile = false,
  }) {
    final bgColor = isProfile
        ? (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0))
        : (isDark ? AppTheme.darkCard : Colors.white);
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: bgColor,
        shape: CircleBorder(
          side: BorderSide(
            color: isProfile
                ? (isDark ? AppTheme.darkBorder : Colors.white)
                : (isDark ? AppTheme.darkBorder : const Color(0xFFE2E8F0)),
            width: isProfile ? 2 : 1,
          ),
        ),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 44,
            height: 44,
            child: Icon(
              icon,
              size: 21,
              color: isProfile
                  ? (isDark ? Colors.white70 : const Color(0xFF64748B))
                  : (isDark ? Colors.white : const Color(0xFF0F172A)),
            ),
          ),
        ),
      ),
    );
  }
}
