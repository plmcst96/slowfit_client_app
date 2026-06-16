

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:slowFit_client/client/client_page.dart';
import 'package:slowFit_client/provider/meal_provider.dart';
import 'package:slowFit_client/provider/nutrition_provider.dart';
import '../model/meal_model.dart';
import '../model/nutrition_model.dart';
import '../provider/user_provider.dart';
import 'meal_detail.dart';
import 'meal_page.dart';
import 'meal_widget.dart';
import 'nutrition_page.dart';

class NutritionDetailModal extends ConsumerStatefulWidget {
  final int nutritionId;
  final int typeId;
  const NutritionDetailModal({
    super.key,
    required this.nutritionId,
    required this.typeId,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _NutritionDetailModalState();
}

class _NutritionDetailModalState extends ConsumerState<NutritionDetailModal> {
  bool _isEdit = false;

  // Rendiamo nullable per gestire "nessuna selezione" in modo sicuro
  int? selectedType;
  int? selectedUser;

  // utilità: converte qualsiasi id (int, String) in int? in modo sicuro
  int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  @override
  void initState() {
    super.initState();

    // Carichiamo la nutrition e inizializziamo i selezionati
    Future.microtask(() async {
      await ref
          .read(nutritionByIdProvider.notifier)
          .fetchNutritionById(widget.nutritionId);

      final nutrition = ref.read(nutritionByIdProvider);
      if (nutrition != null) {
        final nt = _toInt(nutrition.typeNutritionId);
        final nu = _toInt(nutrition.userId);

        // set delle meals nel provider (assicurati che selectedMealsProvider.notifier abbia setMeals)
        ref.read(selectedMealsProvider.notifier).updateMeals(nutrition.meals);

        if (!mounted) return;
        setState(() {
          selectedType = nt;
          selectedUser = nu;
        });
      }
    });

    // Carica i tipi (non necessario await)
    Future.microtask(() {
      ref.read(typeNutrutionProvider.notifier).fetchType();
    });
  }

  int calculateTotalCalories(List<Meal> meals) {
    return meals.fold(0, (sum, meal) => sum + meal.calories);
  }

  void updateNutrition(Nutrition nutritionBody) async {
    try {
      await ref.read(nutritionProvider.notifier).updateNutrition(nutritionBody);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Piano nutrizionale aggiornato con successo!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => NutritionPage()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errore durante l\'aggiornamento: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void deleteNutrition(int id) async {
    try {
      await ref.read(nutritionProvider.notifier).deleteNutrition(id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Piano nutrizionale eliminato con successo!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ClientPage()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errore durante l\'eliminazione del piano nutrizionale con ID: $id'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final nutrition = ref.watch(nutritionByIdProvider);
    final typeState = ref.watch(typeNutritionByIdFamilyProvider(widget.typeId));
    final typeN = ref.watch(typeNutrutionProvider);
    final selectedMeals = ref.watch(selectedMealsProvider);
    final users = ref.watch(userProvider);

    if (nutrition == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final imageUrl = (nutrition.meals.isNotEmpty &&
            nutrition.meals.first.imageMeal != null)
        ? nutrition.meals.first.imageMeal!
        : 'https://media.hellofresh.com/w_3840,q_auto,f_auto,c_limit,fl_lossy/recipes/image/HF220905_R14_W39_IT_IT351-1_MB_Main_highremove_chili_rounds_edit_high-8a6c9450.jpg';

    return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(20),
            topLeft: Radius.circular(20),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: Material(
            child: Column(
              children: [
                // HEADER
                Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.33,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: NetworkImage(imageUrl), fit: BoxFit.cover),
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: 60,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 9),
                          decoration: const BoxDecoration(
                            color: Color(0XFFBAFFA5),
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: typeState.when(
                                  data: (typeData) => Text(
                                    typeData?.typeNutritionName ??
                                        'Tipo non trovato',
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  loading: () => const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2)),
                                  error: (e, _) => Text('Errore: $e',
                                      style:
                                          const TextStyle(color: Colors.red)),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                onPressed: () {
                                  // Quando entri in edit, se i selected* sono null li inizializziamo con i valori correnti
                                  final nt = _toInt(nutrition.typeNutritionId);
                                  final nu = _toInt(nutrition.userId);
                                  setState(() {
                                    _isEdit = !_isEdit;
                                    selectedType ??= nt;
                                    selectedUser ??= nu;
                                  });
                                },
                                icon: FaIcon(FontAwesomeIcons.pen,
                                    size: 20, color: Colors.black),
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
                    padding: const EdgeInsets.all(15),
                    child: _isEdit
                        ? buildEditContent(
                            typeN, selectedMeals, users, nutrition)
                        : buildViewContent(nutrition),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Widget buildViewContent(NutritionDetail nutrition) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...nutrition.categories.map((category) {
          final categoryAsync =
              ref.watch(categoryByIdProvider(category.categoryId));
          return categoryAsync.when(
            data: (catData) {
              final categoryName =
                  catData?.momentOfDay ?? "Categoria ${category.categoryId}";
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(categoryName,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  ...category.days.map((day) {
                    final dayAsync = ref.read(dayWeekByIdProvider(day.dayId));
                    return dayAsync.when(
                      data: (dayData) {
                        final dayName =
                            dayData?.dayString ?? "Giorno ${day.dayId}";
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 5),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  border:
                                      Border.all(color: Colors.pink, width: 2)),
                              child: Text(dayName,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.pink)),
                            ),
                            const SizedBox(height: 8),
                            ...day.meals.map((meal) {
                              final totalDayCalories = day.meals.fold<int>(
                                  0, (sum, meal) => sum + meal.calories);
                              return GestureDetector(
                                onTap: () => showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.white,
                                  builder: (context) => FractionallySizedBox(
                                      heightFactor: 0.8,
                                      child:
                                          MealDetailModal(mealId: meal.mealId)),
                                ),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          'Calorie giornaliere: $totalDayCalories Kcal',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      MealWidget(
                                          meals: meal, inte: 0.87, inte2: 2.8),
                                    ]),
                              );
                            }).toList(),
                          ],
                        );
                      },
                      loading: () => const CircularProgressIndicator(),
                      error: (e, _) => Text("Errore giorno: $e"),
                    );
                  }).toList(),
                  const Divider(thickness: 1, height: 20),
                ],
              );
            },
            loading: () => const CircularProgressIndicator(),
            error: (e, _) => Text("Errore categoria: $e"),
          );
        }).toList(),
        SizedBox(
          height: 20,
        ),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
            onPressed: () => showDialog(
              context: context,
              builder: (BuildContext context) => Dialog(
                backgroundColor: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        'Cancella Piano Nutrizionale',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.pink),
                      ),
                      SizedBox(height: 20,),
                      const Text(
                        'Sei sicuro di voler cancellare questo piano nutrizionale?',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          TextButton(
                            onPressed: ()  {
                              deleteNutrition(nutrition.nutritionId!);
                            },
                            child: const Text('Cancella', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Chiudi', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            child: const Text('Cancella Piano Nutrizionale',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
        SizedBox(
          height: 20,
        ),
      ],
    );
  }

  Widget buildEditContent(List typeN, List<Meal> selectedMeals, List users,
      NutritionDetail nutrition) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('1. Tipo Piano Nutrizionale',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28)),
        const SizedBox(height: 10),
        const Text('Seleziona il tipo di piano nutrizionale.'),
        const SizedBox(height: 20),

        // ------------------- GRID TIPI -------------------
        typeN.isEmpty
            ? const Center(
                child: Text('Nessun tipo di nutrizione disponibile',
                    style: TextStyle(color: Colors.grey)))
            : GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 3,
                ),
                itemCount: typeN.length,
                itemBuilder: (context, index) {
                  final item = typeN[index];
                  final itemId = _toInt(item.typeNutritionId);

                  // controlliamo in modo sicuro la selezione
                  final isSelected = selectedType != null &&
                      itemId != null &&
                      selectedType == itemId;

                  return InkWell(
                    key: ValueKey('type-${itemId ?? index}'),
                    onTap: () {
                      // aggiorna lo stato locale
                      setState(() {
                        selectedType = itemId;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.pink[800]
                            : Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                            color:
                                isSelected ? Colors.pink : Colors.grey.shade400,
                            width: isSelected ? 2 : 1),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        item.typeNutritionName ?? '',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.pink : Colors.black),
                      ),
                    ),
                  );
                },
              ),

        const SizedBox(height: 30),

        // ------------------- PASTI -------------------
        Row(
          children: [
            const Text('2. Pasti',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28)),
            const Spacer(),
            TextButton(
              onPressed: () => Navigator.push(
                  context, MaterialPageRoute(builder: (context) => MealPage())),
              child: Row(children: [
                Text('Seleziona Altro',
                    style: TextStyle(color: Colors.grey[600])),
                const SizedBox(width: 6),
                Icon(Icons.arrow_forward_outlined, color: Colors.grey[600])
              ]),
            ),
          ],
        ),
        const SizedBox(height: 10),
        selectedMeals.isEmpty
            ? const Text('Nessuna ricetta selezionata')
            : SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: selectedMeals.length,
                  itemBuilder: (context, index) {
                    final meal = selectedMeals[index];
                    final isSelect = selectedMeals.contains(meal);
                    return GestureDetector(
                      onTap: () => ref
                          .read(selectedMealsProvider.notifier)
                          .toggleMeal(meal),
                      child: MealWidget(
                          meals: meal,
                          inte: 0.87,
                          inte2: 2.8,
                          select: isSelect),
                    );
                  },
                ),
              ),

        const SizedBox(height: 20),

        // ------------------- UTENTI -------------------
        const Text('3. Utenti',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28)),
        const SizedBox(height: 10),
        SizedBox(
          height: 130,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final userId = _toInt(user.userId);
              final isSelect = selectedUser != null &&
                  userId != null &&
                  selectedUser == userId;

              return GestureDetector(
                onTap: () => setState(() => selectedUser = userId),
                child: Card(
                  color: const Color(0XFFE0F6DA),
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: Row(children: [
                      Image.asset('assets/illustration_avatar.png', width: 80),
                      const SizedBox(width: 10),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(children: [
                              Text('${user.firstName} ${user.surname}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(width: 20),
                              if (isSelect)
                                const Icon(Icons.check_circle_outline,
                                    color: Colors.pink)
                            ]),
                            Text(user.email,
                                style: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.width /
                                            35)),
                            Text(user.phone ?? '',
                                style: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.width /
                                            35)),
                          ]),
                    ]),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 20),

        // ------------------- SAVE -------------------
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
            onPressed: () {
              final totCalories =
                  calculateTotalCalories(ref.read(selectedMealsProvider));
              // controllo minimo
              if (selectedType == null || selectedUser == null) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Seleziona tipo e utente prima di salvare')));
                return;
              }
              updateNutrition(Nutrition(
                nutritionId: widget.nutritionId,
                meals: ref.read(selectedMealsProvider),
                typeNutritionId: selectedType!,
                userId: selectedUser,
                totDailyCalories: totCalories,
              ));
            },
            child: const Text('Salva Piano Nutrizionale',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}
