import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:path_provider/path_provider.dart';
import 'package:isar/isar.dart';

import 'package:push_app/config/domain/entities/push_message.dart';
import 'package:push_app/firebase_options.dart';

part 'notifications_event.dart';
part 'notifications_state.dart';

// Handler para recibir notificaciones cuando la app esta en segundo plano o cerrada
Future<void> firebaseMessaginBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  var pushMessage = PushMessage.fromRemoteMessage(message);

  await savePushMessageIsar(pushMessage);
}

Future<void> savePushMessageIsar(PushMessage pushMessage) async {
  final isar = await getIsarInstance();

  if (await isar.pushMessages.where().idEqualTo(pushMessage.id).count() > 0) {
    return;
  }

  await isar.writeTxn(() => isar.pushMessages.put(pushMessage));
}

Future<Isar> getIsarInstance() async {
  final dir = await getApplicationDocumentsDirectory();

  final isar = Isar.getInstance() ?? await Isar.open([PushMessageSchema], directory: dir.path);
  return isar;
}

// Clase para manejar el estado de las notificaciones
class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  final Future<void> Function()? requestLocalNotificationPermissions;

  final void Function({required int id, String? title, String? body, String? data})? showLocalNotification;

  static Future<void> initializeFCM() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  NotificationsBloc({this.requestLocalNotificationPermissions, this.showLocalNotification}) : super(NotificationsState()) {
    on<NotificationStatusChanges>(_onNotificationStatusChanged);
    on<NotificationReceived>(_onNotificationReceived);
    on<NotificationsReceived>(_onNotificationsReceived);
    on<RemoveNotification>(_onRemoveNotification);

    // Inicializa notificaciones recibidas mientras la App estaba en segundo plano o cerrada
    initializePushMessages();

    // Verifica el estado de las notificaciones
    _initialStatusCheck();

    // Listener para recibir notificaciones cuando la app esta en primer plano
    _onForegroundMessage();
  }

  // Método para solicitar al usuario que otorgue los permisos para recibir notificaciones
  Future<void> requestPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: true,
      provisional: false,
      sound: true,
    );

    // Solicitar permiso para recibir local notifications
    if (requestLocalNotificationPermissions != null) {
      await requestLocalNotificationPermissions!();
    }

    add(NotificationStatusChanges(settings.authorizationStatus));
  }

  void initializePushMessages() async {
    final isar = await getIsarInstance();

    final messages = await isar.pushMessages.where().sortBySentTimeDesc().findAll();
    add(NotificationsReceived(messages));
  }

  // Inicializa el estado de autorización de las notificaciones
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

  // Inicializa el servicio que recibe los mensajes de notificación recibidos cuando la app esta en primer plano
  void _onForegroundMessage() => FirebaseMessaging.onMessage.listen((RemoteMessage message) async => await handleRemoteMessage(message));

  // Método para manejar el cambio de estado de autorización para las notificaciones
  Future<void> _onNotificationStatusChanged(NotificationStatusChanges event, Emitter<NotificationsState> emit) async {
    emit(state.copyWith(authorizationStatus: event.newStatus));

    if (event.newStatus == AuthorizationStatus.authorized) {
      final token = await messaging.getToken();
      print('Token: $token');
    }
  }

  // Método para manejar la recepción de un nuevo mensaje de notificación y lo agrega al estado
  void _onNotificationReceived(NotificationReceived event, Emitter<NotificationsState> emit) {
    if (state.notifications.any((sm) => sm.id == event.message.id)) return;
    emit(state.copyWith(notifications: [event.message, ...state.notifications]));
  }

  void _onNotificationsReceived(NotificationsReceived event, Emitter<NotificationsState> emit) {
    final newMessages = event.messages.where((nm) => !state.notifications.any((sm) => sm.id == nm.id)).toList();
    emit(state.copyWith(notifications: [...newMessages, ...state.notifications]));
  }

  Future<void> _onRemoveNotification(RemoveNotification event, Emitter<NotificationsState> emit) async {
    final isar = await getIsarInstance();

    var query = isar.pushMessages.where().idEqualTo(event.message.id);
    if (await query.count() > 0) {
      await isar.writeTxn(() => query.deleteFirst());
    }

    emit(state.copyWith(notifications: state.notifications.where((element) => element.id != event.message.id).toList()));
  }

  // Método para manejar un mensaje de notificación recibido por la App
  Future<void> handleRemoteMessage(RemoteMessage message) async {
    var pushMessage = PushMessage.fromRemoteMessage(message);
    await savePushMessageIsar(pushMessage);

    if (showLocalNotification != null)
      showLocalNotification!(
        id: pushMessage.id.hashCode,
        title: pushMessage.title,
        body: pushMessage.body,
        data: pushMessage.id,
      );

    add(NotificationReceived(pushMessage));
  }

  // Obtiene la inforacion de un mensaje de notificación por su id
  PushMessage? getMessagebyId(String pushMessageId) {
    return state.notifications.any((element) => element.id == pushMessageId) ? state.notifications.firstWhere((element) => element.id == pushMessageId) : null;
  }
}
