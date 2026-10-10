import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Navigation POI Callout Badge Overlay along Highway Corridors
class NavigationPoiBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final bool showPulse;
  final bool isDark;

  const NavigationPoiBadge({
    super.key,
    required this.icon,
    required this.label,
    required this.iconColor,
    this.showPulse = false,
    required this.isDark,
  });

  static const Color emerald = AppTheme.primaryGreen;
  static const Color borderColor = Color(0xFFE2E8F0);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: (isDark ? AppTheme.darkCard : Colors.white).withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: (isDark ? AppTheme.darkBorder : borderColor).withValues(alpha: 0.9),
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.10),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (showPulse) ...<Widget>[
              const DecoratedBox(
                decoration: BoxDecoration(
                  color: emerald,
                  shape: BoxShape.circle,
                ),
                child: SizedBox(width: 8, height: 8),
              ),
              const SizedBox(width: 6),
            ],
            Icon(icon, size: 18, color: iconColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
