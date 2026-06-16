import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slowFit_client/nutrition/add_nutrition.dart';

import '../provider/bottom_bar_provider.dart';
import '../provider/meal_provider.dart';
import '../widget/custom_bottom_bar.dart';
import 'meal_widget.dart';

class MealPage extends ConsumerStatefulWidget {
  const MealPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _MealPageState();
  }
}

class _MealPageState extends ConsumerState<MealPage> {
  late int _selectedCategory = 1;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(categoryProvider.notifier).getCategoryOfDay();
      ref.read(dayWeekProvider.notifier).getDayWeek();
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(bottomBarProvider);
    final categoriesList = ref.watch(categoryProvider);
    final selectedMeals = ref.watch(selectedMealsProvider);
    final selectedMealsNotifier = ref.read(selectedMealsProvider.notifier);
    final day = ref.watch(dayWeekProvider);
    final mealsAsync = ref.watch(mealsByCategoryProvider(_selectedCategory));

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔝 HEADER
            Container(
              height: MediaQuery.of(context).size.height * 0.15,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Stack(
                children: [
                  Positioned(
                    top: 10,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context, selectedMeals);
                          },
                          icon: const Icon(Icons.arrow_back_ios,
                              color: Colors.black),
                        ),
                        IconButton(
                          onPressed: () {
                            // ✅ PRIMA DI ANDARE AVANTI, CONTROLLA SE CI SONO DAYID NULL
                            final invalidMeals = selectedMeals
                                .where((m) => m.dayId == null)
                                .toList();

                            if (invalidMeals.isNotEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "❌ Alcuni pasti non hanno un giorno assegnato. Assegna un giorno a tutti prima di continuare.",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: Colors.redAccent,
                                  duration: Duration(seconds: 3),
                                ),
                              );
                              return;
                            }

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddNutrition(),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.add_circle_outline,
                            color: Colors.pink,
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: MediaQuery.of(context).size.height * 0.06,
                    left: 0,
                    right: 0,
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Lista Piatti',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 33,
                          ),
                        ),
                        SizedBox(height: 15),
                        Text(
                          'Scegli i piatti e assegna un giorno a ciascuno.',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 📂 Categorie
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categoriesList.length,
                itemBuilder: (context, index) {
                  final category = categoriesList[index];
                  final isSelected = _selectedCategory == category.categoryId;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _selectedCategory = category.categoryId;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: isSelected ? Colors.pink : Colors.black,
                          width: 1.5,
                        ),
                        backgroundColor:
                        isSelected ? Colors.white : Colors.transparent,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        category.momentOfDay,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.pink : Colors.black,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // 📜 Lista piatti
            Expanded(
              child: mealsAsync.when(
                data: (meals) {
                  if (meals.isEmpty) {
                    return Center(
                      child: Text(
                        'Nessuna ricetta disponibile per questa categoria',
                        style:
                        TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    );
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: meals.map((meal) {
                        final isSelected = selectedMeals.contains(meal);

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () {
                                // 👇 Aggiungi sempre una nuova istanza selezionabile
                                selectedMealsNotifier
                                    .addMeal(meal.copyWith(dayId: null));
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: MealWidget(
                                  meals: meal,
                                  inte: 0.84,
                                  inte2: 2.9,
                                  select: isSelected,
                                ),
                              ),
                            ),
                            // 👇 Mostra dropdown per ogni istanza selezionata di questo pasto
                            ...selectedMeals
                                .where((m) => m.mealId == meal.mealId)
                                .map((selected) => Padding(
                              padding: const EdgeInsets.only(left: 16, bottom: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // 👇 Dropdown di selezione giorno
                                  Row(
                                    children: [
                                      const Text(
                                        "Assegna giorno:",
                                        style: TextStyle(
                                            fontSize: 16, fontWeight: FontWeight.w500),
                                      ),
                                      const SizedBox(width: 10),
                                      DropdownButton<int>(
                                        value: selected.dayId,
                                        hint: const Text("Seleziona"),
                                        items: day.map((d) {
                                          return DropdownMenuItem<int>(
                                            value: d.dayId,
                                            child: Text(d.dayString),
                                          );
                                        }).toList(),
                                        onChanged: (value) {
                                          if (value == null) return;

                                          final updatedMeals = [...selectedMeals];
                                          final index = updatedMeals.indexOf(selected);

                                          if (index != -1) {
                                            updatedMeals[index] =
                                                updatedMeals[index].copyWith(dayId: value);
                                            selectedMealsNotifier.updateMeals(updatedMeals);
                                          }
                                        },
                                      ),
                                    ],
                                  ),

                                  // 🗑️ Bottone di rimozione per questa istanza
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                                    tooltip: "Rimuovi questo piatto",
                                    onPressed: () {
                                      final updatedMeals = [...selectedMeals];
                                      updatedMeals.remove(selected);
                                      selectedMealsNotifier.updateMeals(updatedMeals);

                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text("✅ Piatto rimosso dalla selezione."),
                                          backgroundColor: Colors.green,
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ))
                                ,

                          ],
                        );
                      }).toList(),
                    ),
                  );
                },
                loading: () =>
                const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(
                  child: Text(
                    'Errore nel caricamento: $err',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomBar(currentIndex: selectedIndex),
    );
  }
}
