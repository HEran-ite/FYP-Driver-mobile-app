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
    final data = res.data!;
    return LoginResponse(
      token: data['token'] as String,
      driver: DriverResponse.fromJson(data['driver'] as Map<String, dynamic>),
    );
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
}
