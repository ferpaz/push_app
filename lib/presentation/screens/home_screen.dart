import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

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
    final textStyles = Theme.of(context).textTheme;
    final notifications = context.watch<NotificationsBloc>().state.notifications;

    if (notifications.isEmpty)
      return Container();

    return ListView.builder(
      itemCount: notifications.length,
      itemBuilder: (BuildContext context, int index) {
        final notification = notifications[index];

        return Dismissible(
          key: Key(notification.id),
          resizeDuration: null,
          direction: DismissDirection.endToStart,
          onDismissed: (direction) => context.read<NotificationsBloc>().add(RemoveNotification(notification)),
          background: Container(
            color: Colors.red,
            child: Row(
              children: [
                const Spacer(),
                const SizedBox(width: 20,),
                Text("Eliminar", style: textStyles.bodyMedium!.copyWith(color: Colors.white)),
                const SizedBox(width: 10,),
                const Icon(Icons.delete_rounded, color: Colors.white),
                const SizedBox(width: 20,),
              ],
            ),
          ),
          child: ListTile(
            title: Text(notification.title),
            subtitle: notification.body == null ? null :Text(notification.body!),
            leading: notification.imageUrl == null ? null : Image.network(notification.imageUrl!),
            trailing: Text(_formatSentDate(notification.sentTime)) ,
            onTap: () {
              context.push('/push-details/${notification.id}');
            },
          ),
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