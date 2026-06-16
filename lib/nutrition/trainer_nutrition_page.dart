import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slowFit_client/nutrition/add_nutrition.dart';
import 'package:slowFit_client/nutrition/meal_detail.dart';
import 'package:slowFit_client/nutrition/meal_page_list.dart';
import 'package:slowFit_client/nutrition/meal_widget.dart';
import 'package:slowFit_client/nutrition/nutrition_detail.dart';
import 'package:slowFit_client/provider/ingredient_provider.dart';
import 'package:slowFit_client/provider/meal_provider.dart';
import 'package:slowFit_client/provider/nutrition_provider.dart';

import '../provider/bottom_bar_provider.dart';
import '../widget/custom_bottom_bar.dart';

class TrainerNutritionPage extends ConsumerStatefulWidget {
  const TrainerNutritionPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _TrainerNutritionPageState();
  }
}

class _TrainerNutritionPageState extends ConsumerState<TrainerNutritionPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(ingredientProvider.notifier).getIngredients();
    });
    Future.microtask(() {
      ref.read(mealProvider.notifier).getMeals();
    });

    Future.microtask(() {
      ref.read(nutritionProvider.notifier).fetchNutritions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(bottomBarProvider);

    final meal = ref.watch(mealProvider);
    final nutrition = ref.watch(nutritionProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.33,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30)),
                image: DecorationImage(
                  image: AssetImage('assets/nutrition_bg.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                      color: Colors.black45, // Cambia opacità a tuo piacimento
                    ),
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: IconButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/trainer-home');
                      },
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Positioned(
                    top: MediaQuery.of(context).size.height * 0.10,
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        'Nutrizione',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 40),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 40,
                      ),
                      Text(
                        'Qui troverai alcune ricette che ti possono ispirre per creare il tuo piano nutrizionale o crearne di nuove completamnete personalizzate',
                        style: TextStyle(color: Colors.black54),
                      ),
                      //Inizio Sezione ricette
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          Text(
                            'Ricette',
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          Spacer(),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => MealPageList()));
                            },
                            child: Row(
                              children: [
                                Text(
                                  'Vedi Altro',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                                SizedBox(
                                  width: 6,
                                ),
                                Icon(
                                  Icons.arrow_forward_outlined,
                                  color: Colors.grey[600],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        'Ricette disponibili per poter creare un piano nutrizionale',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      if (meal.isNotEmpty)
                        SizedBox(
                          height: 420, // altezza fissa delle card
                          child: ListView.builder(
                            scrollDirection:
                                Axis.horizontal, // 👈 SCROLL ORIZZONTALE
                            itemCount: meal.take(5).length,
                            itemBuilder: (context, index) {
                              final meals = meal[index];

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
                                          0.9, // 80% dell'altezza dello schermo
                                      child: MealDetailModal(
                                        mealId: meals.mealId,
                                      ),
                                    ),
                                  );
                                },
                                child: MealWidget(
                                  meals: meals,
                                  inte: 0.76,
                                  inte2: 3,
                                ),
                              );
                            },
                          ),
                        )
                      else
                        Container(
                          child: Center(
                            child: Text('Nessuna ricetta disponibile'),
                          ),
                        ),
                      SizedBox(
                        height: 8,
                      ),
                      //--> Inizio sezione ingredienti
                      SizedBox(
                        height: 30,
                      ),
                      if (nutrition.length > 5)
                        Row(
                          children: [
                            Text(
                              'Nutrizione',
                              style: TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            Spacer(),
                            nutrition.isNotEmpty
                                ? TextButton(
                                    onPressed: () {},
                                    child: Row(
                                      children: [
                                        Text(
                                          'Vedi Altro',
                                          style: TextStyle(
                                              color: Colors.grey[600]),
                                        ),
                                        SizedBox(
                                          width: 6,
                                        ),
                                        Icon(
                                          Icons.arrow_forward_outlined,
                                          color: Colors.grey[600],
                                        ),
                                      ],
                                    ),
                                  )
                                : Container()
                          ],
                        )
                      else
                        Row(
                          children: [
                            Text(
                              'Nutrizione',
                              style: TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            Spacer(),
                            nutrition.isNotEmpty
                                ? TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  AddNutrition()));
                                    },
                                    child: Row(
                                      children: [
                                        Text(
                                          'Aggiungi',
                                          style: TextStyle(
                                              color: Colors.grey[600]),
                                        ),
                                        SizedBox(
                                          width: 6,
                                        ),
                                        Icon(
                                          Icons.add,
                                          color: Colors.grey[600],
                                        ),
                                      ],
                                    ),
                                  )
                                : Container()
                          ],
                        ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        'Piani nutrizionali generati in base al tipo di nutrizione che si vuole avere.',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      if (nutrition.isNotEmpty)
                        SizedBox(
                          height: 280,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: nutrition.take(5).length,
                            itemBuilder: (context, index) {
                              final nutri = nutrition[index];

                              // Qui usiamo la family provider con l'ID dinamico
                              final typeState = ref.watch(typeNutritionByIdFamilyProvider(nutri.typeNutritionId));

                              return GestureDetector(
                                onTap: () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.white,
                                    builder: (context) => FractionallySizedBox(
                                      heightFactor: 0.8,
                                      child: NutritionDetailModal(
                                        nutritionId: nutri.nutritionId!,
                                        typeId: nutri.typeNutritionId,
                                      ),
                                    ),
                                  );
                                },
                                child: Card(
                                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width * 0.70,
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(Radius.circular(15)),
                                            image: DecorationImage(
                                              image: NetworkImage(
                                                nutri.meals.isNotEmpty
                                                    ? nutri.meals.first.imageMeal ?? ''
                                                    : 'https://media.hellofresh.com/w_3840,q_auto,f_auto,c_limit,fl_lossy/recipes/image/HF220905_R14_W39_IT_IT351-1_MB_Main_highremove_chili_rounds_edit_high-8a6c9450.jpg',
                                              ),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          top: 20,
                                          right: 20,
                                          child: Container(
                                            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                                            decoration: BoxDecoration(
                                              color: Color(0XFFBAFFA5),
                                              borderRadius: BorderRadius.all(Radius.circular(20)),
                                            ),
                                            child: typeState.when(
                                              data: (type) => Text(
                                                type?.typeNutritionName ?? 'Tipo non trovato',
                                                style: TextStyle(fontWeight: FontWeight.bold),
                                              ),
                                              loading: () => SizedBox(
                                                  width: 20,
                                                  height: 20,
                                                  child: CircularProgressIndicator(strokeWidth: 2)),
                                              error: (e, _) => Text('Errore: $e'),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        )

                      else
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.16,
                          child: Center(
                            child: Column(
                              children: [
                                SizedBox(
                                  width: 150,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        side: BorderSide(
                                            color: Colors.pink, width: 1.3)),
                                    onPressed: () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => AddNutrition(),
                                        ),
                                      );
                                    },
                                    child: Row(
                                      children: [
                                        Text(
                                          'Aggiungi',
                                          style: TextStyle(
                                              color: Colors.pink,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Icon(
                                          Icons.add_circle_outline,
                                          color: Colors.pink,
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Text(
                                  'Nessuna ricetta disponibile',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                )
                              ],
                            ),
                          ),
                        ),
                      SizedBox(
                        height: 30,
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: selectedIndex,
      ),
    );
  }
}
