import 'dart:convert';

import '../../../../core/errors/api_exception.dart';
import '../../../../core/network/api_client.dart';

class AuthRemoteDataSource {
  Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    ApiClient.ensureBaseUrl();
    final response = await ApiClient.client.post(
      Uri.parse('${ApiClient.baseUrl}/auth/register'),
      headers: ApiClient.headers,
      body: jsonEncode({
        'full_name': fullName,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      }),
    );

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    ApiClient.ensureBaseUrl();
    final response = await ApiClient.client.post(
      Uri.parse('${ApiClient.baseUrl}/auth/login'),
      headers: ApiClient.headers,
      body: jsonEncode({'email': email, 'password': password}),
    );

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> getProfile() async {
    ApiClient.ensureBaseUrl();
    final response = await ApiClient.client.get(
      Uri.parse('${ApiClient.baseUrl}/profile'),
      headers: ApiClient.headers,
    );

    return _handleResponse(response);
  }

  Future<void> logout() async {
    ApiClient.ensureBaseUrl();
    final response = await ApiClient.client.post(
      Uri.parse('${ApiClient.baseUrl}/auth/logout'),
      headers: ApiClient.headers,
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final body = _decodeBody(response.body);
      throw ApiException(
        body['message']?.toString() ?? 'Logout gagal.',
        fieldErrors: _parseErrors(body),
      );
    }
  }

  Map<String, dynamic> _handleResponse(dynamic response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final body = _decodeBody(response.body);
      final data = body['data'];
      if (data is Map<String, dynamic>) {
        return data;
      }
      return body;
    }

    final body = _decodeBody(response.body);
    throw ApiException(
      body['message']?.toString() ?? 'Permintaan gagal.',
      fieldErrors: _parseErrors(body),
    );
  }

  Map<String, dynamic> _decodeBody(String body) {
    if (body.isEmpty) {
      return {};
    }
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    return {};
  }

  Map<String, List<String>> _parseErrors(Map<String, dynamic> body) {
    final errors = body['errors'];
    if (errors is! Map<String, dynamic>) {
      return {};
    }

    final parsed = <String, List<String>>{};
    for (final entry in errors.entries) {
      final value = entry.value;
      if (value is List) {
        parsed[entry.key] = value.map((e) => e.toString()).toList();
      } else if (value != null) {
        parsed[entry.key] = [value.toString()];
      }
    }
    return parsed;
  }
}
