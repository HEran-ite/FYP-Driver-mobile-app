library;

import 'package:equatable/equatable.dart';

abstract class NotificationsEvent extends Equatable {
  const NotificationsEvent();
  @override
  List<Object?> get props => [];
}

class NotificationsLoadRequested extends NotificationsEvent {
  const NotificationsLoadRequested();
}

class NotificationMarkReadRequested extends NotificationsEvent {
  const NotificationMarkReadRequested(this.id);
  final String id;
  @override
  List<Object?> get props => [id];
}

