import 'package:flutter/material.dart';
import 'package:way_point/pages/setting_screen.dart';

class WayPointApp extends StatelessWidget {
  const WayPointApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      home: SettingScreen(),
    );
  }
}
