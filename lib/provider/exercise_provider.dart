import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:http/http.dart' as http;

import '../config.dart';
import '../model/exercise_model.dart';
import '../model/training_model.dart';

class TypeExercise {
  late int typeId;
  late String typeName;

  TypeExercise({required this.typeId, required this.typeName});

  factory TypeExercise.fromJson(Map<String, dynamic> json) {
    return TypeExercise(
      typeId: json['typeId'],
      typeName: json['typeName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'typeId': typeId, 'typeName': typeName};
  }
}

class TypeExerciseState extends StateNotifier<List<TypeExercise>> {
  final Ref ref;
  TypeExerciseState(this.ref) : super([]);

  Future<void> getTypeExercise() async {
    final url = Uri.parse('${AppConfig.baseUrl}/type');

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

        state = data
            .map((item) => TypeExercise.fromJson(item))
            .where((type) =>
                type.typeId != 11 && type.typeId != 12 && type.typeId != 13)
            .toList();
      } else {
        state = [];
      }
    } catch (e) {
      print("Errore: $e");
      state = [];
    }
  }
}

final typeExerciseProvider =
    StateNotifierProvider<TypeExerciseState, List<TypeExercise>>(
        (ref) => TypeExerciseState(ref));

class TypeSingleTraining extends StateNotifier<Map<int, TypeExercise>> {
  TypeSingleTraining() : super({});

  Future<TypeExercise?> getSingleType(int typeId) async {
    final url = Uri.parse('${AppConfig.baseUrl}/type/$typeId');

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
        final type = TypeExercise.fromJson(data);

        // aggiorna lo stato con il nuovo type
        state = {
          ...state,
          typeId: type,
        };

        return type; // 👈 ritorna il singolo oggetto
      } else {
        print("Errore HTTP: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Errore durante il fetch del type $typeId: $e");
      return null;
    }
  }

}

final typeSingleProvider =
    StateNotifierProvider<TypeSingleTraining, Map<int, TypeExercise>>(
        (ref) => TypeSingleTraining());

//provider per il luogo di esercizio
class LocationTraining {
  late int locationId;
  late String locationString;

  LocationTraining({required this.locationId, required this.locationString});

  factory LocationTraining.fromJson(Map<String, dynamic> json) {
    return LocationTraining(
      locationId: json['locationId'],
      locationString: json['locationString'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'locationId': locationId, 'locationString': locationString};
  }
}

class LocationExerciseState extends StateNotifier<List<LocationTraining>> {
  final Ref ref;
  LocationExerciseState(this.ref) : super([]);

  Future<void> getLocationExercise() async {
    final url = Uri.parse('${AppConfig.baseUrl}/location');

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

        state = data.map((item) => LocationTraining.fromJson(item)).toList();
      } else {
        state = [];
      }
    } catch (e) {
      print("Errore: $e");
      state = [];
    }
  }
}

final locationExerciseProvider =
    StateNotifierProvider<LocationExerciseState, List<LocationTraining>>(
        (ref) => LocationExerciseState(ref));

class ExerciseState extends StateNotifier<List<Exercise>> {
  final Ref ref;

  ExerciseState(this.ref) : super([]);

  // Modifica la funzione per restituire una lista di esercizi
  Future<List<Exercise>> getExerciseGpt(int trainingId) async {
    final url = Uri.parse(
        '${AppConfig.baseUrl}/api/exercise/exerciseByTraining/$trainingId');

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
        // Restituisci una lista di esercizi
        return data.map((item) => Exercise.fromJson(item)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print("Errore: $e");
      return [];
    }
  }

  Future<void> getExercise(int trainingId) async {
    final url = Uri.parse(
        '${AppConfig.baseUrl}/api/exercise/exerciseByTraining/$trainingId');
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
        state = data.map((item) => Exercise.fromJson(item)).toList();
      } else {
        state = [];
      }
    } catch (e) {
      print("Errore: $e");
      state = [];
    }
  }

  Future<void> addExercise(Exercise exercise) async {
    final url = Uri.parse('${AppConfig.baseUrl}/api/exercise');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'slowKey': '${AppConfig.slowKey}'
        },
        body: json.encode(exercise.toJson()),
      );

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);

        final newExercise = Exercise.fromJson(decodedResponse);

        state = [...state, newExercise];

        ref
            .read(exerciseProvider.notifier)
            .getExercise(exercise.typeTrainingId);
      } else {
        throw Exception('Failed to add exercise');
      }
    } catch (e) {
      print('Error adding exercise: $e');
    }
  }

  Future<void> updateExercise(Exercise exercise) async {
    final url =
        Uri.parse('${AppConfig.baseUrl}/api/exercise/${exercise.exerciseId}');

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'slowKey': '${AppConfig.slowKey}'
        },
        body: json.encode(exercise.toJson()),
      );

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        print("Messaggio: ${decodedResponse['message']}");

        // Aggiorna lo stato manualmente con i dati già in tuo possesso
        state = state.map((ex) {
          return ex.exerciseId == exercise.exerciseId ? exercise : ex;
        }).toList();

        // Oppure, se vuoi ricaricare dal backend:
        await ref
            .read(exerciseProvider.notifier)
            .getExercise(exercise.typeTrainingId);
      } else {
        throw Exception('Failed to update exercise');
      }
    } catch (e) {
      print('Error updating exercise: $e');
    }
  }
}

