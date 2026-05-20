import 'map_facility.dart';

class MapLocation {
  const MapLocation({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.publishDate,
    required this.photoUrl,
    required this.reportedBy,
    required this.facilities,
  });

  final int id;
  final double latitude;
  final double longitude;
  final String publishDate;
  final String photoUrl;
  final String reportedBy;
  final List<MapFacility> facilities;

  factory MapLocation.fromJson(Map<String, dynamic> json) {
    final facilitiesJson = json['facilities'];
    final facilities = <MapFacility>[];
    if (facilitiesJson is List) {
      for (final item in facilitiesJson) {
        if (item is Map<String, dynamic>) {
          facilities.add(MapFacility.fromJson(item));
        }
      }
    }

    return MapLocation(
      id: (json['location_id'] ?? 0) as int,
      latitude: _toDouble(json['latitude']),
      longitude: _toDouble(json['longitude']),
      publishDate: (json['publish_date'] ?? '').toString(),
      photoUrl: (json['photo_url'] ?? '').toString(),
      reportedBy: (json['reported_by'] ?? '').toString(),
      facilities: facilities,
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }
}
