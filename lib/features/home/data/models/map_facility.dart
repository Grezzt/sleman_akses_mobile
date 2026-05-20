class MapFacility {
  const MapFacility({
    required this.category,
    required this.iconMarker,
    required this.available,
  });

  final String category;
  final String iconMarker;
  final bool available;

  factory MapFacility.fromJson(Map<String, dynamic> json) {
    return MapFacility(
      category: (json['category'] ?? '').toString(),
      iconMarker: (json['icon_marker'] ?? '').toString(),
      available: (json['available'] ?? false) as bool,
    );
  }
}
