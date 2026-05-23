import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/errors/api_exception.dart';
import '../../../../core/network/api_client.dart';

class ProfileRepository {
  Future<Map<String, dynamic>> updateProfile(String fullName) async {
    final uri = Uri.parse('${ApiClient.baseUrl}/profile');
    final response = await http.put(
      uri,
      headers: ApiClient.headers,
      body: jsonEncode({
        'full_name': fullName,
      }),
    );

    return _handleResponse(response);
  }

  Future<void> changePassword(String currentPassword, String newPassword, String newPasswordConfirmation) async {
    final uri = Uri.parse('${ApiClient.baseUrl}/profile/password');
    final response = await http.put(
      uri,
      headers: ApiClient.headers,
      body: jsonEncode({
        'current_password': currentPassword,
        'new_password': newPassword,
        'new_password_confirmation': newPasswordConfirmation,
      }),
    );

    _handleResponse(response);
  }

  Future<Map<String, dynamic>> getReportStats() async {
    final uri = Uri.parse('${ApiClient.baseUrl}/reports/stats');
    final response = await http.get(uri, headers: ApiClient.headers);

    return _handleResponse(response);
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.body.isEmpty) {
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {};
      }
      throw ApiException('Permintaan gagal.');
    }

    final body = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (body['success'] == true) {
        return body['data'] ?? {};
      }
    }

    throw ApiException(
      body['message']?.toString() ?? 'Permintaan gagal.',
      fieldErrors: _parseErrors(body),
    );
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
