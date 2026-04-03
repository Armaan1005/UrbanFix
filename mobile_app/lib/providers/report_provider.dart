import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/report.dart';
import '../models/comment.dart';
import '../services/report_service.dart';

class ReportProvider with ChangeNotifier {
  final ReportService _reportService = ReportService();
  final _supabase = Supabase.instance.client;

  List<Report> _reports = [];
  Report? _selectedReport;
  List<Comment> _comments = [];
  bool _isLoading = false;
  bool _isLoadingComments = false;
  String? _error;

  // Caching
  DateTime? _lastFetchTime;
  Map<String, DateTime> _reportCacheTimes = {};
  Map<String, DateTime> _commentsCacheTimes = {};
  static const Duration _cacheDuration = Duration(minutes: 5);

  List<Report> get reports => _reports;
  Report? get selectedReport => _selectedReport;
  List<Comment> get comments => _comments;
  bool get isLoading => _isLoading;
  bool get isLoadingComments => _isLoadingComments;
  String? get error => _error;

  // Check if cache is still valid
  bool _isCacheValid(DateTime? cacheTime) {
    if (cacheTime == null) return false;
    return DateTime.now().difference(cacheTime) < _cacheDuration;
  }

  // Fetch reports
  Future<void> fetchReports({
    double? lat,
    double? lng,
    String? category,
    String? status,
    bool forceRefresh = false,
  }) async {
    // Check if we have cached data and it's still valid
    if (!forceRefresh && _isCacheValid(_lastFetchTime) && _reports.isNotEmpty) {
      print('Using cached reports (${_reports.length} reports)');
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      var query = _supabase.from('reports').select();

      // Apply filters if provided
      if (status != null) {
        query = query.eq('status', status);
      }
      if (category != null) {
        query = query.eq('category', category);
      }

      // Order and execute
      final response = await query.order('created_at', ascending: false);

      _reports = (response as List).map((json) {
        // Transform Supabase data to match Report model format
        return Report.fromJson({
          'reportId': json['id']?.toString() ?? '',
          'issueNumber': '#${json['id']?.toString() ?? '000'}',
          'status': json['status']?.toString() ?? 'reported',
          'category': json['category']?.toString() ?? 'other',
          'location': {
            'latitude': (json['latitude'] ?? 0.0).toDouble(),
            'longitude': (json['longitude'] ?? 0.0).toDouble(),
            'address': json['address']?.toString() ?? 'Unknown location',
          },
          'imageUrl': json['image_url']?.toString() ?? '',
          'description': json['description']?.toString() ?? '',
          'reportedBy': {
            'userId': json['user_id']?.toString() ?? '',
            'name': 'User',
            'avatarUrl': '',
          },
          'createdAt': json['created_at']?.toString() ??
              DateTime.now().toIso8601String(),
          'updatedAt': json['updated_at']?.toString() ??
              DateTime.now().toIso8601String(),
          'upvotes': json['upvotes'] ?? 0,
          'upvotedByUser': false,
          'comments': json['comments_count'] ?? 0,
          'timeline': [],
          'evidence': [],
        });
      }).toList();

      _lastFetchTime = DateTime.now();
      print('Fetched ${_reports.length} reports from server');
      _error = null;
    } catch (e) {
      print('Error fetching reports: $e');
      _error = e.toString();
      _reports = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch single report
  Future<void> fetchReportById(String reportId,
      {bool forceRefresh = false}) async {
    // Check if we have cached data for this specific report
    if (!forceRefresh &&
        _selectedReport?.reportId == reportId &&
        _isCacheValid(_reportCacheTimes[reportId])) {
      print('Using cached report: $reportId');
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      print('Fetching report by ID: $reportId');

      final response =
          await _supabase.from('reports').select().eq('id', reportId).single();

      print('Report response: $response');

      // Transform to Report model
      _selectedReport = Report.fromJson({
        'reportId': response['id']?.toString() ?? '',
        'issueNumber':
            '#${response['id']?.toString().substring(0, 8) ?? '000'}',
        'status': response['status']?.toString() ?? 'reported',
        'category': response['category']?.toString() ?? 'other',
        'location': {
          'latitude': (response['latitude'] ?? 0.0).toDouble(),
          'longitude': (response['longitude'] ?? 0.0).toDouble(),
          'address': response['address']?.toString() ?? 'Unknown location',
        },
        'imageUrl': response['image_url']?.toString() ?? '',
        'description': response['description']?.toString() ?? '',
        'reportedBy': {
          'userId': response['user_id']?.toString() ?? '',
          'name': 'User',
          'avatarUrl': '',
        },
        'createdAt': response['created_at']?.toString() ??
            DateTime.now().toIso8601String(),
        'updatedAt': response['updated_at']?.toString() ??
            DateTime.now().toIso8601String(),
        'upvotes': response['upvotes'] ?? 0,
        'upvotedByUser': false,
        'comments': response['comments_count'] ?? 0,
        'timeline': [],
        'evidence': [],
      });

      _reportCacheTimes[reportId] = DateTime.now();
      _error = null;
    } catch (e) {
      print('Error fetching report by ID: $e');
      _error = e.toString();
      _selectedReport = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create report
  Future<String?> createReport({
    required String imageUrl,
    required String category,
    required String title,
    required double latitude,
    required double longitude,
    required String address,
    String? description,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Insert report into Supabase
      final response = await _supabase
          .from('reports')
          .insert({
            'user_id': user.id,
            'category': category.toLowerCase(),
            'title': title,
            'description': description ?? '',
            'image_url': imageUrl,
            'latitude': latitude,
            'longitude': longitude,
            'address': address,
            'status': 'reported',
            'upvotes': 0,
            'comments_count': 0,
          })
          .select()
          .single();

      print('Report created: $response');

      final reportId = response['id'] as String;

      // Create initial timeline event
      await _supabase.from('timeline_events').insert({
        'report_id': reportId,
        'status': 'reported',
        'message': 'Report submitted',
        'updated_by': user.userMetadata?['name'] ?? 'User',
      });

      _error = null;
      _isLoading = false;
      notifyListeners();
      return reportId;
    } catch (e) {
      print('Error creating report: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Fetch nearby reports
  Future<void> fetchNearbyReports(double latitude, double longitude) async {
    await fetchReports(lat: latitude, lng: longitude);
  }

  // Fetch all reports
  Future<void> fetchAllReports() async {
    await fetchReports();
  }

  // Toggle upvote
  Future<void> toggleUpvote(String reportId) async {
    // Find the report
    final index = _reports.indexWhere((r) => r.reportId == reportId);
    if (index == -1) return;

    final report = _reports[index];

    if (report.upvotedByUser) {
      await removeUpvote(reportId);
    } else {
      await upvoteReport(reportId);
    }
  }

  // Upvote report
  Future<bool> upvoteReport(String reportId) async {
    try {
      final response = await _reportService.upvoteReport(reportId);

      if (response['success']) {
        // Update local report
        final index = _reports.indexWhere((r) => r.reportId == reportId);
        if (index != -1) {
          _reports[index] = _reports[index].copyWith(
            upvotes: response['data']['upvotes'],
            upvotedByUser: true,
          );
        }

        if (_selectedReport?.reportId == reportId) {
          _selectedReport = _selectedReport!.copyWith(
            upvotes: response['data']['upvotes'],
            upvotedByUser: true,
          );
        }

        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Remove upvote
  Future<bool> removeUpvote(String reportId) async {
    try {
      final response = await _reportService.removeUpvote(reportId);

      if (response['success']) {
        // Update local report
        final index = _reports.indexWhere((r) => r.reportId == reportId);
        if (index != -1) {
          _reports[index] = _reports[index].copyWith(
            upvotes: response['data']['upvotes'],
            upvotedByUser: false,
          );
        }

        if (_selectedReport?.reportId == reportId) {
          _selectedReport = _selectedReport!.copyWith(
            upvotes: response['data']['upvotes'],
            upvotedByUser: false,
          );
        }

        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Update report from WebSocket
  void updateReportFromWebSocket(Map<String, dynamic> data) {
    final reportId = data['reportId'];
    final index = _reports.indexWhere((r) => r.reportId == reportId);

    if (index != -1) {
      // Update existing report
      final updatedReport = _reports[index].copyWith(
        status: data['newStatus'],
        timeline: (data['timeline'] as List?)
            ?.map((t) => TimelineEvent.fromJson(t))
            .toList(),
      );
      _reports[index] = updatedReport;

      if (_selectedReport?.reportId == reportId) {
        _selectedReport = updatedReport;
      }

      notifyListeners();
    }
  }

  // Add new report from WebSocket
  void addReportFromWebSocket(Map<String, dynamic> data) {
    final newReport = Report.fromJson(data);
    _reports.insert(0, newReport);
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Clear selected report
  void clearSelectedReport() {
    _selectedReport = null;
    notifyListeners();
  }

  // Fetch comments for a report
  Future<void> fetchComments(String reportId,
      {bool forceRefresh = false}) async {
    // Check if we have cached comments for this report
    if (!forceRefresh &&
        _comments.isNotEmpty &&
        _comments.first.reportId == reportId &&
        _isCacheValid(_commentsCacheTimes[reportId])) {
      print('Using cached comments for report: $reportId');
      return;
    }

    _isLoadingComments = true;
    notifyListeners();

    try {
      final response = await _supabase.from('comments').select('''
            *,
            users!comments_user_id_fkey (
              name,
              avatar_url
            )
          ''').eq('report_id', reportId).order('created_at', ascending: true);

      _comments = (response as List).map((json) {
        final user = json['users'];
        return Comment(
          id: json['id'],
          reportId: json['report_id'],
          userId: json['user_id'],
          userName: user?['name'] ?? 'Unknown User',
          userAvatar: user?['avatar_url'],
          commentText: json['comment_text'],
          createdAt: DateTime.parse(json['created_at']),
          updatedAt: DateTime.parse(json['updated_at']),
        );
      }).toList();

      _commentsCacheTimes[reportId] = DateTime.now();
      _error = null;
    } catch (e) {
      print('Error fetching comments: $e');
      _error = e.toString();
      _comments = [];
    } finally {
      _isLoadingComments = false;
      notifyListeners();
    }
  }

  // Add a comment
  Future<bool> addComment(String reportId, String commentText) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      await _supabase.from('comments').insert({
        'report_id': reportId,
        'user_id': user.id,
        'comment_text': commentText,
      });

      // Refresh comments
      await fetchComments(reportId);

      return true;
    } catch (e) {
      print('Error adding comment: $e');
      _error = e.toString();
      return false;
    }
  }

  // Delete a comment
  Future<bool> deleteComment(String commentId, String reportId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      await _supabase
          .from('comments')
          .delete()
          .eq('id', commentId)
          .eq('user_id', user.id);

      // Refresh comments
      await fetchComments(reportId);

      return true;
    } catch (e) {
      print('Error deleting comment: $e');
      _error = e.toString();
      return false;
    }
  }

  // Clear comments
  void clearComments() {
    _comments = [];
    notifyListeners();
  }
}
