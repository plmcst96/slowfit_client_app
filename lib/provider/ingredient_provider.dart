import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:http/http.dart' as http;

import '../config.dart';
import '../model/ingredient_model.dart';

class IngredientState extends StateNotifier<List<Ingredient>>{
  final Ref ref;

  IngredientState(this.ref) : super([]);

  Future<void> getIngredients({String search = ''}) async {
    final url = Uri.parse('${AppConfig.baseUrl}/ingredient');

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
        List<Ingredient> ingredients = data.map((e) => Ingredient.fromJson(e)).toList();

        // ✅ Filtra SOLO se search non è vuoto
        if (search.trim().isNotEmpty) {
          ingredients = ingredients
              .where((ing) => ing.name.toLowerCase().contains(search.toLowerCase()))
              .toList();
        }

        state = ingredients;
      } else {
        state = [];
      }
    } catch (e) {
      print("Errore: $e");
      state = [];
    }
  }

}

final ingredientProvider =
StateNotifierProvider<IngredientState, List<Ingredient>>((ref) {
  return IngredientState(ref);
});

class SelectedIngredientNotifier extends StateNotifier<List<Ingredient>> {
  SelectedIngredientNotifier() : super([]);

  void toggleIngredient(Ingredient ingredient) {
    if (state.contains(ingredient)) {
      state = state.where((m) => m != ingredient).toList();
    } else {
      state = [...state, ingredient];
    }
  }

  void setIngredient(List<Ingredient> meals) {
    state = meals;
  }

  void clear() {
    state = [];
  }
}

// Provider globale
final selectedIngredientProvider =
StateNotifierProvider<SelectedIngredientNotifier, List<Ingredient>>(
        (ref) => SelectedIngredientNotifier());
