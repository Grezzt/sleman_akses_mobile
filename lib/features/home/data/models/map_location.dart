import 'map_facility.dart';

class MapLocation {
  const MapLocation({
    required this.id,
    required this.placeName,
    required this.address,
    required this.status,
    required this.facilityType,
    required this.latitude,
    required this.longitude,
    required this.publishDate,
    required this.photoUrl,
    required this.reportedBy,
    required this.facilities,
  });

  final int id;
  final String placeName;
  final String address;
  final String status;
  final String facilityType;
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
      placeName: (json['place_name'] ?? '').toString(),
      address: (json['address'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      facilityType: (json['facility_type'] ?? '').toString(),
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
