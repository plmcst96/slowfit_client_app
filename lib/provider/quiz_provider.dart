import 'dart:convert';

import 'package:flutter_riverpod/legacy.dart';
import 'package:slowFit_client/config.dart';
import 'package:slowFit_client/model/quiz_model.dart';
import 'package:http/http.dart' as http;

class QuizSingleNotifier extends StateNotifier<Quiz?> {
  QuizSingleNotifier() : super(null);

  Future<void> getSingleQuiz(int quizId) async {
    final url = Uri.parse('${AppConfig.baseUrl}/quiz/$quizId');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'slowKey': '${AppConfig.slowKey}',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        state = Quiz.fromJson(data);
        print(data.toString());
      } else {
        state = null;
      }
    } catch (e) {
      print('Errore: $e');
      state = null;
    }
  }
}

final quizSingleProvider = StateNotifierProvider<QuizSingleNotifier, Quiz?>(
      (ref) => QuizSingleNotifier(),
);

class QuizNotifier extends StateNotifier<List<Quiz>> {
  QuizNotifier() : super([]);

  Future<void> getAllQuizzesType(String type, {bool includeBoth = false}) async {
    final url = Uri.parse('${AppConfig.baseUrl}/quiz?type=$type');
    print(type);

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'slowKey': '${AppConfig.slowKey}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        var quizzes = data.map((json) => Quiz.fromJson(json)).toList();

        if (includeBoth) {
          // Carica anche le domande con type == "Both"
          final bothUrl = Uri.parse('${AppConfig.baseUrl}/quiz?type=Both');
          final bothResponse = await http.get(
            bothUrl,
            headers: {
              'Content-Type': 'application/json',
              'slowKey': '${AppConfig.slowKey}',
            },
          );
          if (bothResponse.statusCode == 200) {
            final List<dynamic> bothData = json.decode(bothResponse.body);
            quizzes.addAll(bothData.map((json) => Quiz.fromJson(json)).toList());
          }
        }

        // ❗ Rimuovi la prima domanda già caricata (es. quizId == 3)
        quizzes.removeWhere((quiz) => quiz.quizId == 3 || quiz.questionId == 1);

        state = quizzes;
      } else {
        state = [];
      }
    } catch (e) {
      print('Errore: $e');
      state = [];
    }
  }
}


final quizProvider = StateNotifierProvider<QuizNotifier, List<Quiz>>(
      (ref) => QuizNotifier(),
);