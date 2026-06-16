import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config.dart';
import '../service/api_client.dart';
import '../service/app_messenger.dart';
import '../model/meal_model.dart';

final mealEatenProvider =
StateNotifierProvider<MealEatenNotifier, Set<int>>((ref) {
  return MealEatenNotifier()..loadEatenMeals();
});

class MealEatenNotifier extends StateNotifier<Set<int>> {
  MealEatenNotifier() : super({});

  /// Carica i pasti mangiati da SharedPreferences
  Future<void> loadEatenMeals() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedList = prefs.getStringList('eatenMeals') ?? [];
      final parsed = <int>{};
      for (var s in savedList) {
        final v = int.tryParse(s);
        if (v != null) parsed.add(v);
      }
      state = parsed;
      debugPrint('[MealEatenNotifier] loaded ${state.length} eaten meals: $state');
    } catch (e) {
      debugPrint('[MealEatenNotifier] load error: $e');
      state = {};
    }
  }

  /// Segna o desegna un pasto come mangiato
  /// Aggiorna lo state SINCRONAMENTE e poi salva (no await che ritarda l'UI).
  Future<void> toggleMeal(int mealId) async {
    if (mealId <= 0) {
      debugPrint('[MealEatenNotifier] invalid mealId: $mealId');
      return;
    }

    final newState = Set<int>.from(state);
    if (newState.contains(mealId)) {
      newState.remove(mealId);
      debugPrint('[MealEatenNotifier] removing $mealId');
    } else {
      newState.add(mealId);
      debugPrint('[MealEatenNotifier] adding $mealId');
    }

    // Aggiorna subito lo stato così la UI si ricostruisce immediatamente
    state = newState;

    // salva in background (non bloccare l'aggiornamento UI)
    SharedPreferences.getInstance().then((prefs) {
      prefs.setStringList('eatenMeals', state.map((e) => e.toString()).toList())
          .then((ok) => debugPrint('[MealEatenNotifier] saved eatenMeals: ${state.toList()}'))
          .catchError((e) => debugPrint('[MealEatenNotifier] save error: $e'));
    }).catchError((e) {
      debugPrint('[MealEatenNotifier] prefs get error: $e');
    });
  }

  Future<void> clearAll() async {
    state = {};
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('eatenMeals');
      debugPrint('[MealEatenNotifier] cleared eatenMeals');
    } catch (e) {
      debugPrint('[MealEatenNotifier] clear error: $e');
    }
  }}


final categoryByIdProvider =
FutureProvider.family<CategoryOfDay?, int>((ref, categoryId) async {
  try {
    final response =
        await ApiClient.get('${AppConfig.baseUrl}/category/$categoryId');
    final data = json.decode(response.body);
    return CategoryOfDay.fromJson(data);
  } on ApiException catch (e) {
    showAppError('Categoria: ${e.message}');
    return null;
  }
});

final mealsByCategoryProvider =
    FutureProvider.family<List<Meal>, int>((ref, categoryId) async {
  try {
    final response = await ApiClient.get(
      '${AppConfig.baseUrl}/meal/byCategory/$categoryId',
    );
    final List<dynamic> data = json.decode(response.body);
    return data.map((e) => Meal.fromJson(e)).toList();
  } on ApiException catch (e) {
    showAppError('Pasti: ${e.message}');
    return [];
  }
});

final categoryByIdProviders =
    FutureProvider.family<CategoryOfDay?, int>((ref, categoryId) async {
  try {
    final response =
        await ApiClient.get('${AppConfig.baseUrl}/category/$categoryId');
    final data = json.decode(response.body);
    return CategoryOfDay.fromJson(data);
  } on ApiException catch (e) {
    showAppError('Categoria: ${e.message}');
    return null;
  }
});


class MealState extends StateNotifier<List<Meal>> {
  final Ref ref;

  MealState(this.ref) : super([]);

  Future<void> getMeals() async {
    try {
      final response = await ApiClient.get('${AppConfig.baseUrl}/meal');
      final List<dynamic> data = json.decode(response.body);
      state = data.map((e) => Meal.fromJson(e)).toList();
    } on ApiException catch (e) {
      showAppError('Pasti: ${e.message}');
      state = [];
    }
  }
}


final mealProvider = StateNotifierProvider<MealState, List<Meal>>((ref) {
  return MealState(ref);
});

/// Stato possibile per il caricamento dei dettagli di un Meal
class MealDetailState {
  final MealDetail? meal;
  final bool isLoading;
  final String? error;

  MealDetailState({
    this.meal,
    this.isLoading = false,
    this.error,
  });

