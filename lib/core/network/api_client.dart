import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  static String get baseUrl => dotenv.env['API_BASE_URL'] ?? '';

  static String? _token;
  static final http.Client _client = http.Client();

  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  static http.Client get client => _client;

  static void setToken(String token) {
    _token = token;
  }

  static void clearToken() {
    _token = null;
  }
}
