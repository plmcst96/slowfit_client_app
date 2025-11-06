import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:http/http.dart' as http;

import '../config.dart';
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
    final url = Uri.parse('${AppConfig.baseUrl}/typeNutrition');
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
        print(data.length);
        state = data.map((json) => TypeNutrition.fromJson(json)).toList();
      } else {
        print('⚠️ Failed with status: ${response.statusCode}');
        print('⚠️ Response body: ${response.body}');
        throw Exception('Failed to fetch nutritions');
      }
    } catch (e) {
      print('Error fetching type nutritions: $e');
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
      final url = Uri.parse('${AppConfig.baseUrl}/typeNutrition/$id');
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'slowKey': '${AppConfig.slowKey}'
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final typeNutrition = TypeNutrition.fromJson(data);
        state = AsyncValue.data(typeNutrition);
      } else if (response.statusCode == 404) {
        state = const AsyncValue.data(null);
      } else {
        throw Exception(
            'Failed to load type nutrition: ${response.statusCode}');
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
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
    final url = Uri.parse('${AppConfig.baseUrl}/nutrition/$id');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'slowKey': '${AppConfig.slowKey}'
        },
      );

      if (response.statusCode == 200) {
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
      } else {
        print('⚠️ Errore: ${response.statusCode}');
        state = null;
      }
    } catch (e) {
      print('❌ Errore fetchNutritionById: $e');
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

    final url = Uri.parse('${AppConfig.baseUrl}/nutrition/byUser/$userId');

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
        print(data);

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
      } else if (response.statusCode == 404) {
        state = const AsyncValue.data([]);
      } else {
        throw Exception(
            'Errore nel caricamento: ${response.statusCode} ${response.body}');
      }
    } catch (e, st) {
      print('❌ Errore fetchNutritionByUser: $e');
      state = AsyncValue.error(e, st);
    }
  }
}

final dailyNutritionProvider = FutureProvider.family<DailyNutrition?, (int userId, int dayId)>((ref, params) async {
  final (userId, dayId) = params;
  final url = Uri.parse('${AppConfig.baseUrl}/nutrition/byUser/$userId/day/$dayId');

  try {
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'slowKey': AppConfig.slowKey,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print(data);
      return DailyNutrition.fromJson(data);
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Errore ${response.statusCode}: ${response.body}');
    }
  } catch (e) {
    throw Exception('Errore nel caricamento del piano nutrizionale giornaliero: $e');
  }
});




