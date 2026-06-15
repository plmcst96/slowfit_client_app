import 'dart:convert';

import 'package:flutter_riverpod/legacy.dart';
import 'package:slowFit_client/config.dart';
import 'package:slowFit_client/model/quiz_model.dart';

import '../service/api_client.dart';
import '../service/app_messenger.dart';

class QuizSingleNotifier extends StateNotifier<Quiz?> {
  QuizSingleNotifier() : super(null);

  /// Restituisce `true` se il caricamento è andato a buon fine.
  Future<bool> getSingleQuiz(int quizId) async {
    try {
      final response = await ApiClient.get('${AppConfig.baseUrl}/quiz/$quizId');
      final Map<String, dynamic> data = json.decode(response.body);
      state = Quiz.fromJson(data);
      return true;
    } on ApiException catch (e) {
      showAppError('Quiz non disponibile: ${e.message}');
      state = null;
      return false;
    }
  }
}

final quizSingleProvider = StateNotifierProvider<QuizSingleNotifier, Quiz?>(
  (ref) => QuizSingleNotifier(),
);

class QuizNotifier extends StateNotifier<List<Quiz>> {
  QuizNotifier() : super([]);

  /// Restituisce `true` se il caricamento è andato a buon fine.
  Future<bool> getAllQuizzesType(String type, {bool includeBoth = false}) async {
    try {
      final response =
          await ApiClient.get('${AppConfig.baseUrl}/quiz?type=$type');
      final List<dynamic> data = json.decode(response.body);
      var quizzes = data.map((json) => Quiz.fromJson(json)).toList();

      if (includeBoth) {
        // Carica anche le domande con type == "Both"
        final bothResponse =
            await ApiClient.get('${AppConfig.baseUrl}/quiz?type=Both');
        final List<dynamic> bothData = json.decode(bothResponse.body);
        quizzes.addAll(bothData.map((json) => Quiz.fromJson(json)).toList());
      }

      // ❗ Rimuovi la prima domanda già caricata (es. quizId == 3)
      quizzes.removeWhere((quiz) => quiz.quizId == 3 || quiz.questionId == 1);

      state = quizzes;
      return true;
    } on ApiException catch (e) {
      showAppError('Quiz non disponibile: ${e.message}');
      state = [];
      return false;
    }
  }
}

final quizProvider = StateNotifierProvider<QuizNotifier, List<Quiz>>(
  (ref) => QuizNotifier(),
);
