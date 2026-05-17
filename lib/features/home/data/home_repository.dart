import 'datasources/home_local_data_source.dart';

class HomeRepository {
  HomeRepository(this._localDataSource);

  final HomeLocalDataSource _localDataSource;

  Future<String> getWelcomeMessage() {
    return _localDataSource.getWelcomeMessage();
  }
}
