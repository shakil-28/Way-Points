import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/config/app_routes.dart';
import '../features/auth/views/login_screen.dart';
import '../features/auth/views/signup_screen.dart';
import '../features/auth/views/profile_setup_screen.dart';
import '../features/discovery/controllers/discovery_controller.dart';
import '../features/discovery/views/poi_details_screen.dart';
import '../features/location/views/location_permission_view.dart';
import '../features/navigation/views/navigation_screen.dart';
import '../features/routing/views/route_preview_screen.dart';
import '../features/main/views/main_screen.dart';

/// Central GoRouter configuration leveraging StatefulShellRoute for Bottom Navigation Capsule
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.login,
    routes: [
      // Auth Flow Routes
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.signUp,
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: AppRoutes.profileSetup,
        builder: (context, state) => const ProfileSetupScreen(),
      ),

      // Main Shell with IndexedStack + Floating Bottom Nav
      GoRoute(
        path: AppRoutes.map,
        builder: (context, state) => const MainScreen(),
      ),

      // Fullscreen Push Routes over the Shell
      GoRoute(
        path: AppRoutes.routePreview,
        builder: (context, state) => RoutePreviewScreen(
          onStartNavigation: () {
            context.push(AppRoutes.navigation);
          },
        ),
      ),

      GoRoute(
        path: AppRoutes.navigation,
        builder: (context, state) => ActiveNavigationScreen(),
      ),

      GoRoute(
        path: AppRoutes.poiDetails,
        builder: (context, state) {
          final discoveryController = context.read<DiscoveryController>();
          return PoiDetailsScreen(
            poi: discoveryController.activePoi,
            onAddStop: () {
              context.push(AppRoutes.routePreview);
            },
          );
        },
      ),

      GoRoute(
        path: AppRoutes.locationPermission,
        builder: (context, state) => LocationPermissionView(
          onGranted: () => context.go(AppRoutes.map),
        ),
      ),
    ],
  );
}
