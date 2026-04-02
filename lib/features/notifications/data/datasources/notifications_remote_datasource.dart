library;

import '../models/driver_notification_model.dart';

abstract class NotificationsRemoteDataSource {
  Future<List<DriverNotificationModel>> listNotifications();
  Future<void> markRead(String id);
}

