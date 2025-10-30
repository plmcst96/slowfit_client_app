import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:http/http.dart' as http;

import '../config.dart';
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
    final url = Uri.parse('${AppConfig.baseUrl}/level/$levelId');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'slowKey': AppConfig.slowKey,
        },
      );

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        final type = Level.fromJson(data);

        state = {
          ...state,
          levelId: type,
        };
      }
    } catch (e) {
      print("Errore: $e");
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
    final url = Uri.parse('${AppConfig.baseUrl}/level');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'slowKey': '${AppConfig.slowKey}'
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        state = data.map((item) => Level.fromJson(item)).toList();
      } else {
        state = [];
      }
    } catch (e) {
      print("Errore: $e");
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
    final url = Uri.parse('${AppConfig.baseUrl}/training/byUser/$userId');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'slowKey': '${AppConfig.slowKey}'
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print(data.toString());
        state =
            data.map((item) => TrainingCreateResponse.fromJson(item)).toList();
      } else {
        state = [];
      }
    } catch (e) {
      print("Errore: $e");
      state = [];
    }
  }
}

final trainingGetProvider =
    StateNotifierProvider<TrainingStateResponse, List<TrainingCreateResponse>>(
        (ref) => TrainingStateResponse(ref));
