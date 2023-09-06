import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:push_app/config/domain/entities/push_message.dart';
import 'package:push_app/presentation/blocs/notifications/notifications_bloc.dart';

class DetailsScreen extends StatelessWidget {
  final String pushMessageId;

  const DetailsScreen({super.key, required this.pushMessageId});

  @override
  Widget build(BuildContext context) {

    final pushMessage = context.watch<NotificationsBloc>().getMessagebyId(pushMessageId);

    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles Push'),
      ),
      body: (pushMessage != null) ? _DetailsView(pushMessage: pushMessage) : Container(),
    );
  }
}

class _DetailsView extends StatelessWidget {
  final PushMessage pushMessage;

  const _DetailsView({
    super.key,
    required this.pushMessage,
  });

  @override
  Widget build(BuildContext context) {
    final textStyles = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (pushMessage.imageUrl != null)
            Image.network(
              pushMessage.imageUrl!,
              width: double.infinity,
              fit: BoxFit.cover,
            ),

          SizedBox(height: 10,),

          Text(
            pushMessage.title,
            style: textStyles.titleLarge,
          ),

          if (pushMessage.body != null)
            Text(
              pushMessage.body!,
              style: textStyles.bodyMedium,
            ),

          SizedBox(height: 10,),

          Text(
            pushMessage.sentTime.toString(),
            style: textStyles.bodySmall!.copyWith(
              color: Colors.grey,
            )
          ),

          const Divider(),

          Text(pushMessage.data.toString()),
        ],
      ),
    );
  }
}