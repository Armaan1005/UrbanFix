class AppConfig {
  // API Configuration
  static const String apiBaseUrl = 'http://10.0.2.2:3000'; // Android emulator
  // static const String apiBaseUrl = 'http://localhost:3000'; // iOS simulator
  // static const String apiBaseUrl = 'https://api.urbanfix.in'; // Production

  static const String wsUrl = 'ws://10.0.2.2:3000';

  // App Configuration
  static const String appName = 'UrbanFix';
  static const String appVersion = '1.0.0';
  static const String appCity = 'Chennai';

  // API Endpoints
  static const String authEndpoint = '/api/v1/auth';
  static const String reportsEndpoint = '/api/v1/reports';
  static const String usersEndpoint = '/api/v1/users';
  static const String notificationsEndpoint = '/api/v1/notifications';

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Map Configuration
  static const double defaultLatitude = 13.0827; // Chennai
  static const double defaultLongitude = 80.2707;
  static const double defaultZoom = 13.0;
  static const double nearbyRadius = 5.0; // km

  // Image Configuration
  static const int maxImageSize = 10 * 1024 * 1024; // 10MB
  static const int imageQuality = 85;
  static const int maxImageWidth = 1920;
  static const int maxImageHeight = 1080;

  // Offline Configuration
  static const int maxRetryAttempts = 5;
  static const int syncIntervalMinutes = 5;

  // Points System
  static const int pointsForReport = 50;
  static const int pointsForUpvote = 10;
  static const int pointsForResolution = 100;

  // Issue Categories
  static const List<String> issueCategories = [
    'pothole',
    'garbage',
    'streetlight',
    'footpath',
    'drain',
  ];

  static const Map<String, String> issueCategoryLabels = {
    'pothole': 'Pothole',
    'garbage': 'Garbage Dump',
    'streetlight': 'Broken Streetlight',
    'footpath': 'Damaged Footpath',
    'drain': 'Open Drain',
  };

  static const Map<String, String> issueCategoryIcons = {
    'pothole': '🕳️',
    'garbage': '🗑️',
    'streetlight': '💡',
    'footpath': '🚶',
    'drain': '🌊',
  };

  // Status Labels
  static const Map<String, String> statusLabels = {
    'reported': 'Reported',
    'acknowledged': 'Acknowledged',
    'under_review': 'Under Review',
    'in_progress': 'In Progress',
    'resolved': 'Resolved',
    'rejected': 'Rejected',
  };

  // Status Colors
  static const Map<String, String> statusColors = {
    'reported': '#FF5252', // Red
    'acknowledged': '#FFA726', // Orange
    'under_review': '#42A5F5', // Blue
    'in_progress': '#AB47BC', // Purple
    'resolved': '#66BB6A', // Green
    'rejected': '#757575', // Grey
  };
}
