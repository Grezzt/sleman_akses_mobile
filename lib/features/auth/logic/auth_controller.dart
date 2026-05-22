import 'package:flutter/material.dart';

import '../../../core/errors/api_exception.dart';
import '../../../core/network/api_client.dart';
import '../data/auth_repository.dart';
import '../data/models/user_model.dart';

class AuthController extends ChangeNotifier {
  AuthController(this._repository);

  final AuthRepository _repository;

  UserModel? _user;
  String? _token;
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, List<String>> _fieldErrors = {};

  UserModel? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _token != null && _token!.isNotEmpty;

  String? fieldError(String key) {
    final errors = _fieldErrors[key];
    if (errors == null || errors.isEmpty) {
      return null;
    }
    return errors.first;
  }

  Future<void> loadFromStorage() async {
    final storedToken = await _repository.getStoredToken();
    if (storedToken != null && storedToken.isNotEmpty) {
      _token = storedToken;
      ApiClient.setToken(storedToken);
    }
    notifyListeners();
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    _setLoading(true);
    _clearErrors();
    try {
      final session = await _repository.register(
        fullName: fullName,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      await _persistSession(session);
      return true;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      _fieldErrors = error.fieldErrors;
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> login({required String email, required String password}) async {
    _setLoading(true);
    _clearErrors();
    try {
      final session = await _repository.login(email: email, password: password);
      await _persistSession(session);
      return true;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      _fieldErrors = error.fieldErrors;
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchProfile() async {
    _setLoading(true);
    _clearErrors();
    try {
      final user = await _repository.getProfile();
      _user = user;
      notifyListeners();
    } on ApiException catch (error) {
      _errorMessage = error.message;
      _fieldErrors = error.fieldErrors;
    } catch (e) {
      _errorMessage = 'Gagal mengambil profil';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    try {
      await _repository.logout();
    } catch (_) {
      // ignore logout errors; local session still cleared
    }
    await _repository.clearToken();
    ApiClient.clearToken();
    _token = null;
    _user = null;
    _setLoading(false);
  }

  Future<void> _persistSession(AuthSession session) async {
    _token = session.token;
    _user = session.user;
    ApiClient.setToken(session.token);
    await _repository.saveToken(session.token);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearErrors() {
    _errorMessage = null;
    _fieldErrors = {};
  }
}
