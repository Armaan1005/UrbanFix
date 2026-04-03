import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _token;

  // Get token from storage
  Future<String?> _getToken() async {
    if (_token != null) return _token;
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('access_token');
    return _token;
  }

  // Set token
  void setToken(String token) {
    _token = token;
  }

  // Clear token
  void clearToken() {
    _token = null;
  }

  // GET request
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? queryParams,
  }) async {
    try {
      final token = await _getToken();
      final uri = Uri.parse(
        '${AppConfig.apiBaseUrl}$endpoint',
      ).replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // POST request
  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final token = await _getToken();
      final uri = Uri.parse('${AppConfig.apiBaseUrl}$endpoint');

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: json.encode(body),
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // PATCH request
  Future<Map<String, dynamic>> patch(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final token = await _getToken();
      final uri = Uri.parse('${AppConfig.apiBaseUrl}$endpoint');

      final response = await http.patch(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: json.encode(body),
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // DELETE request
  Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final token = await _getToken();
      final uri = Uri.parse('${AppConfig.apiBaseUrl}$endpoint');

      final response = await http.delete(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // Multipart request (for file uploads)
  Future<Map<String, dynamic>> multipartPost(
    String endpoint,
    Map<String, String> fields,
    String fileField,
    String filePath,
  ) async {
    try {
      final token = await _getToken();
      final uri = Uri.parse('${AppConfig.apiBaseUrl}$endpoint');

      final request = http.MultipartRequest('POST', uri);

      // Add headers
      request.headers['Authorization'] = 'Bearer $token';

      // Add fields
      request.fields.addAll(fields);

      // Add file
      request.files.add(await http.MultipartFile.fromPath(fileField, filePath));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Upload error: ${e.toString()}'};
    }
  }

  // Handle response
  Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final data = json.decode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data;
      } else if (response.statusCode == 401) {
        // Unauthorized - token expired
        clearToken();
        return {
          'success': false,
          'message': 'Session expired. Please login again.',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Request failed',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Failed to parse response'};
    }
  }
}
