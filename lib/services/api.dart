import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const String baseUrl =
    'https://idol-audience-belongs-towards.trycloudflare.com';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

class Api {
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', token);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
  }

  static Future<Map<String, String>> _getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<dynamic> get(String endpoint) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      );

      return _handleResponse(response);
    } catch (e) {
      throw ApiException('Gagal melakukan request GET: $e');
    }
  }

  static Future<dynamic> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: jsonEncode(body),
      );

      return _handleResponse(response);
    } catch (e) {
      throw ApiException('Gagal melakukan request POST: $e');
    }
  }

  static Future<dynamic> put(String endpoint, Map<String, dynamic> body) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: jsonEncode(body),
      );

      return _handleResponse(response);
    } catch (e) {
      throw ApiException('Gagal melakukan request PUT: $e');
    }
  }

  static Future<dynamic> delete(String endpoint) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      );

      return _handleResponse(response);
    } catch (e) {
      throw ApiException('Gagal melakukan request DELETE: $e');
    }
  }

  static dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return {'status': 'success'};
      }
      return jsonDecode(response.body);
    } else {
      String errorMessage = 'Terjadi kesalahan pada server';

      try {
        final errorData = jsonDecode(response.body);

        // Penanganan error validasi skema (Pydantic 422) dari FastAPI
        if (errorData is Map) {
          if (errorData['detail'] is List) {
            errorMessage = (errorData['detail'] as List)
                .map(
                  (err) =>
                      '${err['loc']?.last ?? 'error'}: ${err['msg'] ?? 'error'}',
                )
                .join(' | ');
          } else if (errorData['detail'] is String) {
            errorMessage = errorData['detail'];
          } else if (errorData['message'] is String) {
            errorMessage = errorData['message'];
          }
        }
      } catch (e) {
        errorMessage = 'Error status ${response.statusCode}: ${response.body}';
      }

      throw ApiException(errorMessage);
    }
  }
}
