/// Route name constants
/// 
/// All route names used in the application should be defined here.
/// Use these constants instead of hardcoded route strings.

class RouteNames {
  // Authentication Routes
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  
  // Dashboard Routes
  static const String driverDashboard = '/driver-dashboard';
  static const String garageDashboard = '/garage-dashboard';
  
  // Vehicle Routes
  static const String vehicleList = '/vehicles';
  static const String vehicleDetail = '/vehicles/:id';
  static const String registerVehicle = '/vehicles/register';
  static const String updateVehicle = '/vehicles/:id/update';
  
  // Maintenance Routes
  static const String maintenanceDashboard = '/maintenance';
  static const String maintenanceHistory = '/maintenance/history';
  static const String maintenanceDetail = '/maintenance/:id';
  static const String setMaintenanceReminder = '/maintenance/reminder';
  
  // Services Routes
  static const String serviceLocator = '/services';
  static const String serviceDetail = '/services/:id';
  static const String appointments = '/appointments';
  static const String appointmentDetail = '/appointments/:id';
  static const String bookAppointment = '/appointments/book';
  static const String emergencyAssistance = '/emergency';
  
  // AI Assistant Routes
  static const String aiChat = '/ai-chat';
  static const String aiChatHistory = '/ai-chat/history';
  
  // Education Routes
  static const String educationList = '/education';
  static const String educationDetail = '/education/:id';
  static const String educationSearch = '/education/search';
  
  // Community Routes
  static const String communityFeed = '/community';
  static const String myPosts = '/community/my-posts';
  static const String createPost = '/community/create';
  static const String postDetail = '/community/posts/:id';
  static const String editPost = '/community/posts/:id/edit';
  static const String bookmarks = '/community/bookmarks';
  
  // Profile Routes
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  
  // Settings Routes
  static const String settings = '/settings';
  
  // Notifications Routes
  static const String notifications = '/notifications';
  static const String notificationSettings = '/notifications/settings';
  
  // Private constructor to prevent instantiation
  RouteNames._();
}

