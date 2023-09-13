import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:push_app/config/local_notifications/local_notifications.dart';
import 'package:push_app/config/router/app_router.dart';
import 'package:push_app/config/theme/app_theme.dart';
import 'package:push_app/presentation/blocs/notifications/notifications_bloc.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Registra el handler para recibir notificaciones cuando la app esta en segundo plano
  FirebaseMessaging.onBackgroundMessage(firebaseMessaginBackgroundHandler);

  // Inicializa el Bloc de notificaciones
  await NotificationsBloc.initializeFCM();

  // Inicializa las notificaciones locales
  await LocalNotifications.initialize();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => NotificationsBloc(
          requestLocalNotificationPermissions: LocalNotifications.requestPermissionLocalNotification,
          showLocalNotification: LocalNotifications.showLocalNotification,
        )),
      ],
      child: const MainApp(),
    )
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: AppTheme().themeData,
      routerConfig: appRouter,
      builder: (context, child) => HandleNotificationInteractions(child: child!),
    );
  }
}

class HandleNotificationInteractions extends StatefulWidget {
  final Widget child;

  const HandleNotificationInteractions({super.key, required this.child});

  @override
  State<HandleNotificationInteractions> createState() => _HandleNotificationInteractionsState();
}

class _HandleNotificationInteractionsState extends State<HandleNotificationInteractions> with WidgetsBindingObserver {

  Future<void> setupInteractedMessage() async {
    // Get any messages which caused the application to open from a terminated state.
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();

    // Process any interacted messages received as a result of the user tapping on a notification.
    if (initialMessage != null) _handleMessage(initialMessage);

    // Also handle any interaction when the app is in the background via a Stream listener
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  void _handleMessage(RemoteMessage message) {
    context.read<NotificationsBloc>().handleRemoteMessage(message);

    appRouter.push('/push-details/${message.messageId?.replaceAll(':', '').replaceAll('%', '') ?? ''}');
  }

  @override
  void initState() {
    super.initState();

    // Escuchar los cambios de estado en el ciclo de vida de la app
    WidgetsBinding.instance.addObserver(this);

    // Run code required to handle interacted messages in an async function as initState() must not be async
    setupInteractedMessage();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      // La app esta en primer plano
      case AppLifecycleState.resumed:
        // Agrega posibles notificaciones recibidas mientras la App estaba en segundo plano
        context.read<NotificationsBloc>().initializePushMessages();
        break;

      // La app paso a segundo plano
      case AppLifecycleState.inactive:
        break;

      // Está a punto de pausarse o cerrarse
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        break;

      // Acaba de iniciar y no tiene vistas visibles
      case AppLifecycleState.detached:
        break;
    }
  }
}