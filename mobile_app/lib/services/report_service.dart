import 'api_service.dart';

class ReportService {
  final ApiService _apiService = ApiService();

  // Get reports
  Future<Map<String, dynamic>> getReports({
    double? lat,
    double? lng,
    String? category,
    String? status,
    int limit = 20,
    int offset = 0,
  }) async {
    final queryParams = <String, String>{
      'limit': limit.toString(),
      'offset': offset.toString(),
    };

    if (lat != null) queryParams['lat'] = lat.toString();
    if (lng != null) queryParams['lng'] = lng.toString();
    if (category != null) queryParams['category'] = category;
    if (status != null) queryParams['status'] = status;

    return await _apiService.get('/api/v1/reports', queryParams: queryParams);
  }

  // Get single report
  Future<Map<String, dynamic>> getReportById(String reportId) async {
    return await _apiService.get('/api/v1/reports/$reportId');
  }

  // Create report
  Future<Map<String, dynamic>> createReport({
    required String imagePath,
    required String category,
    required double latitude,
    required double longitude,
    required String address,
    String? description,
  }) async {
    final fields = {
      'category': category,
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'address': address,
      if (description != null) 'description': description,
    };

    return await _apiService.multipartPost(
      '/api/v1/reports',
      fields,
      'image',
      imagePath,
    );
  }

  // Upvote report
  Future<Map<String, dynamic>> upvoteReport(String reportId) async {
    return await _apiService.post('/api/v1/reports/$reportId/upvote', {});
  }

  // Remove upvote
  Future<Map<String, dynamic>> removeUpvote(String reportId) async {
    return await _apiService.delete('/api/v1/reports/$reportId/upvote');
  }
}
