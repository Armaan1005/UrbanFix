import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class UserProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  User? _currentUser;
  List<dynamic> _leaderboard = [];
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  List<dynamic> get leaderboard => _leaderboard;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get current user profile
  Future<void> fetchCurrentUser() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.get('/users/me');

      if (response['success']) {
        _currentUser = User.fromJson(response['data']);
        _error = null;
      } else {
        _error = response['message'];
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch user profile by ID
  Future<void> fetchUserProfile(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.get('/users/$userId');

      if (response['success']) {
        _currentUser = User.fromJson(response['data']);
        _error = null;
      } else {
        _error = response['message'];
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update user profile
  Future<bool> updateProfile(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.patch('/users/me', data);

      if (response['success']) {
        _currentUser = User.fromJson(response['data']);
        _error = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response['message'];
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Fetch leaderboard
  Future<void> fetchLeaderboard({String period = 'monthly'}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response =
          await _apiService.get('/users/leaderboard?period=$period');

      if (response['success']) {
        _leaderboard = response['data']['leaderboard'];
        _error = null;
      } else {
        _error = response['message'];
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add points to user
  void addPoints(int points) {
    if (_currentUser != null) {
      _currentUser = User(
        userId: _currentUser!.userId,
        name: _currentUser!.name,
        email: _currentUser!.email,
        phone: _currentUser!.phone,
        city: _currentUser!.city,
        ward: _currentUser!.ward,
        avatar: _currentUser!.avatar,
        points: _currentUser!.points + points,
        rank: _currentUser!.rank,
        badges: _currentUser!.badges,
        stats: _currentUser!.stats,
        createdAt: _currentUser!.createdAt,
      );
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
