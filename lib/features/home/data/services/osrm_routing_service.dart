import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../models/navigation_step.dart';

class OsrmRoutingService {
  final http.Client _client;

  OsrmRoutingService({http.Client? client}) : _client = client ?? http.Client();

  Future<RouteData> getRoute({
    required LatLng origin,
    required LatLng destination,
    required String placeName,
  }) async {
    final url = Uri.parse(
      'https://router.project-osrm.org/route/v1/driving/'
      '${origin.longitude},${origin.latitude};${destination.longitude},${destination.latitude}'
      '?overview=full&geometries=geojson&steps=true',
    );

    try {
      final response = await _client.get(url).timeout(
            const Duration(seconds: 10),
          );

      if (response.statusCode != 200) {
        throw Exception(
          'Gagal mengambil rute dari server navigasi (${response.statusCode})',
        );
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (data['code'] != 'Ok' ||
          data['routes'] == null ||
          (data['routes'] as List).isEmpty) {
        throw Exception('Rute navigasi tidak ditemukan');
      }

      final route = data['routes'][0] as Map<String, dynamic>;
      final geometry = route['geometry'] as Map<String, dynamic>? ?? {};
      final coordinates = geometry['coordinates'] as List<dynamic>? ?? [];

      final points = coordinates.map((coord) {
        final pair = coord as List<dynamic>;
        return LatLng(
          (pair[1] as num).toDouble(),
          (pair[0] as num).toDouble(),
        );
      }).toList();

      final totalDistance = (route['distance'] as num?)?.toDouble() ?? 0.0;
      final totalDuration = (route['duration'] as num?)?.toDouble() ?? 0.0;

      final legs = route['legs'] as List<dynamic>? ?? [];
      final stepsJson = (legs.isNotEmpty && legs[0]['steps'] != null)
          ? legs[0]['steps'] as List<dynamic>
          : <dynamic>[];

      final steps = stepsJson
          .map((s) => NavigationStep.fromOsrmStep(s as Map<String, dynamic>))
          .toList();

      return RouteData(
        points: points,
        totalDistanceMeters: totalDistance,
        totalDurationSeconds: totalDuration,
        steps: steps,
        placeName: placeName,
      );
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Kesalahan jaringan saat mengambil rute: $e');
    }
  }
}
