library;

import '../../domain/repositories/notifications_repository.dart';

class MarkNotificationReadUseCase {
  MarkNotificationReadUseCase(this._repo);
  final NotificationsRepository _repo;

  Future<void> call(String id) => _repo.markRead(id);
}

