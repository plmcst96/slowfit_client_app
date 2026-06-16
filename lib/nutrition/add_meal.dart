import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slowFit_client/nutrition/ingredient_widget.dart';
import 'package:slowFit_client/provider/meal_provider.dart';
import 'package:slowFit_client/widget/input_meal.dart';
import '../model/ingredient_model.dart';
import '../model/meal_model.dart';
import '../provider/ingredient_provider.dart';

class AddMeal extends ConsumerStatefulWidget {
  const AddMeal({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddMealState();
}

class _AddMealState extends ConsumerState<AddMeal> {
  final GlobalKey _formKey = GlobalKey();
  late final TextEditingController _nameController = TextEditingController();
  late final TextEditingController _descriptionController = TextEditingController();
  late final TextEditingController _recipeController = TextEditingController();
  late final TextEditingController _searchController = TextEditingController();
  late final TextEditingController _imageMealController = TextEditingController();
  late int _calories = 0;
  late int _preparingTime = 0;
  late int _protein = 0;
  late int _fats = 0;
  late int _carbohydrate = 0;
  late int _difficulty = 0;
  late int _categoryId = 0;

  // mappe per controller per singolo ingrediente (key: ingredient.id)
  final Map<int, TextEditingController> _quantityControllers = {};
  final Map<int, TextEditingController> _unitControllers = {};

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(ingredientProvider.notifier).getIngredients();
    });
  }

  void _calculateNutrients() {
    int totalCalories = 0;
    int totalProtein = 0;
    int totalFats = 0;
    int totalCarbs = 0;

    final selectedIngredients = ref.read(selectedIngredientProvider);

    for (final ing in selectedIngredients) {
      final qtyText = _quantityControllers[ing.ingredientId]?.text ?? '0';
      final qty = int.tryParse(qtyText) ?? 0;

      // ⚠️ Qui assumiamo che i valori siano per 100g, moltiplichiamo in base alla quantità
      totalCalories += ((ing.calories ?? 0) * qty ~/ 100);
      totalProtein += ((ing.protein ?? 0) * qty ~/ 100);
      totalFats += ((ing.fats ?? 0) * qty ~/ 100);
      totalCarbs += ((ing.carbohydrate ?? 0) * qty ~/ 100);
    }

    setState(() {
      _calories = totalCalories;
      _protein = totalProtein;
      _fats = totalFats;
      _carbohydrate = totalCarbs;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _recipeController.dispose();
    _searchController.dispose();
    for (final c in _quantityControllers.values) {
      c.dispose();
    }
    for (final c in _unitControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allIngredients = ref.watch(ingredientProvider);
    final selectedIngredients = ref.watch(selectedIngredientProvider);
    final category = ref.watch(categoryProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            Container(
              height: MediaQuery.of(context).size.height * 0.33,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30)),
                image: DecorationImage(
                  image: AssetImage('assets/meal.jpg'),
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
                      color: Colors.black45,
                    ),
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.arrow_back_ios, color: Colors.white),
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
                              'Aggiungi Piatto',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 33),
                            ),
                          ),
                          const SizedBox(height: 15),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.8,
                            child: Text(
                              'Crea un piatto personalizzato in base ad ingredienti ben selezionati.',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. Inserisci Piatto
                        Text(
                          '1. Inserisci Piatto',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 28),
                        ),
                        SizedBox(height: 10),
                        Text(
                            'Inserisci i dati principali per creare il nuovo piatto'),
                        const SizedBox(height: 20),
                        InputMeal(
                            controller: _nameController,
                            hint: "Inserisci il nome del piatto",
                            label: "Nome"),
                        const SizedBox(height: 10),
                        InputMeal(
                            lines: 3,
                            controller: _descriptionController,
                            hint: "Inserisci descrizione del piatto",
                            label: "Descrizione"),
                        const SizedBox(height: 10),
                        InputMeal(
                            lines: 5,
                            controller: _recipeController,
                            hint: "Inserisci ricetta del piatto",
                            label: "Ricetta"),
                        const SizedBox(height: 10),
                        InputMeal(
                            lines: 2,
                            controller: _imageMealController,
                            hint: "Inserisci l'immagine del piatto",
                            label: "Immagine"),
                        const SizedBox(height: 30),

                        // 2. Scegli Ingredienti
                        Text('2. Scegli Ingredienti',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 28)),
                        SizedBox(height: 10),
                        Text(
                            'Scegli gli ingredienti che comporranno i tuoi piatti.'),
                        const SizedBox(height: 20),

                        // Search
                        TextFormField(
                          controller: _searchController,
                          onChanged: (value) {
                            ref
                                .read(ingredientProvider.notifier)
                                .getIngredients(search: value);
                          },
                          decoration: InputDecoration(
                            labelText: 'Cerca',
                            hintText: 'Cerca ingredienti',
                            labelStyle: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                            hintStyle: TextStyle(color: Colors.black54),
                            border: OutlineInputBorder(),
                            enabledBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.black, width: 1)),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color(0xFFBAFFA5), width: 1.5)),
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Lista completa ingredienti
                        if (allIngredients.isNotEmpty)
                          AnimatedSize(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            child: SizedBox(
                              height: 180.0 +
                                  (selectedIngredients.isNotEmpty
                                      ? 155.0
                                      : 0.0),
                              // Altezza dinamica
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: allIngredients.length,
                                itemBuilder: (context, index) {
                                  final ing = allIngredients[index];
                                  final isSelected =
                                      selectedIngredients.contains(ing);

                                  final qtyController =
                                      _quantityControllers.putIfAbsent(
                                          ing.ingredientId,
                                          () => TextEditingController());
                                  final unitController =
                                      _unitControllers.putIfAbsent(
                                          ing.ingredientId,
                                          () => TextEditingController());

                                  return Padding(
                                    padding: const EdgeInsets.all(6.0),
                                    child: AnimatedSize(
                                      duration:
                                          const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                      child: SizedBox(
                                        width: 220,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                ref
                                                    .read(
                                                        selectedIngredientProvider
                                                            .notifier)
                                                    .toggleIngredient(ing);
                                                setState(
                                                    () {}); // refresh immediato
                                              },
                                              child: IngredientWidget(
                                                  ingredient: ing,
                                                  isSelected: isSelected),
                                            ),
                                            const SizedBox(height: 15),
                                            if (isSelected) ...[
                                              TextField(
                                                controller: qtyController,
                                                keyboardType:
                                                    TextInputType.number,
                                                onChanged: (_) =>
                                                    setState(() {}),
                                                inputFormatters: [
                                                  FilteringTextInputFormatter
                                                      .digitsOnly
                                                ],
                                                decoration: InputDecoration(
                                                  labelText: 'Quantità',
                                                  hintText: 'es. 100',
                                                  border: OutlineInputBorder(),
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              TextField(
                                                controller: unitController,
                                                onChanged: (_) =>
                                                    setState(() {}),
                                                decoration: InputDecoration(
                                                  labelText: 'Unità',
                                                  hintText: 'g / ml / pz',
                                                  border: OutlineInputBorder(),
                                                ),
                                              ),
                                            ]
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          )
                        else
                          Center(child: Text('Nessun ingrediente disponibile')),

                        // Lista ingredienti selezionati con quantità e unità
                        if (selectedIngredients.isNotEmpty) ...[
                          const SizedBox(height: 30),
                          Text('🥗 Ingredienti selezionati',
                              style: TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: selectedIngredients.length,
                            itemBuilder: (context, index) {
                              final ing = selectedIngredients[index];
                              final qty = _quantityControllers[ing.ingredientId]
                                      ?.text ??
                                  '';
                              final unit =
                                  _unitControllers[ing.ingredientId]?.text ??
                                      '';

                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                child: ListTile(
                                  title: Text(ing.name,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  subtitle: Text(
                                    qty.isEmpty || unit.isEmpty
                                        ? "Quantità e unità non impostate"
                                        : "Quantità: $qty $unit",
                                  ),
                                  trailing: IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      ref
                                          .read(selectedIngredientProvider
                                              .notifier)
                                          .toggleIngredient(ing);
                                      setState(() {});
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                        Text(
                          '3. Inserisci Dettagli',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 28),
                        ),
                        SizedBox(height: 10),
                        Text(
                            'Inserisci i dettagli per poter completare la tua ricetta.'),
                        const SizedBox(height: 10),
                        Text('Scegli il momento della giornata.'),
                        const SizedBox(height: 20),
                        GridView.builder(
                          shrinkWrap:
                              true, // 👈 importante: si adatta all'altezza del contenuto
                          physics:
                              const NeverScrollableScrollPhysics(), // 👈 disattiva lo scroll interno
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount:
                                2, // numero di colonne della griglia
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 1.8,
                          ),
                          itemCount: category.length,
                          itemBuilder: (context, index) {
                            final cate = category[index];
                            final select = cate.categoryId == _categoryId;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _categoryId = cate.categoryId;
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(20),
                                  ),
                                  border: Border.all(
                                      color: Colors.pink,
                                      width: select ? 5 : 2),
                                ),
                                height: 20,
                                alignment: Alignment.center,
                                child: Text(
                                  cate.momentOfDay,
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 30),
                        Text('Scegli il livello di difficoltà della ricetta.'),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection:
                                Axis.horizontal, // 👈 scorri in orizzontale
                            itemCount: 10,
                            itemBuilder: (context, index) {
                              final listDifficulty = [
                                1,
                                2,
                                3,
                                4,
                                5,
                                6,
                                7,
                                8,
                                9,
                                10
                              ];
                              final number = listDifficulty[index];
                              final select = _difficulty == number;

                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _difficulty = number;
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal:
                                          6.0), // spaziatura tra i cerchi
                                  child: Container(
                                    width: 50, // 👈 diametro del cerchio
                                    height: 50,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.pink, width: 1.5),
                                      shape: BoxShape
                                          .circle, // 👈 rende il container circolare
                                      color:
                                          select ? Colors.pink : Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 4,
                                          offset: Offset(2, 2),
                                        ),
                                      ],
                                    ),
                                    alignment: Alignment
                                        .center, // centra il testo nel cerchio
                                    child: Text(
                                      number.toString(),
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: select
                                            ? Colors.white
                                            : Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 30),
                        Text(
                            'Inserisci il tempo di preparazione di questa ricetta.'),
                        const SizedBox(height: 20),
                        DropdownButtonFormField<int>(
                          decoration: const InputDecoration(
                            labelText: "Tempo di preparazione (minuti)",
                            labelStyle: TextStyle(
                                color: Colors.pink,
                                fontWeight: FontWeight.bold),
                            enabledBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.black, width: 1)),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.black, width: 1.5)),
                          ),
                          initialValue: _preparingTime != 0
                              ? _preparingTime
                              : null, // 👈 valore iniziale (null se non selezionato)
                          items: [10, 15, 20, 25, 30, 40, 45, 50, 60, 80, 90]
                              .map((m) => DropdownMenuItem<int>(
                                    value: m,
                                    child: Text("$m min"),
                                  ))
                              .toList(),
                          onChanged: (e) {
                            setState(() {
                              _preparingTime =
                                  e ?? 0; // 👈 gestione valore nullable
                            });
                          },
                        ),
                        SizedBox(
                          height: 40,
                        ),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.pink),
                            onPressed: () async {
                              _calculateNutrients();

                              final selectedIngredients =
                                  ref.read(selectedIngredientProvider);

                              final meal = MealDetail(
                                mealId:
                                    0, // se lo genera il backend metti 0 o nulla
                                name: _nameController.text,
                                description: _descriptionController.text,
                                recipe: _recipeController.text,
                                calories: _calories,
                                preparingTime: _preparingTime,
                                protein: _protein,
                                fats: _fats,
                                carbohydrate: _carbohydrate,
                                imageMeal: _imageMealController.text.isEmpty
                                    ? null
                                    : _imageMealController.text,
                                difficulty: _difficulty,
                                categoryId: _categoryId,
                                dayId: null,
                                ingredients: selectedIngredients.map((ing) {
                                  final qty =
                                      _quantityControllers[ing.ingredientId]
                                              ?.text ??
                                          '0';
                                  final unit =
                                      _unitControllers[ing.ingredientId]
                                              ?.text ??
                                          '';
                                  return IngredientDetail(
                                    ingredientId: ing.ingredientId,
                                    name: ing.name,
                                    quantity: int.tryParse(qty) ?? 0,
                                    unit: unit,
                                  );
                                }).toList(),
                              );

                              await ref
                                  .read(mealDetailProvider.notifier)
                                  .createMeal(meal);
                            },
                            child: Text(
                              'Salva Ricetta',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
