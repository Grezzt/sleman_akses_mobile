import 'datasources/home_remote_data_source.dart';
import 'models/facility_category.dart';
import 'models/map_location.dart';

class HomeRepository {
  HomeRepository(this._remoteDataSource);

  final HomeRemoteDataSource _remoteDataSource;

  Future<List<FacilityCategory>> getCategories() {
    return _remoteDataSource.getCategories();
  }

  Future<List<MapLocation>> getMapLocations() {
    return _remoteDataSource.getMapLocations();
  }
}
