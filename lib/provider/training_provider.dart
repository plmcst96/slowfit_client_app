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
