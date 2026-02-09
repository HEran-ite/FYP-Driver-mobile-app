/// API endpoint constants
/// 
/// All API endpoint URLs should be defined here.
/// Base URL should be configured via environment variables.

class ApiEndpoints {
  // Base URL (should be loaded from environment)
  static const String baseUrl = 'https://api.example.com/v1';
  
  // Authentication
  static const String login = '/auth/login';
  static const String signup = '/auth/signup';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  
  // Profile
  static const String profile = '/profile';
  static const String updateProfile = '/profile/update';
  
  // Vehicles
  static const String vehicles = '/vehicles';
  static const String registerVehicle = '/vehicles/register';
  static const String updateVehicle = '/vehicles/update';
  
  // Maintenance
  static const String maintenance = '/maintenance';
  static const String maintenanceHistory = '/maintenance/history';
  static const String maintenanceReminders = '/maintenance/reminders';
  
  // Services
  static const String services = '/services';
  static const String nearbyServices = '/services/nearby';
  
  // Appointments
  static const String appointments = '/appointments';
  static const String bookAppointment = '/appointments/book';
  static const String rescheduleAppointment = '/appointments/reschedule';
  static const String cancelAppointment = '/appointments/cancel';
  
  // Emergency
  static const String emergency = '/emergency/request';
  
  // AI Assistant
  static const String aiChat = '/ai/chat';
  static const String aiChatHistory = '/ai/chat/history';
  
  // Education
  static const String education = '/education';
  static const String searchEducation = '/education/search';
  
  // Community
  static const String posts = '/community/posts';
  static const String comments = '/community/comments';
  static const String bookmarks = '/community/bookmarks';
  
  // Notifications
  static const String notifications = '/notifications';
  static const String notificationSettings = '/notifications/settings';
  
  // Reviews
  static const String reviews = '/reviews';
  static const String rateGarage = '/reviews/rate';
  
  // Private constructor to prevent instantiation
  ApiEndpoints._();
}

