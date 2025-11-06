
import 'ingredient_model.dart';

class CategoryOfDay {
  late int categoryId;
  late String momentOfDay;

  CategoryOfDay({required this.categoryId, required this.momentOfDay});

  factory CategoryOfDay.fromJson(Map<String, dynamic> json) {
    return CategoryOfDay(
        categoryId: json['categoryId'], momentOfDay: json['momentOfDay']);
  }

  Map<String, dynamic> toJson() {
    return {'categoryId': categoryId, 'momentOfDay': momentOfDay};
  }
}

class DayWeek {
  late int dayId;
  late String dayString;

  DayWeek({
    required this.dayId,
    required this.dayString,
  });
  factory DayWeek.fromJson(Map<String, dynamic> json) {
    return DayWeek(dayId: json['dayId'], dayString: json['dayString']);
  }

  Map<String, dynamic> toJson() {
    return {'dayId': dayId, 'dayString': dayString};
  }
}

class Meal {
  late int mealId;
  late String name;
  late String description;
  late String recipe;
  late int calories;
  late int preparingTime;
  late int protein;
  late int fats;
  late int carbohydrate;
  late String? imageMeal;
  late int? difficulty;
  late int? categoryId;
  late int? dayId;

  Meal(
      {required this.mealId,
      required this.name,
      required this.description,
      required this.recipe,
      required this.calories,
      required this.preparingTime,
      required this.protein,
      required this.fats,
      required this.carbohydrate,
      this.imageMeal,
      this.difficulty,
      this.categoryId,
      this.dayId});

  Meal copyWith({
    int? mealId,
    String? name,
    String? description,
    String? recipe,
    int? calories,
    int? preparingTime,
    int? protein,
    int? fats,
    int? carbohydrate,
    String? imageMeal,
    int? difficulty,
    int? categoryId,
    int? dayId,
  }) {
    return Meal(
      mealId: mealId ?? this.mealId,
      name: name ?? this.name,
      description: description ?? this.description,
      recipe: recipe ?? this.recipe,
      calories: calories ?? this.calories,
      preparingTime: preparingTime ?? this.preparingTime,
      protein: protein ?? this.protein,
      fats: fats ?? this.fats,
      carbohydrate: carbohydrate ?? this.carbohydrate,
      imageMeal: imageMeal ?? this.imageMeal,
      difficulty: difficulty ?? this.difficulty,
      categoryId: categoryId ?? this.categoryId,
      dayId: dayId ?? this.dayId,
    );
  }

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      mealId: json['mealId'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      recipe: json['recipe'] ?? '',
      calories: json['calories'],
      preparingTime: json['preparingTime'],
      protein: json['protein'],
      fats: json['fats'],
      carbohydrate: json['carbohydrate'],
      imageMeal: json['imageMeal'] ?? null,
      difficulty: json['difficulty'] ?? null,
      categoryId: json['categoryId'] ?? null,
      dayId: json['dayId'] ?? null
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mealId': mealId,
      'name': name,
      'description': description,
      'recipe': recipe,
      'calories': calories,
      'preparingTime': preparingTime,
      'protein': protein,
      'fats': fats,
      'carbohydrate': carbohydrate,
      'imageMeal': imageMeal,
      'difficulty': difficulty,
      'categoryId': categoryId,
      'dayId': dayId
    };
  }
}

class MealDetail {
  late int mealId;
  late String name;
  late String description;
  late String recipe;
  late int calories;
  late int preparingTime;
  late int protein;
  late int fats;
  late int carbohydrate;
  late String? imageMeal;
  late int? difficulty;
  late int? categoryId;
  late int? dayId;
  late List<IngredientDetail> ingredients; // ⚡ lista, non singolo

  MealDetail({
    required this.mealId,
    required this.name,
    required this.description,
    required this.recipe,
    required this.calories,
    required this.preparingTime,
    required this.protein,
    required this.fats,
    required this.carbohydrate,
    this.imageMeal,
    this.difficulty,
    this.categoryId,
    this.dayId,
    required this.ingredients,
  });

  factory MealDetail.fromJson(Map<String, dynamic> json) {
    return MealDetail(
      mealId: json['mealId'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      recipe: json['recipe'] ?? '',
      calories: json['calories'],
      preparingTime: json['preparingTime'],
      protein: json['protein'],
      fats: json['fats'],
      carbohydrate: json['carbohydrate'],
      imageMeal: json['imageMeal'],
      difficulty: json['difficulty'],
      categoryId: json['categoryId'],
      dayId: json['dayId'],
      ingredients: (json['ingredients'] as List<dynamic>?)
          ?.map((e) => IngredientDetail.fromJson(e))
          .map((e) => IngredientDetail.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mealId': mealId,
      'name': name,
      'description': description,
      'recipe': recipe,
      'calories': calories,
      'preparingTime': preparingTime,
      'protein': protein,
      'fats': fats,
      'carbohydrate': carbohydrate,
      'imageMeal': imageMeal,
      'difficulty': difficulty,
      'categoryId': categoryId,
      'dayId': dayId,
      'ingredients': ingredients.map((e) => e.toJson()).toList(),
    };
  }
}



