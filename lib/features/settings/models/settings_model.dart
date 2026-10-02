enum ThemePreference {
  system,
  light,
  dark,
}

enum AvoidRoadOption {
  tolls,
  ferries,
  unpavedRoads,
}

/// User navigation and display preferences
class SettingsModel {
  final ThemePreference themePreference;
  final bool avoidTolls;
  final bool avoidFerries;
  final bool autoRerouteScenic;
  final bool voicePromptsEnabled;
  final double speedAlertThresholdKmh;
  final String preferredFuelType; // 'Octane', 'CNG', 'Diesel', 'Electric'
  final bool offlineCacheEnabled;

  const SettingsModel({
    this.themePreference = ThemePreference.dark,
    this.avoidTolls = false,
    this.avoidFerries = false,
    this.autoRerouteScenic = true,
    this.voicePromptsEnabled = true,
    this.speedAlertThresholdKmh = 80.0,
    this.preferredFuelType = 'Octane',
    this.offlineCacheEnabled = true,
  });

  SettingsModel copyWith({
    ThemePreference? themePreference,
    bool? avoidTolls,
    bool? avoidFerries,
    bool? autoRerouteScenic,
    bool? voicePromptsEnabled,
    double? speedAlertThresholdKmh,
    String? preferredFuelType,
    bool? offlineCacheEnabled,
  }) {
    return SettingsModel(
      themePreference: themePreference ?? this.themePreference,
      avoidTolls: avoidTolls ?? this.avoidTolls,
      avoidFerries: avoidFerries ?? this.avoidFerries,
      autoRerouteScenic: autoRerouteScenic ?? this.autoRerouteScenic,
      voicePromptsEnabled: voicePromptsEnabled ?? this.voicePromptsEnabled,
      speedAlertThresholdKmh: speedAlertThresholdKmh ?? this.speedAlertThresholdKmh,
      preferredFuelType: preferredFuelType ?? this.preferredFuelType,
      offlineCacheEnabled: offlineCacheEnabled ?? this.offlineCacheEnabled,
    );
  }
}
