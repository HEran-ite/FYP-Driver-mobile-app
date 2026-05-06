library;

import '../../domain/repositories/auth_repository.dart';

class LoginUseCase {
  LoginUseCase(this._repository);
  final AuthRepository _repository;

  Future<AuthResult> call({required String phone, required String password}) {
    return _repository.login(phone: phone, password: password);
  }
}
