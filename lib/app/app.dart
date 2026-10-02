import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/config/app_config.dart';
import '../core/theme/app_theme.dart';
import '../features/discovery/controllers/discovery_controller.dart';
import '../features/history/controllers/history_controller.dart';
import '../features/location/controllers/location_controller.dart';
import '../features/map/controllers/map_controller.dart';
import '../features/navigation/controllers/navigation_controller.dart';
import '../features/routing/controllers/routing_controller.dart';
import '../features/search/controllers/place_search_controller.dart'; // from here
import '../features/settings/controllers/settings_controller.dart';
import '../features/settings/models/settings_model.dart';
import '../routes/app_router.dart';

/// MaterialApp Root component managing top-level Provider DI and theme switches
class WaypointApp extends StatelessWidget {
  const WaypointApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocationController()),
        ChangeNotifierProvider(create: (_) => MapController()),
        ChangeNotifierProvider(create: (_) => PlaceSearchController()),
        ChangeNotifierProvider(create: (_) => RoutingController()),
        ChangeNotifierProvider(create: (_) => NavigationController()),
        ChangeNotifierProvider(create: (_) => DiscoveryController()),
        ChangeNotifierProvider(create: (_) => HistoryController()),
        ChangeNotifierProvider(create: (_) => SettingsController()),
      ],
      child: Consumer<SettingsController>(
        builder: (context, settingsController, _) {
          final themePref = settingsController.settings.themePreference;

          ThemeMode mode;
          switch (themePref) {
            case ThemePreference.light:
              mode = ThemeMode.light;
              break;
            case ThemePreference.dark:
              mode = ThemeMode.dark;
              break;
            case ThemePreference.system:
              mode = ThemeMode.system;
              break;
          }

          return MaterialApp.router(
            title: AppConfig.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: mode,
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}
