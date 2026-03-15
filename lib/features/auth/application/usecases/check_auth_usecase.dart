library;

import '../../domain/entities/driver_user.dart';
import '../../domain/repositories/auth_repository.dart';

class CheckAuthUseCase {
  CheckAuthUseCase(this._repository);
  final AuthRepository _repository;

  Future<DriverUser?> call() => _repository.getCurrentUser();
}
