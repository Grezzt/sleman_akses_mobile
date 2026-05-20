import 'dart:convert';

import '../../../../core/errors/api_exception.dart';
import '../../../../core/network/api_client.dart';
import '../models/facility_category.dart';
import '../models/map_location.dart';

class HomeRemoteDataSource {
  Future<List<FacilityCategory>> getCategories() async {
    ApiClient.ensureBaseUrl();
    final response = await ApiClient.client.get(
      Uri.parse('${ApiClient.baseUrl}/categories'),
      headers: ApiClient.headers,
    );

    final data = _handleListResponse(response);
    return data
        .whereType<Map<String, dynamic>>()
        .map(FacilityCategory.fromJson)
        .toList();
  }

  Future<List<MapLocation>> getMapLocations() async {
    ApiClient.ensureBaseUrl();
    final response = await ApiClient.client.get(
      Uri.parse('${ApiClient.baseUrl}/map'),
      headers: ApiClient.headers,
    );

    final data = _handleListResponse(response);
    return data
        .whereType<Map<String, dynamic>>()
        .map(MapLocation.fromJson)
        .toList();
  }

  List<dynamic> _handleListResponse(dynamic response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final body = _decodeBody(response.body);
      final data = body['data'];
      if (data is List) {
        return data;
      }
      return [];
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
