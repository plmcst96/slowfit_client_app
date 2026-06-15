import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:slowFit_client/config.dart';
import 'package:slowFit_client/service/api_client.dart';
import 'package:slowFit_client/service/app_messenger.dart';
import 'package:slowFit_client/model/progress_model.dart';

class SingleProgressTrainingState extends StateNotifier<ProgressTraining?> {
  SingleProgressTrainingState(Ref ref) : super(null);

  Future<void> getSingleProgress(int progressId) async {
    try {
      final response =
          await ApiClient.get('${AppConfig.baseUrl}/progress/$progressId');
      final dynamic data = json.decode(response.body);
      state = ProgressTraining.fromJson(data);
    } on ApiException catch (e) {
      showAppError('Progressi: ${e.message}');
      state = null;
    }
  }

  Future<bool> postProgressTraining(ProgressTraining progress) async {
    try {
      final response = await ApiClient.post(
        '${AppConfig.baseUrl}/progress',
        body: json.encode(progress.toJson()),
      );
      final Map<String, dynamic> data = json.decode(response.body);
      if (data.containsKey("progress")) {
        state = ProgressTraining.fromJson(data["progress"]);
      }
      return true; // ✅ SUCCESSO
    } on ApiException catch (e) {
      showAppError('Salvataggio progressi fallito: ${e.message}');
      return false; // ❌ FALLIMENTO
    }
  }
}

final progressTrainingProvider = StateNotifierProvider<SingleProgressTrainingState, ProgressTraining?>((ref){
  return SingleProgressTrainingState(ref);
});
