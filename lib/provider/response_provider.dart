import 'dart:convert';
import 'package:flutter_riverpod/legacy.dart';
import 'package:slowFit_client/config.dart';
import 'package:slowFit_client/service/api_client.dart';
import 'package:slowFit_client/service/app_messenger.dart';

import '../model/response_model.dart';

final responseQuizProvider =
StateNotifierProvider<ResponseQuizNotifier, List<ResponseQuiz>>(
      (ref) => ResponseQuizNotifier(),
);

class ResponseQuizNotifier extends StateNotifier<List<ResponseQuiz>> {
  ResponseQuizNotifier() : super([]);

  /// Invia la lista di risposte al backend
  Future<bool> submitResponses(List<ResponseQuiz> responses) async {
    // Convertiamo la lista di oggetti in JSON
    final List<Map<String, dynamic>> jsonList =
        responses.map((r) => r.toJson()).toList();

    try {
      await ApiClient.post(
        '${AppConfig.baseUrl}/response',
        body: jsonEncode(jsonList),
      );
      return true;
    } on ApiException catch (e) {
      showAppError('Invio risposte fallito: ${e.message}');
      return false;
    }
  }

  /// Opzionale: salva le risposte anche localmente nello stato Riverpod
  void setResponses(List<ResponseQuiz> responses) {
    state = responses;
  }
}

