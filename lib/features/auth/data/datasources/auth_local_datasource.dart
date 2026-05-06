library;

abstract class AuthLocalDataSource {
  Future<void> saveToken(String token);
  Future<void> saveUser(String json);
  Future<String?> getToken();
  Future<String?> getUserJson();
  Future<void> clear();
}
