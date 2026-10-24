import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/settings/models/settings_model.dart';

/// Disk Storage Service for persisting driver application preferences
class SharedPreferencesService {
  static const String _keyThemePreference = 'key_theme_preference';
  static const String _keySpeedUnit = 'key_speed_unit';
  static const String _keyVoiceLanguage = 'key_voice_language';
  static const String _keyPreferredFuelType = 'key_preferred_fuel_type';
  static const String _keyAvoidTolls = 'key_avoid_tolls';
  static const String _keyAvoidFerries = 'key_avoid_ferries';
  static const String _keyAvoidHighways = 'key_avoid_highways';
  static const String _keyVoicePromptsEnabled = 'key_voice_prompts_enabled';
  static const String _keySpeedLimitWarnings = 'key_speed_limit_warnings';
  static const String _keySpeedAlertThresholdKmh = 'key_speed_alert_threshold_kmh';
  static const String _keyAutoRerouteScenic = 'key_auto_reroute_scenic';
  static const String _keyOfflineCacheEnabled = 'key_offline_cache_enabled';

  /// Load saved SettingsModel from disk
  static Future<SettingsModel> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final themeName = prefs.getString(_keyThemePreference) ?? ThemePreference.system.name;
      final speedUnitName = prefs.getString(_keySpeedUnit) ?? SpeedUnit.kmh.name;

      final theme = ThemePreference.values.firstWhere(
        (e) => e.name == themeName,
        orElse: () => ThemePreference.system,
      );

      final speedUnit = SpeedUnit.values.firstWhere(
        (e) => e.name == speedUnitName,
        orElse: () => SpeedUnit.kmh,
      );

      return SettingsModel(
        themePreference: theme,
        speedUnit: speedUnit,
        voiceLanguage: prefs.getString(_keyVoiceLanguage) ?? 'Bengali (BD - Farhana)',
        preferredFuelType: prefs.getString(_keyPreferredFuelType) ?? 'Octane 95',
        avoidTolls: prefs.getBool(_keyAvoidTolls) ?? false,
        avoidFerries: prefs.getBool(_keyAvoidFerries) ?? false,
        avoidHighways: prefs.getBool(_keyAvoidHighways) ?? false,
        voicePromptsEnabled: prefs.getBool(_keyVoicePromptsEnabled) ?? true,
        speedLimitWarnings: prefs.getBool(_keySpeedLimitWarnings) ?? true,
        speedAlertThresholdKmh: prefs.getDouble(_keySpeedAlertThresholdKmh) ?? 80.0,
        autoRerouteScenic: prefs.getBool(_keyAutoRerouteScenic) ?? true,
        offlineCacheEnabled: prefs.getBool(_keyOfflineCacheEnabled) ?? true,
      );
    } catch (e) {
      debugPrint('Error loading saved settings from disk: $e');
      return const SettingsModel();
    }
  }

  /// Save full SettingsModel to disk
  static Future<void> saveSettings(SettingsModel settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyThemePreference, settings.themePreference.name);
      await prefs.setString(_keySpeedUnit, settings.speedUnit.name);
      await prefs.setString(_keyVoiceLanguage, settings.voiceLanguage);
      await prefs.setString(_keyPreferredFuelType, settings.preferredFuelType);
      await prefs.setBool(_keyAvoidTolls, settings.avoidTolls);
      await prefs.setBool(_keyAvoidFerries, settings.avoidFerries);
      await prefs.setBool(_keyAvoidHighways, settings.avoidHighways);
      await prefs.setBool(_keyVoicePromptsEnabled, settings.voicePromptsEnabled);
      await prefs.setBool(_keySpeedLimitWarnings, settings.speedLimitWarnings);
      await prefs.setDouble(_keySpeedAlertThresholdKmh, settings.speedAlertThresholdKmh);
      await prefs.setBool(_keyAutoRerouteScenic, settings.autoRerouteScenic);
      await prefs.setBool(_keyOfflineCacheEnabled, settings.offlineCacheEnabled);
    } catch (e) {
      debugPrint('Error saving settings to disk: $e');
    }
  }

  /// Clear all saved settings on disk
  static Future<void> clearSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyThemePreference);
      await prefs.remove(_keySpeedUnit);
      await prefs.remove(_keyVoiceLanguage);
      await prefs.remove(_keyPreferredFuelType);
      await prefs.remove(_keyAvoidTolls);
      await prefs.remove(_keyAvoidFerries);
      await prefs.remove(_keyAvoidHighways);
      await prefs.remove(_keyVoicePromptsEnabled);
      await prefs.remove(_keySpeedLimitWarnings);
      await prefs.remove(_keySpeedAlertThresholdKmh);
      await prefs.remove(_keyAutoRerouteScenic);
      await prefs.remove(_keyOfflineCacheEnabled);
    } catch (e) {
      debugPrint('Error clearing settings on disk: $e');
    }
  }
}
