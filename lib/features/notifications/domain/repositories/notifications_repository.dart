library;

import '../entities/driver_notification.dart';

abstract class NotificationsRepository {
  Future<List<DriverNotification>> listNotifications();
  Future<void> markRead(String id);
  Future<void> markAllRead();
}
