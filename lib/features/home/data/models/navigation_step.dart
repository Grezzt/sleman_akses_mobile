import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class NavigationStep {
  final String maneuverType;
  final String modifier;
  final String instruction;
  final String roadName;
  final LatLng location;
  final IconData icon;
  final double distanceMeters;

  const NavigationStep({
    required this.maneuverType,
    required this.modifier,
    required this.instruction,
    required this.roadName,
    required this.location,
    required this.icon,
    required this.distanceMeters,
  });

  factory NavigationStep.fromOsrmStep(Map<String, dynamic> json) {
    final maneuver = json['maneuver'] as Map<String, dynamic>? ?? {};
    final type = (maneuver['type'] as String? ?? '').toLowerCase();
    final modifier = (maneuver['modifier'] as String? ?? '').toLowerCase();
    final roadName = (json['name'] as String? ?? '').trim();
    final road = roadName.isNotEmpty ? roadName : 'jalan berikutnya';
    final distanceMeters = (json['distance'] as num?)?.toDouble() ?? 0.0;

    final locCoords = maneuver['location'] as List<dynamic>?;
    final latLng = (locCoords != null && locCoords.length >= 2)
        ? LatLng(
            (locCoords[1] as num).toDouble(),
            (locCoords[0] as num).toDouble(),
          )
        : const LatLng(0, 0);

    IconData icon = Icons.straight;
    String action = 'Lurus terus ke';

    if (type == 'turn') {
      if (modifier.contains('right')) {
        if (modifier.contains('sharp')) {
          icon = Icons.turn_sharp_right;
          action = 'Belok tajam ke kanan menuju';
        } else if (modifier.contains('slight')) {
          icon = Icons.turn_slight_right;
          action = 'Sedikit ke kanan ke';
        } else {
          icon = Icons.turn_right;
          action = 'Belok kanan ke';
        }
      } else if (modifier.contains('left')) {
        if (modifier.contains('sharp')) {
          icon = Icons.turn_sharp_left;
          action = 'Belok tajam ke kiri menuju';
        } else if (modifier.contains('slight')) {
          icon = Icons.turn_slight_left;
          action = 'Sedikit ke kiri ke';
        } else {
          icon = Icons.turn_left;
          action = 'Belok kiri ke';
        }
      } else if (modifier.contains('uturn')) {
        icon = Icons.u_turn_left;
        action = 'Putar balik di';
      } else if (modifier.contains('straight')) {
        icon = Icons.straight;
        action = 'Lurus terus ke';
      }
    } else if (type == 'new name' || type == 'continue') {
      if (modifier.contains('right')) {
        icon = Icons.turn_right;
        action = 'Ambil kanan ke';
      } else if (modifier.contains('left')) {
        icon = Icons.turn_left;
        action = 'Ambil kiri ke';
      } else {
        icon = Icons.straight;
        action = 'Lanjut lurus ke';
      }
    } else if (type == 'depart') {
      icon = Icons.navigation;
      action = 'Mulai melaju ke arah';
    } else if (type == 'arrive') {
      icon = Icons.location_on;
      action = 'Tujuan ada di';
    } else if (type == 'roundabout' || type == 'rotary') {
      icon = Icons.roundabout_right;
      action = 'Masuk bundaran ke';
    } else if (type == 'fork') {
      if (modifier.contains('right')) {
        icon = Icons.turn_slight_right;
        action = 'Ambil percabangan kanan ke';
      } else if (modifier.contains('left')) {
        icon = Icons.turn_slight_left;
        action = 'Ambil percabangan kiri ke';
      } else {
        icon = Icons.straight;
        action = 'Ambil jalur tengah ke';
      }
    } else if (type == 'end of road') {
      if (modifier.contains('right')) {
        icon = Icons.turn_right;
        action = 'Ujung jalan, belok kanan ke';
      } else if (modifier.contains('left')) {
        icon = Icons.turn_left;
        action = 'Ujung jalan, belok kiri ke';
      } else {
        icon = Icons.straight;
        action = 'Ujung jalan ke';
      }
    } else if (type.contains('ramp')) {
      if (modifier.contains('right')) {
        icon = Icons.turn_slight_right;
        action = 'Masuk lajur kanan ke';
      } else if (modifier.contains('left')) {
        icon = Icons.turn_slight_left;
        action = 'Masuk lajur kiri ke';
      } else {
        icon = Icons.straight;
        action = 'Masuk lajur ke';
      }
    } else {
      if (modifier.contains('right')) {
        icon = Icons.turn_right;
        action = 'Ke arah kanan menuju';
      } else if (modifier.contains('left')) {
        icon = Icons.turn_left;
        action = 'Ke arah kiri menuju';
      } else {
        icon = Icons.straight;
        action = 'Lurus terus ke';
      }
    }

    return NavigationStep(
      maneuverType: type,
      modifier: modifier,
      instruction: '$action $road',
      roadName: road,
      location: latLng,
      icon: icon,
      distanceMeters: distanceMeters,
    );
  }
}

class RouteData {
  final List<LatLng> points;
  final double totalDistanceMeters;
  final double totalDurationSeconds;
  final List<NavigationStep> steps;
  final String placeName;

  const RouteData({
    required this.points,
    required this.totalDistanceMeters,
    required this.totalDurationSeconds,
    required this.steps,
    required this.placeName,
  });

  String get formattedDistance {
    if (totalDistanceMeters < 1000) {
      return '${totalDistanceMeters.round()} m';
    }
    return '${(totalDistanceMeters / 1000).toStringAsFixed(1)} km';
  }

  String get formattedDuration {
    final minutes = (totalDurationSeconds / 60).round();
    if (minutes <= 1) {
      return '1 mnt';
    }
    return '$minutes mnt';
  }
}
