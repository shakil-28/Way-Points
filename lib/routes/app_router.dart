import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/config/app_routes.dart';
import '../features/discovery/controllers/discovery_controller.dart';
import '../features/discovery/views/poi_details_screen.dart';
import '../features/history/views/history_screen.dart';
import '../features/location/views/location_permission_view.dart';
import '../features/map/controllers/map_controller.dart';
import '../features/map/views/map_screen.dart';
import '../features/navigation/views/navigation_screen.dart';
import '../features/routing/controllers/routing_controller.dart';
import '../features/routing/views/route_preview_view.dart';
import '../features/search/views/search_screen.dart';
import '../features/settings/views/settings_screen.dart';

/// Central GoRouter configuration leveraging Provider state management
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.map,
    routes: [
      // Interactive Map Route
      GoRoute(
        path: AppRoutes.map,
        builder: (context, state) => MapScreen(
          onSearchTap: () => context.push(AppRoutes.search),
          onNavigateTap: () => context.push(AppRoutes.routePreview),
          onLayersTap: () => context.push(AppRoutes.settings),
        ),
      ),

      // Place Search & Autocomplete Route
      GoRoute(
        path: AppRoutes.search,
        builder: (context, state) => SearchScreen(
          onPlaceSelected: (place) {
            context.read<MapController>().panTo(place.latitude, place.longitude, zoom: 15.0);
            context.push(AppRoutes.routePreview);
          },
        ),
      ),

      // Route Preview & Corridor Selection Route
      GoRoute(
        path: AppRoutes.routePreview,
        builder: (context, state) => Scaffold(
          appBar: AppBar(title: const Text('Corridor Preview')),
          body: Center(
            child: RoutePreviewView(
              onStartNavigation: () {
                context.push(AppRoutes.navigation);
              },
            ),
          ),
        ),
      ),

      // Live Turn-by-Turn Navigation Screen
      GoRoute(
        path: AppRoutes.navigation,
        builder: (context, state) => NavigationScreen(
          onExitNavigation: () => context.go(AppRoutes.map),
        ),
      ),

      // Waypoint Dossier Details Route
      GoRoute(
        path: AppRoutes.poiDetails,
        builder: (context, state) {
          final discoveryController = context.watch<DiscoveryController>();
          return PoiDetailsScreen(
            poi: discoveryController.activePoi,
            onAddStop: () {
              context.push(AppRoutes.routePreview);
            },
          );
        },
      ),

      // Navigation History Route
      GoRoute(
        path: AppRoutes.history,
        builder: (context, state) => HistoryScreen(
          onReplayTrip: (trip) {
            context.read<RoutingController>().selectRouteById('route_riverine_scenic');
            context.push(AppRoutes.routePreview);
          },
        ),
      ),

      // Settings & Preferences Route
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),

      // Location Permission View
      GoRoute(
        path: AppRoutes.locationPermission,
        builder: (context, state) => LocationPermissionView(
          onGranted: () => context.go(AppRoutes.map),
        ),
      ),
    ],
  );
}
