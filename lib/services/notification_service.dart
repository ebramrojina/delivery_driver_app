import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> initialize({required String token, required String locale}) async {
    await _messaging.requestPermission(alert: true, badge: true, sound: true);

    final fcmToken = await _messaging.getToken();
    if (fcmToken != null) {
      await _sendTokenToBackend(fcmToken, token, locale);
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('New order notification: ${message.notification?.title}');
    });
  }

  Future<void> _sendTokenToBackend(String fcmToken, String authToken, String locale) async {
    try {
      await http.put(
        Uri.parse('${ApiConfig.baseUrl}/users/fcm-token'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({'fcmToken': fcmToken, 'locale': locale}),
      );
    } catch (e) {
      print('Failed to save FCM token: $e');
    }
  }
}