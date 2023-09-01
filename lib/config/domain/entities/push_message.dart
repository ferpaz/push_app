import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:isar/isar.dart';

part 'push_message.g.dart';

@collection
class PushMessage {
  final Id key = Isar.autoIncrement;

  @Index(unique: true, caseSensitive: false)
  final String id;

  final String title;
  final String? body;
  final String? data;
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
  data: ${dataToMap()},
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
      data: _dataMapToJson(message.data),
      imageUrl: Platform.isAndroid
        ? message.notification?.android?.imageUrl
        : message.notification?.apple?.imageUrl,
    );

  // convertir un string en formato json en un Map<String, dynamic>
  Map<String, dynamic> dataToMap() {
    if (data == null) return {};
    return jsonDecode(data!);
  }

  // convertir un Map<String, dynamic> en un string en formato json
  static String _dataMapToJson(Map<String, dynamic> map) {
    if (map.isEmpty) return '';
    return jsonEncode(map);
  }
}