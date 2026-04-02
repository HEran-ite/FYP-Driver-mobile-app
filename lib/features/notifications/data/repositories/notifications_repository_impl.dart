library;

import '../../domain/entities/driver_notification.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../datasources/notifications_remote_datasource.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  NotificationsRepositoryImpl(this._remote);
  final NotificationsRemoteDataSource _remote;

  @override
  Future<List<DriverNotification>> listNotifications() async {
    final models = await _remote.listNotifications();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> markRead(String id) => _remote.markRead(id);
}

