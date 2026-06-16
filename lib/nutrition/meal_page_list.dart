import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slowFit_client/nutrition/add_meal.dart';
import '../provider/bottom_bar_provider.dart';
import '../provider/meal_provider.dart';
import '../widget/custom_bottom_bar.dart';
import 'meal_detail.dart';
import 'meal_widget.dart';

class MealPageList extends ConsumerStatefulWidget {
  const MealPageList({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _MealPageListState();
  }
}

class _MealPageListState extends ConsumerState<MealPageList> {
  late int _selectedCategory = 1;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      return ref.read(categoryProvider.notifier).getCategoryOfDay();
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(bottomBarProvider);
    final categoriesList = ref.watch(categoryProvider);

    // 👉 Usare il nuovo provider basato sulla categoria selezionata
    final mealsAsync = ref.watch(mealsByCategoryProvider(_selectedCategory));

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔝 HEADER
            Container(
              height: MediaQuery.of(context).size.height * 0.2,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Stack(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.black,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AddMeal()));
                        },
                        icon: const Icon(
                          Icons.add_circle_outline,
                          color: Colors.pink,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    top: MediaQuery.of(context).size.height * 0.06,
                    left: 0,
                    right: 0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Lista Piatti',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 28,
                          ),
                        ),
                        SizedBox(height: 15),
                        Text(
                          'Scegli i piatti con cui poter comporre il piano nutrizionale o crea i tuoi piatti partendo da qui.',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // 📂 Lista categorie
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
                        minimumSize: const Size(100, 40),
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
                            color: isSelected ? Colors.pink : Colors.black),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // 📜 Lista piatti filtrati per categoria
            Expanded(
              child: mealsAsync.when(
                data: (meals) {
                  if (meals.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 40.0),
                        child: Text(
                          'Nessuna ricetta disponibile per questa categoria',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    );
                  }

                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        children: meals.map((meal) {
                          return GestureDetector(
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled:
                                    true, // Importante per usare heightFactor
                                backgroundColor:
                                    Colors.white, // Bordo arrotondato
                                builder: (context) => FractionallySizedBox(
                                  heightFactor:
                                      0.7, // 80% dell'altezza dello schermo
                                  child: MealDetailModal(
                                    mealId: meal.mealId,
                                  ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: MealWidget(
                                meals: meal,
                                inte: 0.84,
                                inte2: 2.9,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (err, _) => Center(
                  child: Text(
                    'Errore nel caricamento dei piatti: $err',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: selectedIndex,
      ),
    );
  }
}
