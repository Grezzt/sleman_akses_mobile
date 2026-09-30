import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:sleman_akses_mobile/features/home/data/models/navigation_step.dart';

void main() {
  group('NavigationStep Parser Tests', () {
    test('should parse right turn maneuver correctly', () {
      final json = {
        'maneuver': {
          'type': 'turn',
          'modifier': 'right',
          'location': [110.3695, -7.7956],
        },
        'name': 'Jl. Magelang',
        'distance': 150.0,
      };

      final step = NavigationStep.fromOsrmStep(json);

      expect(step.maneuverType, 'turn');
      expect(step.modifier, 'right');
      expect(step.roadName, 'Jl. Magelang');
      expect(step.instruction, contains('Belok kanan ke Jl. Magelang'));
      expect(step.icon, Icons.turn_right);
      expect(step.location.latitude, -7.7956);
      expect(step.location.longitude, 110.3695);
      expect(step.distanceMeters, 150.0);
    });

    test('should parse left turn maneuver correctly', () {
      final json = {
        'maneuver': {
          'type': 'turn',
          'modifier': 'left',
          'location': [110.3700, -7.7960],
        },
        'name': 'Jl. Kaliurang',
        'distance': 320.0,
      };

      final step = NavigationStep.fromOsrmStep(json);

      expect(step.maneuverType, 'turn');
      expect(step.instruction, contains('Belok kiri ke Jl. Kaliurang'));
      expect(step.icon, Icons.turn_left);
    });

    test('should parse uturn maneuver correctly', () {
      final json = {
        'maneuver': {
          'type': 'turn',
          'modifier': 'uturn',
          'location': [110.3700, -7.7960],
        },
        'name': 'Ring Road Utara',
        'distance': 80.0,
      };

      final step = NavigationStep.fromOsrmStep(json);

      expect(step.instruction, contains('Putar balik di Ring Road Utara'));
      expect(step.icon, Icons.u_turn_left);
    });

    test('should parse arrive maneuver correctly', () {
      final json = {
        'maneuver': {
          'type': 'arrive',
          'modifier': '',
          'location': [110.3710, -7.7970],
        },
        'name': 'Masjid Agung Sleman',
        'distance': 0.0,
      };

      final step = NavigationStep.fromOsrmStep(json);

      expect(step.instruction, contains('Tujuan ada di Masjid Agung Sleman'));
      expect(step.icon, Icons.location_on);
    });
  });

  group('RouteData Metrik Formatting Tests', () {
    test('should format distance under 1000m in meters', () {
      const route = RouteData(
        points: [LatLng(-7.7, 110.3)],
        totalDistanceMeters: 650.0,
        totalDurationSeconds: 120.0,
        steps: [],
        placeName: 'Taman Denggung',
      );

      expect(route.formattedDistance, '650 m');
      expect(route.formattedDuration, '2 mnt');
    });

    test('should format distance over 1000m in kilometers', () {
      const route = RouteData(
        points: [LatLng(-7.7, 110.3)],
        totalDistanceMeters: 4250.0,
        totalDurationSeconds: 600.0,
        steps: [],
        placeName: 'Kantor Bupati Sleman',
      );

      expect(route.formattedDistance, '4.3 km');
      expect(route.formattedDuration, '10 mnt');
    });
  });
}
