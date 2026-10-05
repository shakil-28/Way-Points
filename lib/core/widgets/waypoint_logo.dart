import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/theme/app_theme.dart';

/// Reusable WayPoint logo widget using the SVG asset.
/// Tints the logo to match the current theme's accent or primary green.
class WayPointLogo extends StatelessWidget {
  final double size;
  /// Pass [AppTheme.accentNeon] for neon green, or [AppTheme.primaryGreen] for deep emerald.
  final Color tintColor;
  final bool filledBg;

  const WayPointLogo({
    super.key,
    this.size = 32,
    this.tintColor = AppTheme.accentNeon,
    this.filledBg = false,
  });

  @override
  Widget build(BuildContext context) {
    if (filledBg) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppTheme.primaryGreen,
          shape: BoxShape.circle,
        ),
        child: SvgPicture.asset(
          'assets/logo.svg',
          width: size * 0.7,
          height: size * 0.7,
          colorFilter: ColorFilter.mode(
            tintColor,
            BlendMode.srcIn,
          ),
        ),
      );
    }
    return SvgPicture.asset(
      'assets/logo.svg',
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(
        tintColor,
        BlendMode.srcIn,
      ),
    );
  }
}
