// lib/src/services/firebase_notification_service.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FirebaseNotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // Inicializar o serviço
  static Future<void> initialize() async {
    await Firebase.initializeApp();

    // Solicitar permissões
    await _requestPermissions();

    // Configurar notificações locais
    await _initializeLocalNotifications();

    // Configurar handlers
    _setupFirebaseHandlers();
  }

  // Solicitar permissões do usuário
  static Future<void> _requestPermissions() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
    );

    print('Permissão concedida: ${settings.authorizationStatus}');
  }

  // Configurar notificações locais
  static Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  // Configurar handlers do Firebase
  static void _setupFirebaseHandlers() {
    // Quando o app está em foreground
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Quando o app é aberto através de uma notificação
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Quando o app está completamente fechado
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  // Handler para mensagens em foreground
  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('Mensagem recebida em foreground: ${message.notification?.title}');

    // Mostrar notificação local
    await _showLocalNotification(message);
  }

  // Handler para quando a notificação é tocada
  static Future<void> _handleNotificationTap(RemoteMessage message) async {
    print('Notificação tocada: ${message.data}');

    // Navegar para tela específica baseada nos dados
    _navigateToScreen(message.data);
  }

  // Mostrar notificação local
  static Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          channelDescription:
              'This channel is used for important notifications.',
          importance: Importance.high,
          priority: Priority.high,
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'Nova Notificação',
      message.notification?.body ?? 'Você tem uma nova notificação',
      notificationDetails,
      payload: message.data.toString(),
    );
  }

  // Callback para quando notificação local é tocada
  static void _onNotificationTapped(NotificationResponse response) {
    print('Notificação local tocada: ${response.payload}');
    // Processar dados e navegar
  }

  // Navegar para tela baseada no tipo de notificação
  static void _navigateToScreen(Map<String, dynamic> data) {
    final String? type = data['type'];

    switch (type) {
      case 'EVENT_CREATED':
      case 'EVENT_TODAY':
        // Navegar para tela de eventos
        break;
      case 'EXAM_CREATED':
      case 'EXAM_REMINDER':
        // Navegar para tela de provas
        break;
      case 'SESSION_CREATED':
      case 'SESSION_FINISHED':
        // Navegar para tela de sessões
        break;
      default:
        // Tela padrão
        break;
    }
  }

  // Obter token FCM (atualizar sua função existente)
  static Future<String?> getToken() async {
    try {
      String? token = await _messaging.getToken();
      print('FCM Token: $token');
      return token;
    } catch (e) {
      print('Erro ao obter token: $e');
      return null;
    }
  }
}

// Handler para mensagens em background (deve estar fora da classe)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Mensagem em background: ${message.notification?.title}');
}
