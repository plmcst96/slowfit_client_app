// -------------------- API SERVICE --------------------
import 'dart:convert';

import '../config.dart';
import 'api_client.dart';

class ApiService {
  Future<bool> updateFcmToken(int userId, String token) async {
    try {
      await ApiClient.post(
        '${AppConfig.baseUrl}/user/update-fcm-token',
        body: jsonEncode({'UserId': userId, 'FcmToken': token}),
      );
      return true;
    } on ApiException catch (e) {
      // Operazione in background: logghiamo soltanto, niente SnackBar.
      print('🚨 updateFcmToken: ${e.message}');
      return false;
    }
  }

  Future<List<dynamic>> getNotifications(int userId) async {
    // Propaga eventuali ApiException: fetchNotifications le gestisce.
    final response =
        await ApiClient.get('${AppConfig.baseUrl}/notification/$userId');
    final jsonResponse = json.decode(response.body);
    return jsonResponse['notifications'] ?? [];
  }

  Future<bool> deleteNotification(int notificationId) async {
    try {
      await ApiClient.delete(
        '${AppConfig.baseUrl}/notification/$notificationId',
      );
      return true;
    } on ApiException catch (e) {
      print('🚨 deleteNotification: ${e.message}');
      return false;
    }
  }

  Future<bool> notifyTrainerByClient(
    int clientId,
    String title,
    String bodyText,
    Map<String, dynamic> appointmentData,
  ) async {
    try {
      await ApiClient.post(
        '${AppConfig.baseUrl}/notification/client-to-trainer',
        body: jsonEncode({
          "ClientId": clientId,
          "Title": title,
          "Body": bodyText,
          "Data": appointmentData,
        }),
      );
      return true;
    } on ApiException catch (e) {
      print('🚨 notifyTrainerByClient: ${e.message}');
      return false;
    }
  }
}