final exerciseProvider = StateNotifierProvider<ExerciseState, List<Exercise>>(
    (ref) => ExerciseState(ref));

class ExerciseSingleState extends StateNotifier<Exercise?> {
  ExerciseSingleState() : super(null);

  Future<void> getSingleExercise(int exerciseId) async {
    final url = Uri.parse('${AppConfig.baseUrl}/api/exercise/$exerciseId');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'slowKey': '${AppConfig.slowKey}'
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        state = Exercise.fromJson(data);
      } else {
        state = null;
      }
    } catch (e) {
      print('Errore: $e');
      state = null;
    }
  }
}

final exerciseSingleProvider =
    StateNotifierProvider<ExerciseSingleState, Exercise?>(
        (ref) => ExerciseSingleState());

class ExerciseSingleMapState extends StateNotifier<Map<int, Exercise>> {
  ExerciseSingleMapState() : super({});

  Future<void> getSingleExerciseMap(int exerciseId) async {
    final url = Uri.parse('${AppConfig.baseUrl}/api/exercise/$exerciseId');

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
        final exercise = Exercise.fromJson(data);

        state = {
          ...state,
          exerciseId: exercise,
        };
      }
    } catch (e) {
      print("Errore: $e");
    }
  }
}

final exerciseSingleMapProvider =
    StateNotifierProvider<ExerciseSingleMapState, Map<int, Exercise>>(
        (ref) => ExerciseSingleMapState());

class ExerciseRestState extends StateNotifier<List<Exercise>> {
  final Ref ref;

  ExerciseRestState(this.ref) : super([]);

  Future<void> getExerciseRest() async {
    final url =
        Uri.parse('${AppConfig.baseUrl}/api/exercise/exerciseByTraining/15');
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
        state = data.map((item) => Exercise.fromJson(item)).toList();
      } else {
        state = [];
      }
    } catch (e) {
      print("Errore: $e");
      state = [];
    }
  }

  Future<void> getExerciseStr() async {
    final url =
        Uri.parse('${AppConfig.baseUrl}/api/exercise/exerciseByTraining/14');
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
        state = data.map((item) => Exercise.fromJson(item)).toList();
      } else {
        state = [];
      }
    } catch (e) {
      print("Errore: $e");
      state = [];
    }
  }
}

final exerciseRestProvider =
    StateNotifierProvider<ExerciseRestState, List<Exercise>>(
        (ref) => ExerciseRestState(ref));

class ExerciseStrState extends StateNotifier<List<Exercise>> {
  final Ref ref;

  ExerciseStrState(this.ref) : super([]);

  Future<void> getExerciseStr() async {
    final url =
        Uri.parse('${AppConfig.baseUrl}/api/exercise/exerciseByTraining/14');
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
        state = data.map((item) => Exercise.fromJson(item)).toList();
      } else {
        state = [];
      }
    } catch (e) {
      print("Errore: $e");
      state = [];
    }
  }
}

final exerciseStrProvider =
    StateNotifierProvider<ExerciseStrState, List<Exercise>>(
        (ref) => ExerciseStrState(ref));

class DetailExercisesState {
  final List<DetailExerciseRequest> exRest;
  final List<DetailExerciseRequest> ex;
  final List<DetailExerciseRequest> exStr;

  DetailExercisesState({
    this.exRest = const [],
    this.ex = const [],
    this.exStr = const [],
  });

  DetailExercisesState copyWith({
    List<DetailExerciseRequest>? exRest,
    List<DetailExerciseRequest>? ex,
    List<DetailExerciseRequest>? exStr,
  }) {
    return DetailExercisesState(
      exRest: exRest ?? this.exRest,
      ex: ex ?? this.ex,
      exStr: exStr ?? this.exStr,
    );
  }
}

class DetailExercisesNotifier extends StateNotifier<DetailExercisesState> {
  DetailExercisesNotifier() : super(DetailExercisesState());

  void updateExercises({
    required List<DetailExerciseRequest> exRest,
    required List<DetailExerciseRequest> ex,
    required List<DetailExerciseRequest> exStr,
  }) {
    state = state.copyWith(
      exRest: exRest,
      ex: ex,
      exStr: exStr,
    );
  }
}

final detailExercisesProvider =
    StateNotifierProvider<DetailExercisesNotifier, DetailExercisesState>((ref) {
  return DetailExercisesNotifier();
});
