part of 'notifications_bloc.dart';

abstract class NotificationsEvent {
  const NotificationsEvent();
}

class NotificationStatusChanges extends NotificationsEvent {
  final AuthorizationStatus newStatus;

  const NotificationStatusChanges(this.newStatus);
}
