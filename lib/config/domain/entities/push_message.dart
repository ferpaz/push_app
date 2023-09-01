import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';

class PushMessage {
  final String id;
  final String title;
  final String? body;
  final Map<String, dynamic>? data;
  final DateTime sentTime;
  final String? imageUrl;

  PushMessage({
    required this.id,
    required this.title,
    required this.sentTime,
    this.body,
    this.data,
    this.imageUrl,
  });

  @override
  String toString() {
    return '''
PushMesage (
  id: $id,
  title: $title,
  body: $body,
  data: $data,
  sentTime: $sentTime,
  imageUrl: $imageUrl,
)''';
  }

  static PushMessage fromRemoteMessage(RemoteMessage message)
    => PushMessage(
      id: message.messageId?.replaceAll(':', '').replaceAll('%', '') ?? '',
      title: message.notification?.title ?? '',
      sentTime: message.sentTime ?? DateTime.now(),
      body: message.notification?.body,
      data: message.data,
      imageUrl: Platform.isAndroid
        ? message.notification?.android?.imageUrl
        : message.notification?.apple?.imageUrl,
    );
}