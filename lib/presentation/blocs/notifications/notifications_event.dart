part of 'notifications_bloc.dart';

abstract class NotificationsEvent {
  const NotificationsEvent();
}

class NotificationStatusChanges extends NotificationsEvent {
  final AuthorizationStatus newStatus;

  const NotificationStatusChanges(this.newStatus);
}

class NotificationReceived extends NotificationsEvent {
  final PushMessage message;

  const NotificationReceived(this.message);
}
