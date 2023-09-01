import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:push_app/presentation/blocs/notifications/notifications_bloc.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: context.select((NotificationsBloc value) => Text(value.state.authorizationStatus.toString())),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              context.read<NotificationsBloc>().requestPermission();
            },
          ),
        ],
      ),
      body: _HomeView(),

    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    final notifications = context.watch<NotificationsBloc>().state.notifications;

    if (notifications.isEmpty)
      return Container();

    return ListView.builder(
      itemCount: notifications.length,
      itemBuilder: (BuildContext context, int index) {
        final notification = notifications[index];

        return ListTile(
          title: Text(notification.title),
          subtitle: notification.body == null ? null :Text(notification.body!),
          leading: notification.imageUrl == null ? null : Image.network(notification.imageUrl!),
          trailing: Text(_formatSentDate(notification.sentTime)) ,
        );
      },
    );
  }

  String _formatSentDate(DateTime sentTime) {
    String res = '';

    if (sentTime.year == DateTime.now().year && sentTime.month == DateTime.now().month && sentTime.day == DateTime.now().day) {
      res += 'Hoy';
    } else  if (sentTime.year == DateTime.now().year && sentTime.month == DateTime.now().month) {
      res += 'El ${sentTime.day}';
    } else  if (sentTime.year == DateTime.now().year) {
      res += 'El ${sentTime.day} / ${sentTime.month}';
    }

    return res + ' ${sentTime.hour}:${sentTime.minute}';
  }
}