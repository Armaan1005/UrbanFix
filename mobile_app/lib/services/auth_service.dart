import 'api_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  // Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    return await _apiService.post('/api/v1/auth/login', {
      'email': email,
      'password': password,
    });
  }

  // Register
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String city,
    required String ward,
  }) async {
    return await _apiService.post('/api/v1/auth/register', {
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
      'city': city,
      'ward': ward,
    });
  }

  // Get current user
  Future<Map<String, dynamic>?> getCurrentUser(String token) async {
    _apiService.setToken(token);
    final response = await _apiService.get('/api/v1/users/me');
    return response['success'] ? response['data'] : null;
  }

  // Refresh token
  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    return await _apiService.post('/api/v1/auth/refresh', {
      'refreshToken': refreshToken,
    });
  }

  // Logout
  Future<void> logout() async {
    _apiService.clearToken();
  }
}
