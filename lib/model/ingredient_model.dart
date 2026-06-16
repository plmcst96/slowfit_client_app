class Ingredient {
  late int ingredientId;
  late String name;
  late int? calories;
  late double? protein;
  late double? fats;
  late double? carbohydrate;

  Ingredient({
    required this.ingredientId,
    required this.name,
    this.calories,
    this.protein,
    this.fats,
    this.carbohydrate,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      ingredientId: json['ingredientId'],
      name: json['name'],
      calories: json['calories'],
      protein: json['protein'],
      fats: json['fats'],
      carbohydrate: json['carbohydrate'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ingredientId': ingredientId,
      'name': name,
      'calories': calories,
      'protein': protein,
      'fats': fats,
      'carbohydrate': carbohydrate,
    };
  }
}

class IngredientDetail {
  late int ingredientId;
  late String? name;
  late int quantity;
  late String? unit;

  IngredientDetail(
      {required this.ingredientId,
       this.name,
      required this.quantity,
      this.unit});

  factory IngredientDetail.fromJson(Map<String, dynamic> json) {
    return IngredientDetail(
        ingredientId: json['ingredientId'],
        name: json['name'] ?? '',

        unit: json['unit'],
        quantity: json['quantity']);
  }

  Map<String, dynamic> toJson() {
    return {
      'ingredientId': ingredientId,
      'name': name,
      'quantity': quantity,
      'unit': unit
    };
  }
}


