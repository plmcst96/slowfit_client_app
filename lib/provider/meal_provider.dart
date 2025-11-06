import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config.dart';
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
  final url = Uri.parse('${AppConfig.baseUrl}/category/$categoryId');
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
      return CategoryOfDay.fromJson(data);
    } else {
      return null;
    }
  } catch (e) {
    print("Errore fetching category: $e");
    return null;
  }
});

final mealsByCategoryProvider =
    FutureProvider.family<List<Meal>, int>((ref, categoryId) async {
  final url = Uri.parse('${AppConfig.baseUrl}/meal/byCategory/$categoryId');

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
      return data.map((e) => Meal.fromJson(e)).toList();
    } else {
      return [];
    }
  } catch (e) {
    print("Errore fetch pasti per categoria: $e");
    return [];
  }
});

final categoryByIdProviders =
    FutureProvider.family<CategoryOfDay?, int>((ref, categoryId) async {
  final url = Uri.parse('${AppConfig.baseUrl}/category/$categoryId');

  try {
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'slowKey': '${AppConfig.slowKey}',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return CategoryOfDay.fromJson(data);
    } else {
      return null;
    }
  } catch (e) {
    print("Errore fetching category: $e");
    return null;
  }
});


class MealState extends StateNotifier<List<Meal>> {
  final Ref ref;

  MealState(this.ref) : super([]);

  Future<void> getMeals() async {
    final url = Uri.parse('${AppConfig.baseUrl}/meal');

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
        state = data.map((e) => Meal.fromJson(e)).toList();
      } else {
        state = [];
      }
    } catch (e) {
      print("Errore: $e");
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
    final url = Uri.parse('${AppConfig.baseUrl}/meal/$mealId/withIngredients');

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
        final meal = MealDetail.fromJson(data);

        state = state.copyWith(meal: meal, isLoading: false);
        print(state.meal?.ingredients.length);
      } else if (response.statusCode == 404) {
        state = state.copyWith(
          isLoading: false,
          error: "Pasto non trovato con ID: $mealId",
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: "Errore del server: ${response.statusCode}",
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: "Errore di rete: $e",
      );
    }
  }

  Future<void> updateMeal(MealDetail meal) async {
    state = state.copyWith(isLoading: true, error: null);
    final bodyJson = jsonEncode(meal.toJson()..remove('mealId'));
    final url = Uri.parse('${AppConfig.baseUrl}/meal/${meal.mealId}');
    print('PUT URL: $url');
    print('PUT BODY: $bodyJson');

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'slowKey': AppConfig.slowKey,
        },
        body: jsonEncode(meal.toJson()), // ✅ invia i dati aggiornati
      );

      print('STATUS CODE: ${response.statusCode}');
      print('BODY: ${response.body}');

      if (response.statusCode == 200) {
        // ✅ Ricarica i dettagli aggiornati dal server
        await fetchMealDetail(meal.mealId);
        state = state.copyWith(isLoading: false);
      } else if (response.statusCode == 404) {
        state = state.copyWith(
          isLoading: false,
          error: "Pasto con ID ${meal.mealId} non trovato",
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error:
              "Errore durante l'aggiornamento: ${response.statusCode} ${response.body}",
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: "Errore di rete: $e",
      );
    }
  }

  Future<void> createMeal(MealDetail meal) async {
    state = state.copyWith(isLoading: true, error: null);
    final url = Uri.parse('${AppConfig.baseUrl}/meal');
    print('PUT URL: $url');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'slowKey': AppConfig.slowKey,
        },
        body: jsonEncode(meal.toJson()), // ✅ invia i dati aggiornati
      );

      print('STATUS CODE: ${response.statusCode}');
      print('BODY: ${response.body}');

      if (response.statusCode == 200) {
        // ✅ Ricarica i dettagli aggiornati dal server
        await fetchMealDetail(meal.mealId);
        state = state.copyWith(isLoading: false);
      } else if (response.statusCode == 404) {
        state = state.copyWith(
          isLoading: false,
          error: "Pasto non salvato",
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error:
              "Errore durante l'aggiunta: ${response.statusCode} ${response.body}",
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: "Errore di rete: $e",
      );
    }
  }
}

/// 🪄 Provider globale
final mealDetailProvider =
    StateNotifierProvider<MealDetailNotifier, MealDetailState>(
  (ref) => MealDetailNotifier(),
);
