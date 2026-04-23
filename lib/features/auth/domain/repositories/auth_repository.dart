library;

import '../entities/driver_user.dart';

abstract class AuthRepository {
  Future<AuthResult> login({required String phone, required String password});
  Future<DriverUser> signup({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
  });
  Future<void> logout();
  Future<String?> getToken();
  Future<DriverUser?> getCurrentUser();
  /// Persist updated profile (name, email) locally so drawer and app reflect changes.
  Future<void> updateProfile(DriverUser user);
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });
}

class AuthResult {
  const AuthResult({required this.token, required this.user});
  final String token;
  final DriverUser user;
}
