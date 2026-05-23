import 'package:flutter/material.dart';
import '../../../../core/errors/api_exception.dart';
import '../data/profile_repository.dart';

class ProfileController extends ChangeNotifier {
  ProfileController(this._repository);

  final ProfileRepository _repository;

  bool _isLoadingStats = false;
  bool _isUpdating = false;

  int _totalDikirim = 0;
  int _totalDisetujui = 0;
  int _totalDitolak = 0;

  String? _statsErrorMessage;
  String? _updateErrorMessage;
  Map<String, List<String>> _fieldErrors = {};

  bool get isLoadingStats => _isLoadingStats;
  bool get isUpdating => _isUpdating;
  int get totalDikirim => _totalDikirim;
  int get totalDisetujui => _totalDisetujui;
  int get totalDitolak => _totalDitolak;
  String? get statsErrorMessage => _statsErrorMessage;
  String? get updateErrorMessage => _updateErrorMessage;

  String? fieldError(String key) {
    final errors = _fieldErrors[key];
    if (errors == null || errors.isEmpty) {
      return null;
    }
    return errors.first;
  }

  void _clearUpdateErrors() {
    _updateErrorMessage = null;
    _fieldErrors = {};
    notifyListeners();
  }

  Future<void> fetchStats() async {
    _isLoadingStats = true;
    _statsErrorMessage = null;
    notifyListeners();

    try {
      final stats = await _repository.getReportStats();
      _totalDikirim = stats['total_dikirim'] ?? 0;
      _totalDisetujui = stats['total_disetujui'] ?? 0;
      _totalDitolak = stats['total_ditolak'] ?? 0;
    } on ApiException catch (error) {
      _statsErrorMessage = error.message;
    } catch (e) {
      _statsErrorMessage = 'Gagal mengambil statistik';
    } finally {
      _isLoadingStats = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile({required String fullName}) async {
    _isUpdating = true;
    _clearUpdateErrors();

    try {
      await _repository.updateProfile(fullName);
      _isUpdating = false;
      notifyListeners();
      return true;
    } on ApiException catch (error) {
      _updateErrorMessage = error.message;
      _fieldErrors = error.fieldErrors;
      _isUpdating = false;
      notifyListeners();
      return false;
    } catch (e) {
      _updateErrorMessage = 'Gagal memperbarui profil';
      _isUpdating = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    _isUpdating = true;
    _clearUpdateErrors();

    try {
      await _repository.changePassword(
        currentPassword,
        newPassword,
        newPasswordConfirmation,
      );
      _isUpdating = false;
      notifyListeners();
      return true;
    } on ApiException catch (error) {
      _updateErrorMessage = error.message;
      _fieldErrors = error.fieldErrors;
      _isUpdating = false;
      notifyListeners();
      return false;
    } catch (e) {
      _updateErrorMessage = 'Gagal mengubah kata sandi';
      _isUpdating = false;
      notifyListeners();
      return false;
    }
  }
}