  MealDetailState copyWith({
    MealDetail? meal,
    bool? isLoading,
    String? error,
  }) {
    return MealDetailState(
      meal: meal ?? this.meal,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// 📦 Notifier: gestisce il recupero del dettaglio del Meal
class MealDetailNotifier extends StateNotifier<MealDetailState> {
  MealDetailNotifier() : super(MealDetailState());

  /// 🔥 Recupera i dettagli di un singolo meal con ingredienti
  Future<void> fetchMealDetail(int mealId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await ApiClient.get(
        '${AppConfig.baseUrl}/meal/$mealId/withIngredients',
      );
      final data = json.decode(response.body);
      state = state.copyWith(meal: MealDetail.fromJson(data), isLoading: false);
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.statusCode == 404
            ? "Pasto non trovato con ID: $mealId"
            : e.message,
      );
    }
  }

  Future<void> updateMeal(MealDetail meal) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await ApiClient.put(
        '${AppConfig.baseUrl}/meal/${meal.mealId}',
        body: jsonEncode(meal.toJson()), // ✅ invia i dati aggiornati
      );
      // ✅ Ricarica i dettagli aggiornati dal server
      await fetchMealDetail(meal.mealId);
      state = state.copyWith(isLoading: false);
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.statusCode == 404
            ? "Pasto con ID ${meal.mealId} non trovato"
            : "Errore durante l'aggiornamento: ${e.message}",
      );
    }
  }

  Future<void> createMeal(MealDetail meal) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await ApiClient.post(
        '${AppConfig.baseUrl}/meal',
        body: jsonEncode(meal.toJson()), // ✅ invia i dati aggiornati
      );
      // ✅ Ricarica i dettagli aggiornati dal server
      await fetchMealDetail(meal.mealId);
      state = state.copyWith(isLoading: false);
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.statusCode == 404
            ? "Pasto non salvato"
            : "Errore durante l'aggiunta: ${e.message}",
      );
    }
  }
}

/// 🪄 Provider globale
final mealDetailProvider =
    StateNotifierProvider<MealDetailNotifier, MealDetailState>(
  (ref) => MealDetailNotifier(),
);

// --- Authoring pasti/diete PT (importato da slowfit) ---

class SelectedMealsNotifier extends StateNotifier<List<Meal>> {
  SelectedMealsNotifier() : super([]);

  void addMeal(Meal meal) {
    state = [...state, meal];
  }

  void removeMeal(Meal meal) {
    state = state.where((m) => m != meal).toList();
  }

  void updateMeals(List<Meal> updatedMeals) {
    state = updatedMeals;
  }

  void clear() {
    state = [];
  }

  void toggleMeal(Meal meal) {
    final exists =
        state.any((m) => m.mealId == meal.mealId && m.dayId == meal.dayId);

    if (exists) {
      state = state
          .where((m) => !(m.mealId == meal.mealId && m.dayId == meal.dayId))
          .toList();
    } else {
      state = [...state, meal];
    }
  }
}

final selectedMealsProvider =
    StateNotifierProvider<SelectedMealsNotifier, List<Meal>>(
        (ref) => SelectedMealsNotifier());

class CategoryState extends StateNotifier<List<CategoryOfDay>> {
  final Ref ref;

  CategoryState(this.ref) : super([]);

  Future<void> getCategoryOfDay() async {
    final url = '${AppConfig.baseUrl}/category';

    try {
      final response = await ApiClient.get(url);
      final data = ApiClient.decodeList(response);
      state = data.map((e) => CategoryOfDay.fromJson(e)).toList();
    } on ApiException catch (e) {
      showAppError(e.message);
      state = [];
    } catch (e) {
      showAppError('Si è verificato un errore. Riprova.');
      state = [];
    }
  }
}

final categoryProvider =
    StateNotifierProvider<CategoryState, List<CategoryOfDay>>((ref) {
  return CategoryState(ref);
});

class DayWeekState extends StateNotifier<List<DayWeek>> {
  final Ref ref;

  DayWeekState(this.ref) : super([]);

  Future<void> getDayWeek() async {
    final url = '${AppConfig.baseUrl}/dayWeek';

    try {
      final response = await ApiClient.get(url);
      final data = ApiClient.decodeList(response);
      state = data.map((e) => DayWeek.fromJson(e)).toList();
    } on ApiException catch (e) {
      showAppError(e.message);
      state = [];
    } catch (e) {
      showAppError('Si è verificato un errore. Riprova.');
      state = [];
    }
  }
}

final dayWeekProvider =
    StateNotifierProvider<DayWeekState, List<DayWeek>>((ref) {
  return DayWeekState(ref);
});

final dayWeekByIdProvider =
    FutureProvider.family<DayWeek?, int>((ref, id) async {
  final url = '${AppConfig.baseUrl}/dayWeek/$id';
  try {
    final response = await ApiClient.get(url);
    final data = ApiClient.decodeMap(response);
    return data == null ? null : DayWeek.fromJson(data);
  } on ApiException catch (e) {
    if (e.statusCode != 404) showAppError(e.message);
    return null;
  } catch (e) {
    showAppError('Si è verificato un errore. Riprova.');
    return null;
  }
});
