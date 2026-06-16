import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  void init() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Foreground message: ${message.notification?.title} - ${message.notification?.body}');
      // Qui puoi mostrare un toast o una notifica locale
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('User clicked notification: ${message.notification?.title}');
      // Naviga a una schermata specifica se vuoi
    });

    // Background/terminated handled automatically
  }
}