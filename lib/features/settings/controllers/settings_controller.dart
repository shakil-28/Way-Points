import 'package:flutter/foundation.dart';
import '../../../core/services/shared_preferences_service.dart';
import '../models/settings_model.dart';

/// App preferences and telemetry calibration controller with disk persistence
class SettingsController extends ChangeNotifier {
  SettingsModel _settings = const SettingsModel();

  SettingsModel get settings => _settings;

  SettingsController() {
    loadSavedSettings();
  }

  Future<void> loadSavedSettings() async {
    _settings = await SharedPreferencesService.loadSettings();
    notifyListeners();
  }

  void setTheme(ThemePreference theme) {
    _settings = _settings.copyWith(
      themePreference: theme,
    );
    notifyListeners();
    SharedPreferencesService.saveSettings(_settings);
  }

  void setSpeedUnit(SpeedUnit unit) {
    _settings = _settings.copyWith(
      speedUnit: unit,
    );
    notifyListeners();
    SharedPreferencesService.saveSettings(_settings);
  }

  void setAvoidTolls(bool value) {
    _settings = _settings.copyWith(
      avoidTolls: value,
    );
    notifyListeners();
    SharedPreferencesService.saveSettings(_settings);
  }

  void setAvoidFerries(bool value) {
    _settings = _settings.copyWith(
      avoidFerries: value,
    );
    notifyListeners();
    SharedPreferencesService.saveSettings(_settings);
  }

  void setAvoidHighways(bool value) {
    _settings = _settings.copyWith(
      avoidHighways: value,
    );
    notifyListeners();
    SharedPreferencesService.saveSettings(_settings);
  }

  void setAutoRerouteScenic(bool value) {
    _settings = _settings.copyWith(
      autoRerouteScenic: value,
    );
    notifyListeners();
    SharedPreferencesService.saveSettings(_settings);
  }

  void setVoicePrompts(bool value) {
    _settings = _settings.copyWith(
      voicePromptsEnabled: value,
    );
    notifyListeners();
    SharedPreferencesService.saveSettings(_settings);
  }

  void setSpeedLimitWarnings(bool value) {
    _settings = _settings.copyWith(
      speedLimitWarnings: value,
    );
    notifyListeners();
    SharedPreferencesService.saveSettings(_settings);
  }

  void setVoiceLanguage(String language) {
    _settings = _settings.copyWith(
      voiceLanguage: language,
    );
    notifyListeners();
    SharedPreferencesService.saveSettings(_settings);
  }

  void setPreferredFuel(String fuel) {
    _settings = _settings.copyWith(
      preferredFuelType: fuel,
    );
    notifyListeners();
    SharedPreferencesService.saveSettings(_settings);
  }

  void setSpeedAlertThreshold(double speed) {
    _settings = _settings.copyWith(
      speedAlertThresholdKmh: speed,
    );
    notifyListeners();
    SharedPreferencesService.saveSettings(_settings);
  }

  void setOfflineCache(bool value) {
    _settings = _settings.copyWith(
      offlineCacheEnabled: value,
    );
    notifyListeners();
    SharedPreferencesService.saveSettings(_settings);
  }

  void resetDefaults() {
    _settings = const SettingsModel();
    notifyListeners();
    SharedPreferencesService.clearSettings();
  }
}
