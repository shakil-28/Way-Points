import 'package:flutter/foundation.dart';
import '../models/settings_model.dart';

/// App preferences and telemetry calibration controller
class SettingsController extends ChangeNotifier {
  SettingsModel _settings = const SettingsModel();

  SettingsModel get settings => _settings;

  void setTheme(ThemePreference theme) {
    _settings = _settings.copyWith(
      themePreference: theme,
    );
    notifyListeners();
  }

  void setAvoidTolls(bool value) {
    _settings = _settings.copyWith(
      avoidTolls: value,
    );
    notifyListeners();
  }

  void setAvoidFerries(bool value) {
    _settings = _settings.copyWith(
      avoidFerries: value,
    );
    notifyListeners();
  }

  void setAutoRerouteScenic(bool value) {
    _settings = _settings.copyWith(
      autoRerouteScenic: value,
    );
    notifyListeners();
  }

  void setVoicePrompts(bool value) {
    _settings = _settings.copyWith(
      voicePromptsEnabled: value,
    );
    notifyListeners();
  }

  void setPreferredFuel(String fuel) {
    _settings = _settings.copyWith(
      preferredFuelType: fuel,
    );
    notifyListeners();
  }

  void setSpeedAlertThreshold(double speed) {
    _settings = _settings.copyWith(
      speedAlertThresholdKmh: speed,
    );
    notifyListeners();
  }

  void setOfflineCache(bool value) {
    _settings = _settings.copyWith(
      offlineCacheEnabled: value,
    );
    notifyListeners();
  }

  void resetDefaults() {
    _settings = const SettingsModel();
    notifyListeners();
  }
}