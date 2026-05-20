class FacilityCategory {
  const FacilityCategory({
    required this.id,
    required this.name,
    required this.iconMarker,
  });

  final int id;
  final String name;
  final String iconMarker;

  factory FacilityCategory.fromJson(Map<String, dynamic> json) {
    return FacilityCategory(
      id: (json['category_id'] ?? 0) as int,
      name: (json['facility_name'] ?? '').toString(),
      iconMarker: (json['icon_marker'] ?? '').toString(),
    );
  }
}
