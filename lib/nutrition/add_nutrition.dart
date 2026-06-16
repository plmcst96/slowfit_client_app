import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slowFit_client/model/nutrition_model.dart';
import 'package:slowFit_client/nutrition/meal_page.dart';
import 'package:slowFit_client/nutrition/nutrition_page.dart';
import 'package:slowFit_client/provider/nutrition_provider.dart';

import '../model/meal_model.dart';
import '../provider/meal_provider.dart';
import '../provider/user_provider.dart';
import 'meal_widget.dart';

class AddNutrition extends ConsumerStatefulWidget {
  const AddNutrition({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _AddNutritionState();
  }
}

class _AddNutritionState extends ConsumerState<AddNutrition> {
  late int selectedType = 1;
  late int selectedUser = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.microtask(() {
      ref.read(typeNutrutionProvider.notifier).fetchType();
    });
  }

  void saveNutrition(Nutrition nutritionBody) async {
    try {
      // Chiamiamo il provider per creare il piano nutrizionale
      await ref.read(nutritionProvider.notifier).createNutrition(nutritionBody);

      // Se non lancia eccezione, POST è andata a buon fine
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Piano nutrizionale creato con successo!'),
            backgroundColor: Colors.green,
          ),
        );

        // Naviga alla NutritionPage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => NutritionPage()),
        );
      }

    } catch (_) {
      // L'errore (messaggio del backend) è già mostrato dal provider tramite
      // showAppError: qui evitiamo solo la snackbar di successo e la navigazione.
    }
  }

  // Metodo per calcolare le calorie totali dei pasti selezionati
  int calculateTotalCalories(List<Meal> meals) {
    return meals.fold(0, (sum, meal) => sum + (meal.calories));
  }

  @override
  Widget build(BuildContext context) {
    final typeN = ref.watch(typeNutrutionProvider);
    final users = ref.watch(userProvider);

    final selectedMeals = ref.watch(selectedMealsProvider);

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
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => NutritionPage()));
                      },
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Positioned(
                    top: MediaQuery.of(context).size.height * 0.06,
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.8,
                            child: Text(
                              'Aggiungi Piano Nutrizionale',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 33,
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.8,
                            child: Text(
                              'Crea un piano nutrizionale personalizzato per il tuo cliente seguendo gli step sotto riportati.',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        '1. Tipo Piano Nutrizionale',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 28),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text('Seleziona il tipo di piano nutrizionale.'),
                      const SizedBox(height: 30),

                      // Mostriamo i tipi di nutrizione
                      typeN.isEmpty
                          ? Center(
                              child: Text(
                                'Nessun tipo di nutrizione disponibile',
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                          : GridView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2, // ✅ due colonne
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                                childAspectRatio: 3, // regola altezza/largh
                              ),
                              itemCount: typeN.length,
                              itemBuilder: (context, index) {
                                final item = typeN[index];
                                final isSelect =
                                    selectedType == item.typeNutritionId;
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedType = item.typeNutritionId;
                                      debugPrint('${item.typeNutritionId}');
                                    });
                                  },
                                  child: Container(
                                    height: 100,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(
                                          color: isSelect
                                              ? Colors.pink
                                              : Colors.black,
                                          width: 1.3),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 6,
                                          offset: Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    padding: EdgeInsets.all(10),
                                    child: Center(
                                      child: Text(
                                        item.typeNutritionName, // 👈 usa il campo giusto del tuo modello
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: isSelect
                                              ? Colors.pink
                                              : Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                      SizedBox(
                        height: 30,
                      ),
                      Row(
                        children: [
                          Text(
                            '2. Pasti',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 28),
                          ),
                          Spacer(),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MealPage(),
                                ),
                              );
                            },
                            child: Row(
                              children: [
                                Text(
                                  'Seleziona Altro',
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
                          'Seleziona i pasti che vuoi inserire nel piano nutrizionale o creane di nuovi.'),
                      SizedBox(
                        height: 30,
                      ),
                      if (selectedMeals.isNotEmpty)
                        SizedBox(
                          height: 420, // altezza fissa delle card
                          child: ListView.builder(
                            scrollDirection:
                                Axis.horizontal, // 👈 SCROLL ORIZZONTALE
                            itemCount: selectedMeals.length,
                            itemBuilder: (context, index) {
                              final meals = selectedMeals[index];
                              final isSelected = selectedMeals.contains(meals);
                              return GestureDetector(
                                onTap: () {
                                  ref
                                      .read(selectedMealsProvider.notifier)
                                      .toggleMeal(meals);
                                },
                                child: MealWidget(
                                  meals: meals,
                                  inte: 0.83,
                                  inte2: 3,
                                  select: isSelected,
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
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => MealPage(),
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
                        height: 20,
                      ),
                      Text(
                        '3. Utenti',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 28),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                          "Seleziona l'utente a cui assegnare il piano nutrizionale."),
                      const SizedBox(height: 30),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.13,
                          child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: users.length,
                              itemBuilder: (context, index) {
                                final user = users[index];
                                final isSelect = selectedUser == user.userId;
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedUser = user.userId;
                                    });
                                  },
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.85,
                                    height: 200,
                                    child: Card(
                                      color: Color(0XFFE0F6DA),
                                      margin:
                                          EdgeInsets.symmetric(horizontal: 10),
                                      child: Padding(
                                        padding: EdgeInsets.all(12),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Image.asset(
                                                  'assets/illustration_avatar.png',
                                                  width: 80,
                                                ),
                                                SizedBox(width: 10),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Text(
                                                          '${user.firstName} ${user.surname}',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        SizedBox(
                                                          width: 30,
                                                        ),
                                                        isSelect
                                                            ? Icon(
                                                                Icons
                                                                    .check_circle_outline,
                                                                color:
                                                                    Colors.pink,
                                                              )
                                                            : Container()
                                                      ],
                                                    ),
                                                    SizedBox(height: 10),
                                                    Text(
                                                      user.email,
                                                      style: TextStyle(
                                                          fontSize: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width /
                                                              35),
                                                    ),
                                                    SizedBox(height: 10),
                                                    Text(
                                                      user.phone!,
                                                      style: TextStyle(
                                                          fontSize: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width /
                                                              35),
                                                    ),
                                                    SizedBox(height: 10),
                                                  ],
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              })),
                      const SizedBox(height: 30),
                      Padding(
                        padding: EdgeInsets.all(15),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.pink),
                            onPressed: () {
                              final totCalories =
                                  calculateTotalCalories(selectedMeals);
                              saveNutrition(
                                Nutrition(
                                    meals: selectedMeals,
                                    typeNutritionId: selectedType,
                                    userId: selectedUser,
                                    totDailyCalories: totCalories),
                              );
                            },
                            child: Text(
                              'Aggiungi Piano Nutrizionale',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
