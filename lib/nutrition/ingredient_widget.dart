import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slowFit_client/model/ingredient_model.dart';

class IngredientWidget extends ConsumerWidget {
  const IngredientWidget(
      {super.key, required this.ingredient, this.isSelected = false});
  final Ingredient ingredient;
  final bool isSelected;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: 180, // larghezza di ogni card
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Color(0xFFBAFFA5), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          if (isSelected)
            Padding(
              padding: EdgeInsets.all(8),
              child: Align(
                alignment: Alignment.topCenter,
                child: Icon(
                  Icons.verified,
                  color: Colors.green,
                ),
              ),
            ),
          Text(
            ingredient.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Calorie: ${ingredient.calories.toString()} Kcal', // oppure calorie ecc.
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 3),
          Text(
            'Proteine: ${ingredient.protein.toString()} g', // oppure calorie ecc.
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 3),
          Text(
            'Grassi: ${ingredient.fats.toString()} g', // oppure calorie ecc.
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 3),
          Text(
            'Carboidrati: ${ingredient.carbohydrate.toString()} g', // oppure calorie ecc.
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
