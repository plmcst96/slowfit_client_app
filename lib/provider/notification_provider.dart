import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../model/notification_model.dart';
import '../service/api_service.dart';
import 'login_provider.dart';

final fcmTokenProvider = StateNotifierProvider<FcmTokenNotifier, String?>(
  (ref) => FcmTokenNotifier(),
);

class FcmTokenNotifier extends StateNotifier<String?> {
  FcmTokenNotifier() : super(null) {
    _init();
  }

  Future<void> _init() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Chiede permessi (iOS)
    await messaging.requestPermission();

    // Ottiene il token
    final token = await messaging.getToken();
    state = token;
    print('📱 Token FCM: $token');

    // Aggiorna quando cambia
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      state = newToken;
      print('🔁 Token FCM aggiornato: $newToken');
      // Aggiorna subito anche sul backend se l'utente è loggato
      final container = ProviderContainer();
      final login = container.read(loginProvider);
      if (login.userId != null) {
        ApiService().updateFcmToken(login.userId!, newToken);
      }
    });
  }
}

final updateFcmTokenProvider = FutureProvider<void>((ref) async {
  final token = ref.watch(fcmTokenProvider);
  final login = ref.watch(loginProvider);

  print('🧠 updateFcmTokenProvider - token: $token');
  print('🧠 updateFcmTokenProvider - userId: ${login.userId}');

  if (token != null && login.userId != null) {
    final success = await ApiService().updateFcmToken(login.userId!, token);
    print(
      success
          ? '✅ Token aggiornato sul backend con successo'
          : '❌ Errore nell’aggiornamento token',
    );
  } else {
    print('⚠️ Token o userId null, skip update.');
  }
});

final notificationProvider =
    StateNotifierProvider<NotificationNotifier, List<RemoteMessage>>(
      (ref) => NotificationNotifier(),
    );

class NotificationNotifier extends StateNotifier<List<RemoteMessage>> {
  NotificationNotifier() : super([]) {
    _init();
  }

  void _init() {
    // Notifiche in foreground
    FirebaseMessaging.onMessage.listen((message) {
      state = [...state, message];
    });

    // Notifiche cliccate dall'utente (foreground/background)
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      state = [...state, message];
    });
  }

  void clear() => state = [];
}


final notificationsProvider = StateNotifierProvider<NotificationsNotifier, List<NotificationModel>>(
      (ref) => NotificationsNotifier(),
);

class NotificationsNotifier extends StateNotifier<List<NotificationModel>> {
  NotificationsNotifier() : super([]);

  final _apiService = ApiService();

  // Recupera notifiche dal backend per un utente
  Future<void> fetchNotifications(int userId) async {
    try {
      final notificationsJson = await _apiService.getNotifications(userId);

      state = notificationsJson
          .map<NotificationModel>((json) => NotificationModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Errore nel fetch delle notifiche: $e');
    }
  }

  // Pulisce le notifiche
  void clear() => state = [];

  Future<void> deleteNotification(int notificationId) async {
    final apiService = ApiService();
    final success = await apiService.deleteNotification(notificationId);
    if (success) {
      state = state.where((n) => n.id != notificationId).toList();
    }
  }
}

class ReadNotificationNotifier extends StateNotifier<Map<int, bool>> {
  ReadNotificationNotifier() : super({});

  void markAsRead(int notificationId) {
    state = {
      ...state,
      notificationId: true,
    };
  }

  bool isRead(int notificationId) {
    return state[notificationId] ?? false;
  }
}

final readNotificationProvider =
StateNotifierProvider<ReadNotificationNotifier, Map<int, bool>>(
        (ref) => ReadNotificationNotifier());
