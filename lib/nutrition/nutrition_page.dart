import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slowFit_client/widget/custom_appbar.dart';

import '../function.dart';
import '../model/meal_model.dart';
import '../provider/appointment_provider.dart';
import '../provider/bottom_bar_provider.dart';
import '../provider/login_provider.dart';
import '../provider/meal_provider.dart';
import '../provider/nutrition_provider.dart';
import '../widget/calendar_horizontal.dart';
import '../widget/custom_bottom_bar.dart';

class NutritionPage extends ConsumerStatefulWidget {
  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _NutritionPageState();
  }
}

class _NutritionPageState extends ConsumerState<NutritionPage> {
  bool _loading = true;

  int calculateTotalCalories(List<Meal> meals) {
    return meals.fold(0, (sum, meal) => sum + meal.calories);
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(bottomBarProvider);
    final selectedDate = ref.watch(selectedDateProvider);
    final login = ref.watch(loginProvider);

    final dayId = selectedDate != null
        ? Utils.getDayIdFromDate(selectedDate)
        : 1;

    final dailyNutritionAsync = ref.watch(
      dailyNutritionProvider((login.userId!, dayId)),
    );

    if (_loading) {
      Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: CustomAppBar(),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.12,
                child: HorizontalWeekCalendar(),
              ),
              Expanded(
                child: dailyNutritionAsync.when(
                  data: (nutrition) {
                    if (nutrition == null ||
                        nutrition.mealsByCategory.isEmpty) {
                      return const Center(
                        child: Text("Nessun piano nutrizionale per oggi"),
                      );
                    }

                    final categories = nutrition.mealsByCategory.entries
                        .toList();
                    final typeState = ref.watch(
                      typeNutritionByIdFamilyProvider(
                        nutrition.typeNutritionId,
                      ),
                    );
                    // 🔹 Calcola il totale di tutte le calorie giornaliere
                    final totCalories = nutrition.mealsByCategory.values
                        .expand(
                          (meals) => meals,
                        ) // unisce tutte le liste di pasti
                        .fold<int>(0, (sum, meal) => sum + meal.calories);
                    final totProtein = nutrition.mealsByCategory.values
                        .expand(
                          (meals) => meals,
                        ) // unisce tutte le liste di pasti
                        .fold<int>(0, (sum, meal) => sum + meal.protein);
                    final totFats = nutrition.mealsByCategory.values
                        .expand(
                          (meals) => meals,
                        ) // unisce tutte le liste di pasti
                        .fold<int>(0, (sum, meal) => sum + meal.fats);
                    final totCarb = nutrition.mealsByCategory.values
                        .expand(
                          (meals) => meals,
                        ) // unisce tutte le liste di pasti
                        .fold<int>(0, (sum, meal) => sum + meal.carbohydrate);

                    return Column(
                      children: [
                        // 🔹 Container con i dettagli del piano nutrizionale
                        typeState.when(
                          data: (type) {
                            if (type == null) return const SizedBox();
                            return Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 20),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 6,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    type.typeNutritionName,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Divider(),

                                  const SizedBox(height: 5),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 12),

                                      Row(
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                totCalories.toString() + 'kcal',
                                                style: TextStyle(
                                                  color: Colors.pink[600],
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              Text(
                                                'Calorie',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Spacer(),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                totProtein.toString() + 'g',
                                                style: TextStyle(
                                                  color: Colors.pink[600],
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              Text(
                                                'Proteine',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Spacer(),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                totFats.toString() + 'g',
                                                style: TextStyle(
                                                  color: Colors.pink[600],
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              Text(
                                                'Grassi',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Spacer(),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                totCarb.toString() + 'g',
                                                style: TextStyle(
                                                  color: Colors.pink[600],
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              Text(
                                                'Carboidrati',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (e, _) => Text('Errore caricamento piano: $e'),
                        ),
                        Expanded(
                          child: ListView.builder(
                            scrollDirection: Axis.vertical,
                            physics: const PageScrollPhysics(),
                            itemCount: categories.length,
                            itemBuilder: (context, index) {
                              final category = categories[index];

                              // 🔹 Converte la chiave (stringa) in intero
                              final categoryId =
                                  int.tryParse(category.key.toString()) ?? 0;
                              final meals = category.value;

                              // 🔹 Recupera i dettagli della categoria da Riverpod
                              final categoryAsync = ref.watch(
                                categoryByIdProvider(categoryId),
                              );

                              // 🔹 Prendo il primo piatto come copertina
                              final coverImage = meals.isNotEmpty
                                  ? (meals.first.imageMeal ?? '')
                                  : 'https://via.placeholder.com/300x200';

                              return categoryAsync.when(
                                data: (categoryData) {
                                  String categoryName =
                                      categoryData?.momentOfDay ??
                                      'Categoria $categoryId';
                                  // ✂️ Tronca se contiene "Spuntino"
                                  if (categoryName.contains('Spuntino')) {
                                    final index = categoryName.indexOf(
                                      'Spuntino',
                                    );
                                    categoryName = categoryName
                                        .substring(0, index + 'Spuntino'.length)
                                        .trim();
                                  }

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12.0,
                                      vertical: 15,
                                    ),
                                    child: Stack(
                                      clipBehavior: Clip.none,
                                      alignment: Alignment.bottomCenter,
                                      children: [
                                        // 🔸 Card immagine principale
                                        Container(
                                          margin: const EdgeInsets.only(
                                            bottom: 70,
                                          ), // lascia spazio per il box sotto
                                          child: Column(
                                            children: [
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 20,
                                                  vertical: 10,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.black,
                                                  borderRadius:
                                                      BorderRadius.all(
                                                        Radius.circular(30),
                                                      ),
                                                ),
                                                child: Text(
                                                  categoryName,
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                              SizedBox(height: 20),
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                child: Image.network(
                                                  coverImage,
                                                  height: 260,
                                                  width:
                                                      MediaQuery.of(
                                                        context,
                                                      ).size.width *
                                                      0.85,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        // 🔸 Contenitore sovrapposto bianco (info pasti)
                                        Positioned(
                                          bottom: 0,
                                          left: 0,
                                          right: 0,
                                          child: Container(
                                            margin: const EdgeInsets.only(
                                              left: 40,
                                            ),

                                            decoration: BoxDecoration(
                                              color: Colors.black87,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black12,
                                                  blurRadius: 4,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 25,
                                              vertical: 20,
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                ...meals.map(
                                                  (meal) => Text(
                                                    meal.name,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    textAlign: TextAlign.start,
                                                    softWrap: true,
                                                  ),
                                                ),
                                                const SizedBox(height: 20),
                                                ...meals.map(
                                                  (meal) => Row(
                                                    children: [
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            meal.calories
                                                                    .toString() +
                                                                'kcal',
                                                            style: TextStyle(
                                                              color: Colors
                                                                  .pink[600],
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 16,
                                                            ),
                                                          ),
                                                          Text(
                                                            'Calorie',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Spacer(),
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            meal.protein
                                                                    .toString() +
                                                                'g',
                                                            style: TextStyle(
                                                              color: Colors
                                                                  .pink[600],
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 16,
                                                            ),
                                                          ),
                                                          Text(
                                                            'Proteine',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Spacer(),
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            meal.fats
                                                                    .toString() +
                                                                'g',
                                                            style: TextStyle(
                                                              color: Colors
                                                                  .pink[600],
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 16,
                                                            ),
                                                          ),
                                                          Text(
                                                            'Grassi',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Spacer(),
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            meal.carbohydrate
                                                                    .toString() +
                                                                'g',
                                                            style: TextStyle(
                                                              color: Colors
                                                                  .pink[600],
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 16,
                                                            ),
                                                          ),
                                                          Text(
                                                            'Carboidrati',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(height: 20),
                                                // 🔹 Stato reattivo gestito da Riverpod
                                                // dentro il Column che lista i meals, al posto del tuo blocco attuale:
                                                ...meals.map((meal) {
                                                  // validiamo mealId (sia int oppure stringa convertibile)
                                                  final dynamic rawId =
                                                      meal.mealId;
                                                  final int mealId =
                                                      (rawId is int)
                                                      ? rawId
                                                      : (int.tryParse(
                                                              rawId.toString(),
                                                            ) ??
                                                            -1);

                                                  if (mealId <= 0) {
                                                    // se id non valido, mostriamo comunque il nome ma niente bottone
                                                    return Padding(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            vertical: 6.0,
                                                          ),
                                                      child: Text(
                                                        meal.name,
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    );
                                                  }

                                                  // ogni icona è un piccolo Consumer: quando cambia mealEatenProvider, si ricostruisce solo questo widget
                                                  return Consumer(
                                                    builder: (context, ref, _) {
                                                      final eatenMeals = ref
                                                          .watch(
                                                            mealEatenProvider,
                                                          );
                                                      final isEaten = eatenMeals
                                                          .contains(mealId);

                                                      return Padding(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              vertical: 1.0,
                                                            ),
                                                        child: Row(
                                                          children: [
                                                            Expanded(
                                                              child: Text(
                                                                'Segna come mangiato',
                                                                style: const TextStyle(
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                            ),
                                                            IconButton(
                                                              onPressed: () {
                                                                debugPrint(
                                                                  '[UI] toggle pressed for mealId=$mealId, before state=${eatenMeals.toList()}',
                                                                );
                                                                ref
                                                                    .read(
                                                                      mealEatenProvider
                                                                          .notifier,
                                                                    )
                                                                    .toggleMeal(
                                                                      mealId,
                                                                    );
                                                              },
                                                              icon: Icon(
                                                                isEaten
                                                                    ? Icons
                                                                          .verified_rounded
                                                                    : Icons
                                                                          .verified_outlined,
                                                                color: isEaten
                                                                    ? Colors
                                                                          .pink
                                                                    : Colors
                                                                          .white,
                                                                size: 30,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                  );
                                                }).toList(), // ricordati il toList() se serve
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                loading: () => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                                error: (e, _) => Text('Errore: $e'),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text("Errore: $e")),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: FloatingBottomBar(currentIndex: selectedIndex),
    );
  }
}
