import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../config.dart';
import '../service/api_client.dart';
import '../service/app_messenger.dart';
import '../model/meal_model.dart';
import '../model/nutrition_model.dart';

class TypeNutrition {
  late int typeNutritionId;
  late String typeNutritionName;

  TypeNutrition(
      {required this.typeNutritionId, required this.typeNutritionName});

  factory TypeNutrition.fromJson(Map<String, dynamic> json) {
    return TypeNutrition(
        typeNutritionId: json['typeNutritionId'],
        typeNutritionName: json['typeNutritionName']);
  }

  Map<String, dynamic> toJson() {
    return {
      'typeNutritionId': typeNutritionId,
      'typeNutritionName': typeNutritionName
    };
  }
}

///Provider per gestire il tipo di nuitrizione
final typeNutrutionProvider =
    StateNotifierProvider<TypeNutritionNotifier, List<TypeNutrition>>(
        (ref) => TypeNutritionNotifier());

class TypeNutritionNotifier extends StateNotifier<List<TypeNutrition>> {
  TypeNutritionNotifier() : super([]);

  Future<void> fetchType() async {
    try {
      final response =
          await ApiClient.get('${AppConfig.baseUrl}/typeNutrition');
      final List<dynamic> data = json.decode(response.body);
      state = data.map((json) => TypeNutrition.fromJson(json)).toList();
    } on ApiException catch (e) {
      showAppError('Tipi nutrizione: ${e.message}');
      state = [];
    }
  }
}

/// StateNotifier per gestire il caricamento di un singolo tipo nutrizionale
class TypeNutritionByIdNotifier
    extends StateNotifier<AsyncValue<TypeNutrition?>> {
  TypeNutritionByIdNotifier() : super(const AsyncValue.data(null));

  Future<void> fetchTypeById(int id) async {
    state = const AsyncValue.loading();
    try {
      final response =
          await ApiClient.get('${AppConfig.baseUrl}/typeNutrition/$id');
      final data = json.decode(response.body);
      state = AsyncValue.data(TypeNutrition.fromJson(data));
    } on ApiException catch (e, st) {
      // 404 = nessun tipo per questo id → dato nullo, non un errore.
      if (e.statusCode == 404) {
        state = const AsyncValue.data(null);
      } else {
        state = AsyncValue.error(e, st);
      }
    }
  }
}

/// Provider family: riceve un int (id) e restituisce il TypeNutrition corrispondente
final typeNutritionByIdFamilyProvider = StateNotifierProvider.family<
    TypeNutritionByIdNotifier, AsyncValue<TypeNutrition?>, int>(
  (ref, id) => TypeNutritionByIdNotifier()..fetchTypeById(id),
);

final nutritionByIdProvider =
    StateNotifierProvider<NutritionByIdNotifier, NutritionDetail?>(
        (ref) => NutritionByIdNotifier());

class NutritionByIdNotifier extends StateNotifier<NutritionDetail?> {
  NutritionByIdNotifier() : super(null);

  Future<void> fetchNutritionById(int id) async {
    try {
      final response =
          await ApiClient.get('${AppConfig.baseUrl}/nutrition/$id');
      {
        final Map<String, dynamic> data = json.decode(response.body);
        NutritionDetail nutrition = NutritionDetail.fromJson(data);

        final Map<int, Map<int, List<Meal>>> groupedMeals = {};

        for (var meal in nutrition.meals) {
          if (meal.categoryId == null || meal.dayId == null) continue;

          groupedMeals.putIfAbsent(meal.categoryId!, () => {});
          groupedMeals[meal.categoryId!]!.putIfAbsent(meal.dayId!, () => []);
          groupedMeals[meal.categoryId!]![meal.dayId!]!.add(meal);
        }

        nutrition.categories = groupedMeals.entries.map((catEntry) {
          return NutritionCategory(
            categoryId: catEntry.key,
            categoryName: "", // 🔥 verrà presa dal provider
            days: catEntry.value.entries.map((dayEntry) {
              return NutritionDay(
                dayId: dayEntry.key,
                dayName: "", // 🔥 verrà presa dal provider
                meals: dayEntry.value,
              );
            }).toList(),
          );
        }).toList();

        state = nutrition;
      }
    } on ApiException catch (e) {
      showAppError('Piano nutrizionale: ${e.message}');
      state = null;
    }
  }
}

final nutritionsByUserProvider = StateNotifierProvider.family<
    NutritionByUserNotifier, AsyncValue<List<NutritionDetail>>, int>(
      (ref, userId) => NutritionByUserNotifier()..fetchNutritionByUser(userId),
);

