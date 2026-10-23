import 'package:flutter/material.dart';

/// Data model representing a crowdsourced highway hazard report along Bengal corridors
class HazardModel {
  final String id;
  final String title;
  final String type; // 'police', 'traffic', 'construction', 'accident'
  final IconData icon;
  final Color color;
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final String reportedBy;

  const HazardModel({
    required this.id,
    required this.title,
    required this.type,
    required this.icon,
    required this.color,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.reportedBy = 'WayPoint Driver',
  });
}
