import 'package:flutter/foundation.dart';

import '../../../core/errors/api_exception.dart';
import '../data/home_repository.dart';
import '../data/models/facility_category.dart';
import '../data/models/map_location.dart';

class HomeController {
  HomeController(this._repository);

  final HomeRepository _repository;

  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(true);
  final ValueNotifier<String?> errorMessage = ValueNotifier<String?>(null);
  final ValueNotifier<List<MapLocation>> locations =
      ValueNotifier<List<MapLocation>>([]);
  final ValueNotifier<List<FacilityCategory>> categories =
      ValueNotifier<List<FacilityCategory>>([]);
  final ValueNotifier<int?> selectedCategoryId =
      ValueNotifier<int?>(null);

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final results = await Future.wait([
        _repository.getCategories(),
        _repository.getMapLocations(),
      ]);
      categories.value = results[0] as List<FacilityCategory>;
      locations.value = results[1] as List<MapLocation>;
    } catch (error) {
      if (error is ApiException) {
        errorMessage.value = error.message;
      } else {
        errorMessage.value = error.toString();
      }
    } finally {
      isLoading.value = false;
    }
  }

  void setSelectedCategory(int? categoryId) {
    selectedCategoryId.value = categoryId;
  }

  List<MapLocation> filterLocations(
    List<MapLocation> items,
    List<FacilityCategory> categories,
  ) {
    final selectedId = selectedCategoryId.value;
    if (selectedId == null) {
      return items;
    }

    final selectedCategory = categories
        .cast<FacilityCategory?>()
        .firstWhere(
          (category) => category?.id == selectedId,
          orElse: () => null,
        );

    final selectedName = selectedCategory?.name.toLowerCase().trim();
    if (selectedName == null || selectedName.isEmpty) {
      return items;
    }

    return items
        .where(
          (location) => location.facilities.any(
            (facility) =>
                facility.category.toLowerCase().trim() == selectedName,
          ),
        )
        .toList();
  }

  void dispose() {
    isLoading.dispose();
    errorMessage.dispose();
    locations.dispose();
    categories.dispose();
    selectedCategoryId.dispose();
  }
}
