import 'meal_model.dart';

class Nutrition {
  int? nutritionId;
  DateTime creationDate;
  DateTime? expirationDate; // nullable
  List<Meal> meals;
  int typeNutritionId;
  int? totDailyCalories;
  int? userId;

  Nutrition({
    this.nutritionId,
    DateTime? creationDate,
    this.expirationDate,
    required this.meals,
    required this.typeNutritionId,
    this.totDailyCalories,
    this.userId,
  }) : creationDate = creationDate ?? DateTime.now();

  factory Nutrition.fromJson(Map<String, dynamic> json) {
    return Nutrition(
      nutritionId: json['nutritionId'],
      creationDate: json['creationDate'] != null
          ? DateTime.parse(json['creationDate'])
          : DateTime.now(),
      expirationDate: json['expirationDate'] != null
          ? DateTime.parse(json['expirationDate'])
          : null,
      meals: (json['meals'] as List<dynamic>?)
          ?.map((mealJson) => Meal.fromJson(mealJson))
          .toList() ??
          [],
      typeNutritionId: json['typeNutritionId'],
      totDailyCalories: json['totDailyCalories'],
      userId: json['userId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "userId": userId ?? 0, // fallback se null
      "typeNutritionId": typeNutritionId,
      "totDailyCalories": totDailyCalories ?? 0,
      // Rimuoviamo i microsecondi per compatibilità con C#
      "creationDate": creationDate.toIso8601String().split('.').first,
      "expirationDate": expirationDate?.toIso8601String().split('.').first,
      "meals": meals.map((m) => {
        "mealId": m.mealId,
        "dayId": m.dayId
      }).toList()
    };
  }
}

class NutritionDetail {
  int? nutritionId;
  int? userId;
  int? typeNutritionId;
  int? totDailyCalories;
  String? creationDate;
  String? expirationDate;
  List<Meal> meals; // lista piatta di tutti i pasti
  List<NutritionCategory> categories = []; // raggruppamento per category/day

  NutritionDetail({
    this.nutritionId,
    this.userId,
    this.typeNutritionId,
    this.totDailyCalories,
    this.creationDate,
    this.expirationDate,
    required this.meals,
    List<NutritionCategory>? categories,
  }) {
    this.categories = categories ?? [];
  }

  factory NutritionDetail.fromJson(Map<String, dynamic> json) {
    return NutritionDetail(
      nutritionId: json['nutritionId'],
      userId: json['userId'],
      typeNutritionId: json['typeNutritionId'],
      totDailyCalories: json['totDailyCalories'],
      creationDate: json['creationDate'],
      expirationDate: json['expirationDate'],
      meals: (json['meals'] as List<dynamic>?)
          ?.map((e) => Meal.fromJson(e))
          .toList() ??
          [],
    );
  }
}

class NutritionCategory {
  int categoryId;
  String categoryName;
  List<NutritionDay> days;

  NutritionCategory({
    required this.categoryId,
    required this.categoryName,
    required this.days,
  });
}

class NutritionDay {
  int dayId;
  String dayName;
  List<Meal> meals;

  NutritionDay({
    required this.dayId,
    required this.dayName,
    required this.meals,
  });
}

class DailyNutrition {
  final int nutritionId;
  final int userId;
  final int typeNutritionId;
  final int totDailyCalories;
  final int dayId;
  final Map<String, List<Meal>> mealsByCategory;

  DailyNutrition({
    required this.nutritionId,
    required this.userId,
    required this.typeNutritionId,
    required this.totDailyCalories,
    required this.dayId,
    required this.mealsByCategory,
  });

  factory DailyNutrition.fromJson(Map<String, dynamic> json) {
    final mealsByCategory = <String, List<Meal>>{};
    if (json['mealsByCategory'] != null) {
      json['mealsByCategory'].forEach((key, value) {
        mealsByCategory[key] =
            (value as List).map((m) => Meal.fromJson(m)).toList();
      });
    }

    return DailyNutrition(
      nutritionId: json['nutritionId'],
      userId: json['userId'],
      typeNutritionId: json['typeNutritionId'],
      totDailyCalories: json['totDailyCalories'],
      dayId: json['dayId'],
      mealsByCategory: mealsByCategory,
    );
  }
}
