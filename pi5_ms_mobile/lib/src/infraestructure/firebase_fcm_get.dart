import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> getToken() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  String? token = await messaging.getToken();
  print("Token FCM: $token");
}
