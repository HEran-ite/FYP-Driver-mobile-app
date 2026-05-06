library;

import '../../domain/entities/driver_user.dart';
import '../../domain/repositories/auth_repository.dart';

class SignupUseCase {
  SignupUseCase(this._repository);
  final AuthRepository _repository;

  Future<DriverUser> call({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    String? firebaseIdToken,
  }) {
    return _repository.signup(
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
      password: password,
      firebaseIdToken: firebaseIdToken,
    );
  }
}
