library;

import '../../domain/entities/driver_user.dart';
import '../../domain/repositories/auth_repository.dart';

class UpdateProfileUseCase {
  UpdateProfileUseCase(this._repository);
  final AuthRepository _repository;

  Future<void> call(DriverUser user) => _repository.updateProfile(user);
}
