library;

import 'package:dio/dio.dart';
import 'package:driver/features/auth/data/datasources/auth_remote_datasource.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../models/driver_response.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<LoginResponse> login({
    required String phone,
    required String password,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.driverAuthLogin,
      data: {'phone': phone, 'password': password},
    );
    final data = res.data;
    if (data == null) {
      throw Exception('Empty login response');
    }
    final token = data['token'] ?? data['accessToken'];
    if (token is! String || token.isEmpty) {
      throw Exception('Login response missing token');
    }
    Map<String, dynamic>? driverMap;
    final rawDriver = data['driver'];
    if (rawDriver is Map) {
      driverMap = Map<String, dynamic>.from(rawDriver);
    } else if (data.containsKey('id') ||
        data.containsKey('_id') ||
        data.containsKey('firstName')) {
      driverMap = Map<String, dynamic>.from(data)
        ..remove('token')
        ..remove('accessToken');
    }
    if (driverMap == null) {
      throw Exception('Login response missing driver');
    }
    final driver = DriverResponse.fromJson(driverMap);
    if (driver.id.isEmpty) {
      throw Exception('Login response missing driver id');
    }
    return LoginResponse(token: token, driver: driver);
  }

  @override
  Future<DriverResponse> signup({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.driverAuthSignup,
      data: {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phone': phone,
        'password': password,
      },
    );
    return DriverResponse.fromJson(res.data!);
  }

  @override
  Future<LoginResponse> signupWithFirebase({
    required String idToken,
    required String firstName,
    required String lastName,
    required String email,
    String? password,
  }) async {
    final payload = <String, dynamic>{
      'idToken': idToken,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
    };
    final p = password?.trim();
    if (p != null && p.isNotEmpty) {
      payload['password'] = p;
    }
    final res = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.driverAuthFirebase,
      data: payload,
    );
    final data = res.data ?? <String, dynamic>{};
    final token = data['token'] ?? data['accessToken'];
    if (token is! String || token.isEmpty) {
      throw Exception('Firebase signup response missing token');
    }
    final rawDriver = data['driver'];
    if (rawDriver is! Map) {
      throw Exception('Firebase signup response missing driver');
    }
    final driver = DriverResponse.fromJson(Map<String, dynamic>.from(rawDriver));
    return LoginResponse(token: token, driver: driver);
  }

  @override
  Future<void> logout() async {
    await _dio.post(ApiEndpoints.driverAuthLogout);
  }

  @override
  Future<DriverResponse> getProfile() async {
    final res = await _dio.get<Map<String, dynamic>>(ApiEndpoints.driverProfile);
    return DriverResponse.fromJson(res.data!);
  }

  @override
  Future<DriverResponse> createProfile({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.driverProfile,
      data: {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phone': phone,
      },
    );
    return DriverResponse.fromJson(res.data!);
  }

  @override
  Future<DriverResponse> updateProfile({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
  }) async {
    final res = await _dio.put<Map<String, dynamic>>(
      ApiEndpoints.driverProfile,
      data: {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phone': phone,
      },
    );
    return DriverResponse.fromJson(res.data!);
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _dio.put(
      ApiEndpoints.driverProfileChangePassword,
      data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
    );
  }
}
