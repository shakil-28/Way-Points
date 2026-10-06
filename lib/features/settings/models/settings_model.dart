enum ThemePreference {
  system,
  light,
  dark,
}

enum SpeedUnit {
  kmh,
  mph,
}

enum AvoidRoadOption {
  tolls,
  ferries,
  unpavedRoads,
}

/// User navigation and display preferences
class SettingsModel {
  final ThemePreference themePreference;
  final SpeedUnit speedUnit;
  final bool avoidTolls;
  final bool avoidFerries;
  final bool avoidHighways;
  final bool autoRerouteScenic;
  final bool voicePromptsEnabled;
  final bool speedLimitWarnings;
  final String voiceLanguage;
  final double speedAlertThresholdKmh;
  final String preferredFuelType; // 'Octane', 'CNG', 'Diesel', 'Electric'
  final bool offlineCacheEnabled;

  const SettingsModel({
    this.themePreference = ThemePreference.dark,
    this.speedUnit = SpeedUnit.kmh,
    this.avoidTolls = false,
    this.avoidFerries = false,
    this.avoidHighways = false,
    this.autoRerouteScenic = true,
    this.voicePromptsEnabled = true,
    this.speedLimitWarnings = true,
    this.voiceLanguage = 'Bengali (BD - Farhana)',
    this.speedAlertThresholdKmh = 80.0,
    this.preferredFuelType = 'Octane',
    this.offlineCacheEnabled = true,
  });

  SettingsModel copyWith({
    ThemePreference? themePreference,
    SpeedUnit? speedUnit,
    bool? avoidTolls,
    bool? avoidFerries,
    bool? avoidHighways,
    bool? autoRerouteScenic,
    bool? voicePromptsEnabled,
    bool? speedLimitWarnings,
    String? voiceLanguage,
    double? speedAlertThresholdKmh,
    String? preferredFuelType,
    bool? offlineCacheEnabled,
  }) {
    return SettingsModel(
      themePreference: themePreference ?? this.themePreference,
      speedUnit: speedUnit ?? this.speedUnit,
      avoidTolls: avoidTolls ?? this.avoidTolls,
      avoidFerries: avoidFerries ?? this.avoidFerries,
      avoidHighways: avoidHighways ?? this.avoidHighways,
      autoRerouteScenic: autoRerouteScenic ?? this.autoRerouteScenic,
      voicePromptsEnabled: voicePromptsEnabled ?? this.voicePromptsEnabled,
      speedLimitWarnings: speedLimitWarnings ?? this.speedLimitWarnings,
      voiceLanguage: voiceLanguage ?? this.voiceLanguage,
      speedAlertThresholdKmh: speedAlertThresholdKmh ?? this.speedAlertThresholdKmh,
      preferredFuelType: preferredFuelType ?? this.preferredFuelType,
      offlineCacheEnabled: offlineCacheEnabled ?? this.offlineCacheEnabled,
    );
  }
}
