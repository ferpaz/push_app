part of 'notifications_bloc.dart';

class NotificationsState extends Equatable {
  // Estado de las notificaciones
  final AuthorizationStatus authorizationStatus;

  // Lista de notificaciones push recibidas
  final List<PushMessage> notifications;

  const NotificationsState({
    this.authorizationStatus = AuthorizationStatus.notDetermined,
    this.notifications = const[],
  });

  NotificationsState copyWith({
    AuthorizationStatus? authorizationStatus,
    List<PushMessage>? notifications,
  }) => NotificationsState(
      authorizationStatus: authorizationStatus ?? this.authorizationStatus,
      notifications: notifications ?? this.notifications,
    );

  @override
  List<Object> get props => [authorizationStatus, notifications];
}
