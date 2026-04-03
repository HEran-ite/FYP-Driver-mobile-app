/// API endpoint constants aligned with driver-garage-backend.
/// Base URL should be configured via environment or app constants.
library;

import 'dart:io' show Platform;

class ApiEndpoints {
  /// Base URL for driver-garage-backend.
  /// Android emulator cannot reach localhost; 10.0.2.2 is the host machine.
  /// iOS simulator and desktop can use localhost.
  static String get baseUrl {
    if (Platform.isAndroid) return 'http://10.0.2.2:4000';
    return 'http://localhost:4000';
  }

  // ----- Driver Auth (prefix: /drivers/auth) -----
  static const String driverAuthSignup = '/drivers/auth/signup';
  static const String driverAuthLogin = '/drivers/auth/login';
  static const String driverAuthLogout = '/drivers/auth/logout';

  // ----- Driver Appointments (prefix: /drivers/appointments) -----
  static const String driverAppointments = '/drivers/appointments';

  static String driverAppointmentById(String id) => '/drivers/appointments/$id';
  static String driverAppointmentReschedule(String id) =>
      '/drivers/appointments/$id/reschedule';
  static String driverAppointmentCancel(String id) =>
      '/drivers/appointments/$id/cancel';

  // ----- Driver Vehicles (try /driver/vehicles if /drivers/vehicles returns 404) -----
  static const String driverVehicles = '/driver/vehicles';
  static String driverVehicleById(String id) => '/driver/vehicles/$id';

  // ----- Driver Profile (prefix: /driver) -----
  static const String driverProfile = '/driver/profile';

  // ----- Driver Community (prefix: /driver/community) -----
  static const String driverCommunityPosts = '/driver/community/posts';

  // ----- Driver Education (prefix: /driver/education, JWT) -----
  static const String driverEducation = '/driver/education';
  static String driverEducationById(String id) => '/driver/education/$id';
  static const String driverEducationSearch = '/driver/education/search';

  // ----- Driver Maintenance (prefix: /driver/maintenance) -----
  static const String driverMaintenanceCatalog = '/driver/maintenance/catalog';
  static String driverMaintenanceVehicleHealth(String vehicleId) =>
      '/driver/maintenance/health/$vehicleId';
  static const String driverMaintenanceUpcoming = '/driver/maintenance/upcoming';
  static const String driverMaintenanceHistory = '/driver/maintenance/history';
  static String driverMaintenanceUpcomingById(String id) =>
      '/driver/maintenance/upcoming/$id';
  static String driverMaintenanceHistoryById(String id) =>
      '/driver/maintenance/history/$id';
  static String driverMaintenanceUpcomingToggleReminder(String id) =>
      '/driver/maintenance/upcoming/$id/reminder';
  static String driverMaintenanceUpcomingMarkDone(String id) =>
      '/driver/maintenance/upcoming/$id/done';
  static const String driverMaintenanceNotifications = '/driver/maintenance/notifications';
  static String driverMaintenanceNotificationRead(String id) =>
      '/driver/maintenance/notifications/$id/read';

  // ----- Legacy / other (keep for future use) -----
  static const String profile = '/profile';
  static const String nearbyServices = '/services/nearby';
  static String garageAvailabilitySlots(String garageId) =>
      '/garages/availability/$garageId/slots';
  static const String notifications = '/notifications';

  ApiEndpoints._();
}
