library;

import '../models/driver_response.dart';

abstract class AuthRemoteDataSource {
  Future<LoginResponse> login({required String phone, required String password});
  Future<DriverResponse> signup({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
  });
  Future<void> logout();
}

class LoginResponse {
  const LoginResponse({required this.token, required this.driver});
  final String token;
  final DriverResponse driver;
}