class NutritionByUserNotifier
    extends StateNotifier<AsyncValue<List<NutritionDetail>>> {
  NutritionByUserNotifier() : super(const AsyncValue.loading());

  Future<void> fetchNutritionByUser(int userId) async {
    state = const AsyncValue.loading();

    try {
      final response = await ApiClient.get(
        '${AppConfig.baseUrl}/nutrition/byUser/$userId',
      );

      {
        final List<dynamic> data = json.decode(response.body);

        final nutritions = data.map((json) {
          final nutrition = NutritionDetail.fromJson(json);

          /// Raggruppa i pasti per categoria e giorno (stesso schema che usi in fetchNutritionById)
          final Map<int, Map<int, List<Meal>>> groupedMeals = {};

          for (var meal in nutrition.meals) {
            if (meal.categoryId == null || meal.dayId == null) continue;

            groupedMeals.putIfAbsent(meal.categoryId!, () => {});
            groupedMeals[meal.categoryId!]!.putIfAbsent(meal.dayId!, () => []);
            groupedMeals[meal.categoryId!]![meal.dayId!]!.add(meal);
          }

          nutrition.categories = groupedMeals.entries.map((catEntry) {
            return NutritionCategory(
              categoryId: catEntry.key,
              categoryName: "",
              days: catEntry.value.entries.map((dayEntry) {
                return NutritionDay(
                  dayId: dayEntry.key,
                  dayName: "",
                  meals: dayEntry.value,
                );
              }).toList(),
            );
          }).toList();

          return nutrition;
        }).toList();

        state = AsyncValue.data(nutritions);
      }
    } on ApiException catch (e, st) {
      // 404 = utente senza piani → lista vuota, non un errore.
      if (e.statusCode == 404) {
        state = const AsyncValue.data([]);
      } else {
        state = AsyncValue.error(e, st);
      }
    }
  }
}

final dailyNutritionProvider = FutureProvider.family<DailyNutrition?, (int userId, int dayId)>((ref, params) async {
  final (userId, dayId) = params;

  try {
    final response = await ApiClient.get(
      '${AppConfig.baseUrl}/nutrition/byUser/$userId/day/$dayId',
    );
    final data = json.decode(response.body);
    return DailyNutrition.fromJson(data);
  } on ApiException catch (e) {
    // 404 = nessun piano per quel giorno → null, non un errore.
    if (e.statusCode == 404) return null;
    rethrow;
  }
});

/// Provider per gestire la lista dei piani nutrizionali
final nutritionProvider =
StateNotifierProvider<NutritionNotifier, List<Nutrition>>(
      (ref) => NutritionNotifier(),
);

class NutritionNotifier extends StateNotifier<List<Nutrition>> {
  NutritionNotifier() : super([]);

  /// GET: recupera tutti i piani nutrizionali
  Future<void> fetchNutritions() async {
    try {
      final response = await ApiClient.get('${AppConfig.baseUrl}/nutrition');
      // 204 No Content → corpo vuoto, lista vuota.
      if (response.body.isEmpty) {
        state = [];
        return;
      }
      final List<dynamic> data = json.decode(response.body);
      state = data.map((json) => Nutrition.fromJson(json)).toList();
    } on ApiException catch (e) {
      showAppError('Piani nutrizionali: ${e.message}');
      state = [];
    }
  }

  /// DELETE: elimina un piano nutrizionale
  Future<void> deleteNutrition(int nutritionId) async {
    try {
      await ApiClient.delete('${AppConfig.baseUrl}/nutrition/$nutritionId');
      state = state.where((n) => n.nutritionId != nutritionId).toList();
      await fetchNutritions();
    } on ApiException catch (e) {
      showAppError('Eliminazione piano fallita: ${e.message}');
      rethrow;
    }
  }

  // --- Authoring diete PT (importato da slowfit) ---

  Future<void> getNutritionByUser(int userId) async {
    final url = '${AppConfig.baseUrl}/nutrition/byUser/$userId';
    try {
      final response = await ApiClient.get(url);
      final data = ApiClient.decodeList(response);
      state = data.map((json) => Nutrition.fromJson(json)).toList();
    } on ApiException catch (e) {
      showAppError(e.message);
      state = [];
    } catch (e) {
      showAppError('Errore imprevisto: $e');
      state = [];
    }
  }

  Future<void> createNutrition(Nutrition nutrition) async {
    final url = '${AppConfig.baseUrl}/nutrition';
    try {
      await ApiClient.post(url, body: jsonEncode(nutrition.toJson()));
      await fetchNutritions();
    } on ApiException catch (e) {
      showAppError(e.message);
      rethrow;
    } catch (e) {
      showAppError('Errore imprevisto: $e');
      rethrow;
    }
  }

  Future<void> updateNutrition(Nutrition nutrition) async {
    if (nutrition.nutritionId == null) {
      throw Exception('NutritionId is required');
    }
    final url = '${AppConfig.baseUrl}/nutrition/${nutrition.nutritionId}';
    try {
      await ApiClient.put(url, body: jsonEncode(nutrition.toJson()));
      await fetchNutritions();
    } on ApiException catch (e) {
      showAppError(e.message);
      rethrow;
    } catch (e) {
      showAppError('Errore imprevisto: $e');
      rethrow;
    }
  }
}




