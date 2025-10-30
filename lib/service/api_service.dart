// -------------------- API SERVICE --------------------
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config.dart';

class ApiService {
  Future<bool> updateFcmToken(int userId, String token) async {
    final url = '${AppConfig.baseUrl}/user/update-fcm-token';
    print(
      '🌍 POST verso $url con body: {"UserId": $userId, "FcmToken": $token}',
    );
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'slowKey': AppConfig.slowKey,
        },
        body: jsonEncode({'UserId': userId, 'FcmToken': token}),
      );
      print('📡 Risposta backend: ${response.statusCode} - ${response.body}');
      return response.statusCode == 200;
    } catch (e) {
      print('🚨 Errore HTTP: $e');
      return false;
    }
  }


  Future<List<dynamic>> getNotifications(int userId) async {
    final url = '${AppConfig.baseUrl}/notification/$userId';
    print('🌍 GET verso $url');

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'slowKey': AppConfig.slowKey,
        },
      );

      print('📡 Risposta backend: ${response.statusCode}');
      print('📦 Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return jsonResponse['notifications'] ?? [];
      } else {
        throw Exception('Errore HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('🚨 Errore nel recupero notifiche: $e');
      rethrow;
    }
  }

  Future<bool> deleteNotification(int notificationId) async {
    final url = '${AppConfig.baseUrl}/notification/$notificationId';
    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'slowKey': AppConfig.slowKey,
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Errore cancellazione notifica: $e');
      return false;
    }
  }

  Future<bool> notifyTrainerByClient(
    int clientId,
    String title,
    String bodyText,
    Map<String, dynamic> appointmentData,
  ) async {
    final url = '${AppConfig.baseUrl}/notification/client-to-trainer';
    final body = jsonEncode({
      "ClientId": clientId,
      "Title": title,
      "Body": bodyText,
      "Data": appointmentData,
    });

    print("🚀 Invio richiesta POST a: $url");
    print("📦 Body: $body");

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'slowKey': AppConfig.slowKey,
        },
        body: body,
      );

      print("📡 Risposta backend:");
      print("➡️ Status code: ${response.statusCode}");
      print("➡️ Body: ${response.body}");

      if (response.statusCode == 200) {
        print("✅ Notifica inviata correttamente al trainer");
        return true;
      } else {
        print(
          "❌ Errore dal backend (${response.statusCode}): ${response.body}",
        );
        return false;
      }
    } catch (e, stacktrace) {
      print("🚨 Eccezione HTTP: $e");
      print("🧩 Stacktrace: $stacktrace");
      return false;
    }
  }
}
