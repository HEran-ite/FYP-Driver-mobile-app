library;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'auth_local_datasource.dart';

const _keyToken = 'auth_token';
const _keyUser = 'auth_user';

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  AuthLocalDataSourceImpl({FlutterSecureStorage? secureStorage})
      : _storage = secureStorage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  @override
  Future<void> saveToken(String token) => _storage.write(key: _keyToken, value: token);

  @override
  Future<void> saveUser(String json) => _storage.write(key: _keyUser, value: json);

  @override
  Future<String?> getToken() => _storage.read(key: _keyToken);

  @override
  Future<String?> getUserJson() => _storage.read(key: _keyUser);

  @override
  Future<void> clear() async {
    await _storage.delete(key: _keyToken);
    await _storage.delete(key: _keyUser);
  }
}
