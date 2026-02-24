/// API endpoint constants aligned with driver-garage-backend.
/// Base URL should be configured via environment or app constants.
library;

class ApiEndpoints {
  /// Base URL for driver-garage-backend (e.g. http://10.0.2.2:3000 for Android emulator).
  static const String baseUrl = 'http://10.0.2.2:4000';

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

  // ----- Legacy / other (keep for future use) -----
  static const String profile = '/profile';
  static const String nearbyServices = '/services/nearby';
  static const String notifications = '/notifications';

  ApiEndpoints._();
}
