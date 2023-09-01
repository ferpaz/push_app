part of 'notifications_bloc.dart';

class NotificationsState extends Equatable {
  // Estado de las notificaciones
  final AuthorizationStatus authorizationStatus;

  // Lista de notificaciones push recibidas
  final List<dynamic> notifications;

  const NotificationsState({
    this.authorizationStatus = AuthorizationStatus.notDetermined,
    this.notifications = const[],
  });

  NotificationsState copyWith({
    AuthorizationStatus? authorizationStatus,
    List<dynamic>? notifications,
  }) => NotificationsState(
      authorizationStatus: authorizationStatus ?? this.authorizationStatus,
      notifications: notifications ?? this.notifications,
    );

  @override
  List<Object> get props => [authorizationStatus, notifications];
}
