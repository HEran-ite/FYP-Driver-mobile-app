library;

import '../../domain/entities/driver_notification.dart';
import '../../domain/repositories/notifications_repository.dart';

class ListNotificationsUseCase {
  ListNotificationsUseCase(this._repo);
  final NotificationsRepository _repo;

  Future<List<DriverNotification>> call() => _repo.listNotifications();
}
