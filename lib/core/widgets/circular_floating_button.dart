import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Single source of truth for all circular floating action buttons in the app
class CircularFloatingButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isDark;
  final double size;
  final double iconSize;
  final Color? iconColor;
  final Color? backgroundColor;
  final Color? borderColor;
  final bool showActiveDot;
  final bool isProfile;
  final String? tooltip;

  const CircularFloatingButton({
    super.key,
    required this.icon,
    required this.onTap,
    required this.isDark,
    this.size = 48,
    this.iconSize = 22,
    this.iconColor,
    this.backgroundColor,
    this.borderColor,
    this.showActiveDot = false,
    this.isProfile = false,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final defaultBgColor = isProfile
        ? (isDark ? const Color(0xFF334155) : AppTheme.lightBorder)
        : (isDark ? AppTheme.darkCard : Colors.white);

    final defaultBorderColor = isProfile
        ? (isDark ? AppTheme.darkBorder : Colors.white)
        : (isDark ? AppTheme.darkBorder : AppTheme.lightBorder);

    final defaultIconColor = iconColor ??
        (isProfile
            ? (isDark ? Colors.white70 : AppTheme.textSecondary)
            : (isDark ? Colors.white70 : const Color(0xFF1E293B)));

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? defaultBgColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor ?? defaultBorderColor,
          width: isProfile ? 2.0 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.12),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          IconButton(
            icon: Icon(icon, size: iconSize, color: defaultIconColor),
            onPressed: onTap,
            tooltip: tooltip,
            padding: EdgeInsets.zero,
          ),
          if (showActiveDot)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
