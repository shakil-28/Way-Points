import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../controllers/settings_controller.dart';
import '../models/settings_model.dart';

class SettingsScreen extends StatelessWidget {
  final SettingsController? controller;

  const SettingsScreen({
    super.key,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final settingsCtrl =
        controller ?? context.watch<SettingsController>();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Navigation Preferences'),
      ),
      body: AnimatedBuilder(
        animation: settingsCtrl,
        builder: (context, _) {
          final s = settingsCtrl.settings;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // -----------------------------------------------------------
              // DISPLAY & ATMOSPHERE
              // -----------------------------------------------------------
              _buildSectionHeader(
                'DISPLAY & ATMOSPHERE',
                isDark,
              ),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      RadioListTile<ThemePreference>(
                        title: const Text(
                          'Obsidian Dark Mode (OLED Safe)',
                        ),
                        subtitle: const Text(
                          'Optimized for night highway driving',
                        ),
                        value: ThemePreference.dark,
                        groupValue: s.themePreference,
                        activeColor: AppTheme.accentNeon,
                        onChanged: (value) {
                          if (value != null) {
                            settingsCtrl.setTheme(value);
                          }
                        },
                      ),

                      RadioListTile<ThemePreference>(
                        title: const Text(
                          'Bengal Day Light Mode',
                        ),
                        subtitle: const Text(
                          'High-contrast daytime visibility',
                        ),
                        value: ThemePreference.light,
                        groupValue: s.themePreference,
                        activeColor: AppTheme.accentNeon,
                        onChanged: (value) {
                          if (value != null) {
                            settingsCtrl.setTheme(value);
                          }
                        },
                      ),

                      RadioListTile<ThemePreference>(
                        title: const Text(
                          'System Automatic',
                        ),
                        subtitle: const Text(
                          'Matches OS appearance schedule',
                        ),
                        value: ThemePreference.system,
                        groupValue: s.themePreference,
                        activeColor: AppTheme.accentNeon,
                        onChanged: (value) {
                          if (value != null) {
                            settingsCtrl.setTheme(value);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // -----------------------------------------------------------
              // CORRIDOR ROUTING RULES
              // -----------------------------------------------------------
              _buildSectionHeader(
                'CORRIDOR ROUTING RULES',
                isDark,
              ),

              Card(
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text(
                        'Prioritize Scenic Corridors',
                      ),
                      subtitle: const Text(
                        'Favor riverine vistas, tea gardens, and ghats',
                      ),
                      value: s.autoRerouteScenic,
                      activeColor: AppTheme.accentNeon,
                      onChanged: (value) {
                        settingsCtrl.setAutoRerouteScenic(value);
                      },
                    ),

                    const Divider(height: 1),

                    SwitchListTile(
                      title: const Text(
                        'Avoid Toll Bridges & Plazas',
                      ),
                      subtitle: const Text(
                        'Bypass Padma & Bangabandhu toll gates when possible',
                      ),
                      value: s.avoidTolls,
                      activeColor: AppTheme.accentNeon,
                      onChanged: (value) {
                        settingsCtrl.setAvoidTolls(value);
                      },
                    ),

                    const Divider(height: 1),

                    SwitchListTile(
                      title: const Text(
                        'Avoid Ferries',
                      ),
                      subtitle: const Text(
                        'Prefer road connections instead of ferry crossings',
                      ),
                      value: s.avoidFerries,
                      activeColor: AppTheme.accentNeon,
                      onChanged: (value) {
                        settingsCtrl.setAvoidFerries(value);
                      },
                    ),

                    const Divider(height: 1),

                    SwitchListTile(
                      title: const Text(
                        'Live Bengali Voice Guidance',
                      ),
                      subtitle: const Text(
                        'Bilingual Bangla & English acoustic maneuvers',
                      ),
                      value: s.voicePromptsEnabled,
                      activeColor: AppTheme.accentNeon,
                      onChanged: (value) {
                        settingsCtrl.setVoicePrompts(value);
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // -----------------------------------------------------------
              // SPEED & CALIBRATION
              // -----------------------------------------------------------
              _buildSectionHeader(
                'SPEED & CALIBRATION',
                isDark,
              ),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Speed Alert Threshold',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '${s.speedAlertThresholdKmh.toStringAsFixed(0)} km/h',
                            style: TextStyle(
                              color: AppTheme.accentNeon,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      Slider(
                        value: s.speedAlertThresholdKmh.clamp(
                          30.0,
                          160.0,
                        ),
                        min: 30.0,
                        max: 160.0,
                        divisions: 13,
                        activeColor: AppTheme.accentNeon,
                        inactiveColor: isDark
                            ? Colors.white24
                            : Colors.black12,
                        label:
                        '${s.speedAlertThresholdKmh.toStringAsFixed(0)} km/h',
                        onChanged: (value) {
                          settingsCtrl.setSpeedAlertThreshold(value);
                        },
                      ),

                      const SizedBox(height: 4),

                      Text(
                        'You will receive a speed alert when your simulated or live speed exceeds this value.',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? Colors.white54
                              : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // -----------------------------------------------------------
              // VEHICLE & OFFLINE SETTINGS
              // -----------------------------------------------------------
              _buildSectionHeader(
                'VEHICLE & OFFLINE',
                isDark,
              ),

              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(
                        Symbols.local_gas_station,
                      ),
                      title: const Text(
                        'Preferred Fuel Type',
                      ),
                      subtitle: Text(
                        s.preferredFuelType,
                      ),
                      trailing: DropdownButton<String>(
                        value: s.preferredFuelType,
                        underline: const SizedBox.shrink(),
                        items: const [
                          DropdownMenuItem(
                            value: 'Octane',
                            child: Text('Octane'),
                          ),
                          DropdownMenuItem(
                            value: 'CNG',
                            child: Text('CNG'),
                          ),
                          DropdownMenuItem(
                            value: 'Diesel',
                            child: Text('Diesel'),
                          ),
                          DropdownMenuItem(
                            value: 'Electric',
                            child: Text('Electric'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            settingsCtrl.setPreferredFuel(value);
                          }
                        },
                      ),
                    ),

                    const Divider(height: 1),

                    SwitchListTile(
                      title: const Text(
                        'Offline Map Cache',
                      ),
                      subtitle: const Text(
                        'Keep essential corridor data available offline',
                      ),
                      value: s.offlineCacheEnabled,
                      activeColor: AppTheme.accentNeon,
                      onChanged: (value) {
                        settingsCtrl.setOfflineCache(value);
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // -----------------------------------------------------------
              // RESTORE DEFAULTS
              // -----------------------------------------------------------
              Center(
                child: TextButton.icon(
                  icon: const Icon(
                    Symbols.restart_alt,
                    size: 18,
                  ),
                  label: const Text(
                    'Restore Default Settings',
                  ),
                  onPressed: () {
                    settingsCtrl.resetDefaults();
                  },
                ),
              ),

              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(
      String title,
      bool isDark,
      ) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 8.0,
        bottom: 8.0,
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.1,
          color: isDark
              ? Colors.white38
              : Colors.black45,
        ),
      ),
    );
  }
}