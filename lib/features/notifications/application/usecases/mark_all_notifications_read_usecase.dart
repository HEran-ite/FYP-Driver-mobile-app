library;

import '../../domain/repositories/notifications_repository.dart';

class MarkAllNotificationsReadUseCase {
  MarkAllNotificationsReadUseCase(this._repo);
  final NotificationsRepository _repo;

  Future<void> call() => _repo.markAllRead();
}
