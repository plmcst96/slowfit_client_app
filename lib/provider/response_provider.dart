import 'dart:convert';
import 'package:flutter_riverpod/legacy.dart';
import 'package:http/http.dart' as http;
import 'package:slowFit_client/config.dart';

import '../model/response_model.dart';

final responseQuizProvider =
StateNotifierProvider<ResponseQuizNotifier, List<ResponseQuiz>>(
      (ref) => ResponseQuizNotifier(),
);

class ResponseQuizNotifier extends StateNotifier<List<ResponseQuiz>> {
  ResponseQuizNotifier() : super([]);

  /// Invia la lista di risposte al backend
  Future<bool> submitResponses(List<ResponseQuiz> responses) async {
    final String baseUrl = '${AppConfig.baseUrl}/response';

    // Convertiamo la lista di oggetti in JSON
    final List<Map<String, dynamic>> jsonList =
    responses.map((r) => r.toJson()).toList();

    try {
      final http.Response apiResponse = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'slowKey': AppConfig.slowKey,
        },
        body: jsonEncode(jsonList),
      );

      if (apiResponse.statusCode == 200 || apiResponse.statusCode == 201) {
        print('✅ Risposte inviate con successo!');
        print('Server response: ${apiResponse.body}');
        return true;
      } else {
        print(
            '❌ Errore POST: ${apiResponse.statusCode} - ${apiResponse.body}');
        return false;
      }
    } catch (e) {
      print('❌ Eccezione POST: $e');
      return false;
    }
  }

  /// Opzionale: salva le risposte anche localmente nello stato Riverpod
  void setResponses(List<ResponseQuiz> responses) {
    state = responses;
  }
}

