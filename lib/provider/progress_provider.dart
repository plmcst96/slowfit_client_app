import 'dart:convert';

import 'package:flutter_riverpod/legacy.dart';
import 'package:riverpod/src/framework.dart';
import 'package:slowFit_client/config.dart';
import 'package:http/http.dart' as http;
import 'package:slowFit_client/model/progress_model.dart';

class SingleProgressTrainingState extends StateNotifier<ProgressTraining?> {
  SingleProgressTrainingState(Ref ref) : super(null);

  Future<void> getSingleProgress(int progressId) async {
    final url = Uri.parse('${AppConfig.baseUrl}/progress/$progressId');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'slowKey': '${AppConfig.slowKey}',
        },
      );

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        state = ProgressTraining.fromJson(data);
      } else {
        state = null;
      }
    } catch (e) {
      print("Errore: $e");
      state = null;
    }
  }

  Future<void> postProgressTraining(ProgressTraining progress) async {
    final url = Uri.parse('${AppConfig.baseUrl}/progress');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'slowKey': AppConfig.slowKey,
        },
        body: json.encode(progress.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        if (data.containsKey("progress")) {
          state = ProgressTraining.fromJson(data["progress"]);
        } else {
          // fallback
          state = null;
        }
      } else {
        print("Errore POST: ${response.statusCode} - ${response.body}");
        state = null;
      }
    } catch (e) {
      print("Errore: $e");
      state = null;
    }
  }
}

final progressTrainingProvider = StateNotifierProvider<SingleProgressTrainingState, ProgressTraining?>((ref){
  return SingleProgressTrainingState(ref);
});
