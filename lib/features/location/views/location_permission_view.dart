import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../controllers/location_controller.dart';

class LocationPermissionView extends StatelessWidget {
  final LocationController? locationController;
  final VoidCallback onGranted;

  const LocationPermissionView({
    super.key,
    this.locationController,
    required this.onGranted,
  });

  @override
  Widget build(BuildContext context) {
    final locCtrl = locationController ?? context.read<LocationController>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withOpacity(0.12),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.accentNeon.withOpacity(0.3), width: 2),
                ),
                child: const Icon(
                  Symbols.near_me,
                  color: AppTheme.accentNeon,
                  size: 40,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Enable Precise Navigation',
                style: theme.textTheme.displayLarge?.copyWith(fontSize: 22),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'WayPoint uses your live GPS signal to calibrate lane-level maneuvers across Bangladesh highway corridors and calculate scenic cultural detours.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? Colors.white70 : Colors.black87,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 36),
              ElevatedButton.icon(
                icon: const Icon(Symbols.gps_fixed, size: 20),
                label: const Text('Allow Location Access', style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 2,
                ),
                onPressed: () {
                  locCtrl.requestPermission();
                  onGranted();
                },
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: onGranted,
                child: Text(
                  'Continue with Simulated Telemetry',
                  style: TextStyle(
                    color: isDark ? Colors.white60 : Colors.black54,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
