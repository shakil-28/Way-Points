import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:way_point/features/settings/controllers/settings_controller.dart';
import 'package:way_point/features/settings/models/settings_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SettingsController Disk Persistence Unit Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Initial settings contain default factory values', () async {
      final controller = SettingsController();
      await controller.loadSavedSettings();

      expect(controller.settings.themePreference, equals(ThemePreference.system));
      expect(controller.settings.speedUnit, equals(SpeedUnit.kmh));
      expect(controller.settings.avoidTolls, isFalse);
    });

    test('setSpeedUnit updates state and persists setting', () async {
      final controller = SettingsController();
      controller.setSpeedUnit(SpeedUnit.mph);

      expect(controller.settings.speedUnit, equals(SpeedUnit.mph));

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('key_speed_unit'), equals('mph'));
    });

    test('setTheme updates theme preference and persists', () async {
      final controller = SettingsController();
      controller.setTheme(ThemePreference.dark);

      expect(controller.settings.themePreference, equals(ThemePreference.dark));

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('key_theme_preference'), equals('dark'));
    });

    test('resetDefaults clears saved settings', () async {
      final controller = SettingsController();
      controller.setSpeedUnit(SpeedUnit.mph);
      controller.resetDefaults();

      expect(controller.settings.speedUnit, equals(SpeedUnit.kmh));
    });
  });
}
