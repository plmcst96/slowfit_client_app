import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slowFit_client/model/meal_model.dart';

class MealWidget extends ConsumerWidget {
  const MealWidget({
    super.key,
    required this.meals,
    required this.inte,
    required this.inte2,
    this.select = false,
  });

  final Meal meals;
  final double inte;
  final double inte2;
  final bool select;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      clipBehavior: Clip.none, // 🔥 serve per permettere lo "sbordo"
      children: [
        // 🔹 La card sotto
        Card(
          borderOnForeground: true,
          color: Colors.white,
          elevation: 2,
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 30),
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: select ? Colors.pink : Colors.transparent,
              width: 3,
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          child: AspectRatio(
            aspectRatio: 3 / inte2,
            child: Container(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(15)),
                image: DecorationImage(
                  image: NetworkImage(meals.imageMeal ?? ''),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),

        // 🔹 Contenitore sopra la card (z-index maggiore)
        Positioned(
          bottom: 10, // 👈 fa sbordare verso il basso
          left: 20,
          right: 20,
          child: Material(
            elevation: 6, // 👈 questo aggiunge anche un'ombra sopra la card
            borderRadius: BorderRadius.circular(15),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(15)),
                color: Colors.white,
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: Row(
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.5,
                          child: Text(
                            meals.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 40),
                        Badge(
                          backgroundColor: Colors.white,
                          label: Text(
                            '${meals.preparingTime} min',
                            style: const TextStyle(
                              color: Colors.pink,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          child: const Icon(
                            Icons.access_time_rounded,
                            color: Colors.pink,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 10,
                    ),
                    decoration: const BoxDecoration(
                      color: Color(0xFFBAFFA5),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildInfo("Calorie", '${meals.calories} Kcal'),
                        _buildInfo("Proteine", '${meals.protein} g'),
                        _buildInfo("Grassi", '${meals.fats} g'),
                        _buildInfo("Carboidrati", '${meals.carbohydrate} g'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfo(String label, String value) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
