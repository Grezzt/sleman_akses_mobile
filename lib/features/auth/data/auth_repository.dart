import '../../../core/storage/token_storage.dart';
import 'datasources/auth_remote_data_source.dart';
import 'models/user_model.dart';

class AuthSession {
  AuthSession({required this.token, required this.user});

  final String token;
  final UserModel user;
}

class AuthRepository {
  AuthRepository(this._remote, this._storage);

  final AuthRemoteDataSource _remote;
  final TokenStorage _storage;

  Future<AuthSession> register({
    required String fullName,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final data = await _remote.register(
      fullName: fullName,
      email: email,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );

    final token = (data['token'] ?? '') as String;
    final user = UserModel.fromJson(
      (data['user'] ?? {}) as Map<String, dynamic>,
    );

    return AuthSession(token: token, user: user);
  }

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final data = await _remote.login(email: email, password: password);
    final token = (data['token'] ?? '') as String;
    final user = UserModel.fromJson(
      (data['user'] ?? {}) as Map<String, dynamic>,
    );

    return AuthSession(token: token, user: user);
  }

  Future<UserModel> getProfile() async {
    final data = await _remote.getProfile();
    return UserModel.fromJson(data);
  }

  Future<void> logout() {
    return _remote.logout();
  }

  Future<void> saveToken(String token) {
    return _storage.saveToken(token);
  }

  Future<String?> getStoredToken() {
    return _storage.getToken();
  }

  Future<void> clearToken() {
    return _storage.clearToken();
  }
}
