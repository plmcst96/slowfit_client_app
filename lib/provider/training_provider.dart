import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../config.dart';
import '../service/api_client.dart';
import '../service/app_messenger.dart';
import '../model/training_model.dart';

class Level {
  late int levelId;
  late String levelString;

  Level({required this.levelId, required this.levelString});

  factory Level.fromJson(Map<String, dynamic> json) {
    return Level(
      levelId: json['levelId'],
      levelString: json['levelString'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'levelId': levelId, 'levelString': levelString};
  }
}

class LevelSingleTraining extends StateNotifier<Map<int, Level>> {
  LevelSingleTraining() : super({});

  Future<void> getSingleLevel(int levelId) async {
    try {
      final response =
          await ApiClient.get('${AppConfig.baseUrl}/level/$levelId');
      final dynamic data = json.decode(response.body);
      final type = Level.fromJson(data);
      state = {
        ...state,
        levelId: type,
      };
    } on ApiException catch (e) {
      showAppError('Livello: ${e.message}');
    }
  }
}

final levelSingleProvider =
    StateNotifierProvider<LevelSingleTraining, Map<int, Level>>(
        (ref) => LevelSingleTraining());

class LevelState extends StateNotifier<List<Level>> {
  final Ref ref;
  LevelState(this.ref) : super([]);

  Future<void> getLevel() async {
    try {
      final response = await ApiClient.get('${AppConfig.baseUrl}/level');
      final List<dynamic> data = json.decode(response.body);
      state = data.map((item) => Level.fromJson(item)).toList();
    } on ApiException catch (e) {
      showAppError('Livelli: ${e.message}');
      state = [];
    }
  }
}

final levelProvider =
    StateNotifierProvider<LevelState, List<Level>>((ref) => LevelState(ref));


class TrainingStateResponse
    extends StateNotifier<List<TrainingCreateResponse>> {
  final Ref ref;

  TrainingStateResponse(this.ref) : super([]);

  Future<void> getTrainingByUserId(int userId) async {
    try {
      final response =
          await ApiClient.get('${AppConfig.baseUrl}/training/byUser/$userId');
      final List<dynamic> data = json.decode(response.body);
      state =
          data.map((item) => TrainingCreateResponse.fromJson(item)).toList();
    } on ApiException catch (e) {
      showAppError('Allenamenti: ${e.message}');
      state = [];
    }
  }
}

final trainingGetProvider =
    StateNotifierProvider<TrainingStateResponse, List<TrainingCreateResponse>>(
        (ref) => TrainingStateResponse(ref));

// --- Authoring schede PT (importato da slowfit) ---

class TrainingState extends StateNotifier<List<TrainingRes>> {
  final Ref ref;

  TrainingState(this.ref) : super([]);

  Future<void> getTraining(int trainingId) async {
    final url = '${AppConfig.baseUrl}/training';
    try {
      final response = await ApiClient.get(url);
      final data = ApiClient.decodeList(response);
      state = data.map((item) => TrainingRes.fromJson(item)).toList();
    } on ApiException catch (e) {
      showAppError(e.message);
      state = [];
    } catch (e) {
      showAppError('Si è verificato un errore. Riprova.');
      state = [];
    }
  }

  Future<void> updateTraining(TrainingRes training) async {
    final url = '${AppConfig.baseUrl}/training/${training.trainingId}';

    try {
      await ApiClient.put(
        url,
        body: json.encode(training.toJson()),
      );

      state = state.map((ex) {
        return ex.trainingId == training.trainingId ? training : ex;
      }).toList();

      await ref.read(trainingProvider.notifier).getTraining(training.trainingId);
    } on ApiException catch (e) {
      showAppError(e.message);
    } catch (e) {
      showAppError('Si è verificato un errore. Riprova.');
    }
  }

  Future<void> deleteTraining(int trainingId) async {
    final url = '${AppConfig.baseUrl}/training/$trainingId';

    try {
      await ApiClient.delete(url);
      state = state.where((t) => t.trainingId != trainingId).toList();
    } on ApiException catch (e) {
      if (e.statusCode != 404) showAppError(e.message);
    } catch (e) {
      showAppError('Si è verificato un errore. Riprova.');
    }
  }

  Future<void> getAllTrainings() async {
    final url = '${AppConfig.baseUrl}/training';

    try {
      final response = await ApiClient.get(url);
      final data = ApiClient.decodeList(response);
      state = data.map((json) => TrainingRes.fromJson(json)).toList();
    } on ApiException catch (e) {
      showAppError(e.message);
      state = [];
    } catch (e) {
      showAppError('Si è verificato un errore. Riprova.');
      state = [];
    }
  }
}

final trainingProvider =
    StateNotifierProvider<TrainingState, List<TrainingRes>>(
        (ref) => TrainingState(ref));

class TrainingStateRe extends StateNotifier<List<TrainingCreateRequest>> {
  final Ref ref;

  TrainingStateRe(this.ref) : super([]);

  Future<void> saveTraining(TrainingCreateRequest training) async {
    final url = '${AppConfig.baseUrl}/training';

    try {
      final response = await ApiClient.post(
        url,
        body: json.encode(training.toJson()),
      );

      final decodedResponse = json.decode(response.body);
      final newTraining = TrainingCreateRequest.fromJson(decodedResponse);
      state = [...state, newTraining];
    } on ApiException catch (e) {
      showAppError(e.message);
    } catch (e) {
      showAppError('Errore nel salvataggio dell\'allenamento: $e');
    }
  }
}

final trainingAddProvider =
    StateNotifierProvider<TrainingStateRe, List<TrainingCreateRequest>>(
        (ref) => TrainingStateRe(ref));
