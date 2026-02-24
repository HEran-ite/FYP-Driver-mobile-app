library;

import 'dart:convert';

import '../../domain/entities/driver_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/driver_response.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remote,
    required AuthLocalDataSource local,
  })  : _remote = remote,
        _local = local;

  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;

  @override
  Future<AuthResult> login({
    required String phone,
    required String password,
  }) async {
    final response = await _remote.login(phone: phone, password: password);
    await _local.saveToken(response.token);
    final userJson = _userToJson(response.driver);
    await _local.saveUser(userJson);
    return AuthResult(token: response.token, user: response.driver.toEntity());
  }

  @override
  Future<DriverUser> signup({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
  }) async {
    await _remote.signup(
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
      password: password,
    );
    final result = await login(phone: phone, password: password);
    return result.user;
  }

  @override
  Future<void> logout() async {
    try {
      await _remote.logout();
    } catch (_) {}
    await _local.clear();
  }

  @override
  Future<String?> getToken() => _local.getToken();

  @override
  Future<DriverUser?> getCurrentUser() async {
    final json = await _local.getUserJson();
    if (json == null) return null;
    final map = _jsonToMap(json);
    if (map == null) return null;
    return DriverResponse.fromJson(map).toEntity();
  }

  @override
  Future<void> updateProfile(DriverUser user) async {
    final json = jsonEncode({
      'id': user.id,
      'firstName': user.firstName,
      'lastName': user.lastName,
      'email': user.email,
      'phone': user.phone,
    });
    await _local.saveUser(json);
  }

  String _userToJson(DriverResponse d) {
    return jsonEncode({
      'id': d.id,
      'firstName': d.firstName,
      'lastName': d.lastName,
      'email': d.email,
      'phone': d.phone,
    });
  }

  Map<String, dynamic>? _jsonToMap(String jsonStr) {
    try {
      return Map<String, dynamic>.from(jsonDecode(jsonStr) as Map);
    } catch (_) {
      return null;
    }
  }
}
