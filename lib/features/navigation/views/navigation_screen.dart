import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../map/controllers/map_controller.dart';
import '../controllers/navigation_controller.dart';
import 'navigation_overlay_view.dart';
import '../../map/views/map_view.dart';

class NavigationScreen extends StatefulWidget {
  final NavigationController? navigationController;
  final MapController? mapController;
  final VoidCallback onExitNavigation;

  const NavigationScreen({
    super.key,
    this.navigationController,
    this.mapController,
    required this.onExitNavigation,
  });

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final nav = widget.navigationController ?? context.read<NavigationController>();
      if (!nav.isNavigating) {
        nav.startNavigation();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final navCtrl = widget.navigationController ?? context.watch<NavigationController>();
    final mapCtrl = widget.mapController ?? context.watch<MapController>();

    return Scaffold(
      body: Stack(
        children: [
          // Background Vector Map
          Positioned.fill(
            child: MapView(controller: mapCtrl),
          ),

          // Top Navigation Overlay
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 0,
            right: 0,
            child: NavigationOverlayView(
              controller: navCtrl,
              onExit: () {
                navCtrl.stopNavigation();
                widget.onExitNavigation();
              },
            ),
          ),
        ],
      ),
    );
  }
}
