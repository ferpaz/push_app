import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:push_app/firebase_options.dart';

part 'notifications_event.dart';
part 'notifications_state.dart';


Future<void> firebaseMessaginBackgroundHandler (RemoteMessage message) async {
  await Firebase.initializeApp();

  print('Message data: ${message.data}');
  print('Message notification: ${message.notification}');

  if (message.notification != null) {
    print('Message notification title: ${message.notification!.title}');
    print('Message notification body: ${message.notification!.body}');
  }
}


class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  static Future<void> initializeFCM() async {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);
  }

  NotificationsBloc() : super(NotificationsState()) {
    on<NotificationStatusChanges>(onNotificationStatusChanged);

    // Verifica el estado de las notificaciones
    _initialStatusCheck();

    // Listener para recibir notificaciones cuando la app esta en primer plano
    _onForegroundMessage();

    // Listener para recibir notificaciones cuando la app esta en segundo plano
    _onForegroundMessage();
  }

  void _initialStatusCheck() async {
    // get notification settings solo pregunta si tiene permisos o no
    NotificationSettings settings = await messaging.getNotificationSettings();
    add(NotificationStatusChanges(settings.authorizationStatus));

    /*
      Aqui deberia de obtenerse al token que identifica al dispositivo / instalacion de la app
      En algun lugar (base de datos) se debe guardar este token por cada cuenta de usuario
      para poder enviar notificaciones push a un usuario en especifico y a todos los dispositivos
      que tenga asociados a su cuenta
    */

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      final token = await messaging.getToken();
      print('Token: $token');
    }
  }

  void _onForegroundMessage() => FirebaseMessaging.onMessage.listen(_handleRemoteMessage);


  // Método para manejar un mensaje de notificación recibido po la App
  void _handleRemoteMessage(RemoteMessage message) {
    print('Message data: ${message.data}');
    print('Message notification: ${message.notification}');

    if (message.notification != null) {
      print('Message notification title: ${message.notification!.title}');
      print('Message notification body: ${message.notification!.body}');
    }
  }

  // Método para manejar el cambio de estado de autorización para las notificaciones
  Future<FutureOr<void>> onNotificationStatusChanged(NotificationStatusChanges event, Emitter<NotificationsState> emit) async {
    emit(state.copyWith(authorizationStatus: event.newStatus));

    if (event.newStatus == AuthorizationStatus.authorized) {
      final token = await messaging.getToken();
      print('Token: $token');
    }
  }

  // Método para solicitar los permisos de notificaciones
  Future<void> requestPermission() async {
    // requiere los permisos de notificaciones
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: true,
      provisional: false,
      sound: true,
    );

    add(NotificationStatusChanges(settings.authorizationStatus));
  }
}
