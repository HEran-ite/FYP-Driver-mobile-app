/// General application constants
/// 
/// This file contains all general constants used throughout the application.
/// DO NOT hardcode values in UI - use constants from this file and related constant files.

class AppConstants {
  // App Information
  static const String appName = 'Driver Assistance';
  static const String appVersion = '1.0.0';
  
  // API Configuration
  static const int connectionTimeout = 30000; // milliseconds
  static const int receiveTimeout = 30000; // milliseconds
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Cache Duration
  static const int cacheExpirationMinutes = 5;
  
  // Session
  static const int sessionTimeoutMinutes = 15;
  
  // File Upload
  static const int maxFileSizeMB = 10;
  static const List<String> allowedImageFormats = ['jpg', 'jpeg', 'png'];
  
  // Validation
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 50;
  
  // Private constructor to prevent instantiation
  AppConstants._();
}

