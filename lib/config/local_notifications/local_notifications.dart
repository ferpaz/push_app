import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:push_app/config/router/app_router.dart';

class LocalNotifications {
  static Future<void> requestPermissionLocalNotification() async {
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestPermission();
  }

  static Future<void> initialize() async {
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const initializationSettingsAndroid = AndroidInitializationSettings('app_icon');

    // static const initializationSettingsIOS = DarwinInitializationSettings(
    //   requestAlertPermission: false,
    //   requestBadgePermission: false,
    //   requestSoundPermission: false,
    // );

    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      // iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );
  }

  static void onDidReceiveNotificationResponse(NotificationResponse response) {
    if (response.payload == null) return;
    appRouter.push('/push-details/${response.payload}');
  }

  static void showLocalNotification({required int id, String? title, String? body, String? data}) {
    final androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'channelId',
      'channelName',
      playSound: true,
      sound: RawResourceAndroidNotificationSound('notification'),
      importance: Importance.max,
      priority: Priority.high,
      // showWhen: false,
      // autoCancel: true,
      // enableVibration: true,
      // styleInformation: const DefaultStyleInformation(true, true),
    );

    // final iOSPlatformChannelSpecifics = DarwinNotificationDetails(
    //   presentAlert: true,
    //   presentBadge: true,
    //   presentSound: true,
    // );

    final platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      // iOS: iOSPlatformChannelSpecifics,
    );

    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: data,
    );
  }
}
