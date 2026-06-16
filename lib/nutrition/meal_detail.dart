import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:slowFit_client/model/ingredient_model.dart';
import 'package:slowFit_client/model/meal_model.dart';
import 'package:slowFit_client/provider/ingredient_provider.dart';
import '../provider/meal_provider.dart';

class MealDetailModal extends ConsumerStatefulWidget {
  final int mealId;
  const MealDetailModal({super.key, required this.mealId});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _MealDetailModalState();
}

class _MealDetailModalState extends ConsumerState<MealDetailModal> {
  bool _isEdit = false;
  final _formKey = GlobalKey<FormState>();
  bool _openSelect = false;

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _recipeController;
  late TextEditingController _timeController;
  late TextEditingController _difficultyController;
  List<IngredientDetail> _editableIngredients = [];

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final mealNotifier = ref.read(mealDetailProvider.notifier);
      await mealNotifier.fetchMealDetail(widget.mealId);
      // ✅ Evita crash se il widget è stato smontato nel frattempo
      if (!mounted) return;

      final meal = ref.read(mealDetailProvider).meal;
      if (meal != null) {
        _nameController = TextEditingController(text: meal.name);
        _descriptionController = TextEditingController(text: meal.description);
        _recipeController = TextEditingController(text: meal.recipe);
        _timeController =
            TextEditingController(text: meal.preparingTime.toString());
        _difficultyController =
            TextEditingController(text: meal.difficulty?.toString() ?? '');

        // ✅ Copia ingredienti in una lista modificabile
        _editableIngredients = meal.ingredients
            .map((ing) => IngredientDetail(
                  ingredientId: ing.ingredientId,
                  name: ing.name ?? '',
                  quantity: ing.quantity, // int
                  unit: ing.unit,
                ))
            .toList();
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _recipeController.dispose();
    _timeController.dispose();
    _difficultyController.dispose();
    super.dispose();
  }

  void _submitUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    final currentMeal = ref.read(mealDetailProvider).meal!;

    // Filtra solo ingredienti validi
    final validIngredients = _editableIngredients
        .where((i) => i.quantity > 0 && i.ingredientId > 0)
        .toList();

    if (validIngredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Devi inserire almeno un ingrediente valido.')),
      );
      return;
    }

    final updatedMeal = MealDetail(
      mealId: currentMeal.mealId,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      recipe: _recipeController.text.trim(),
      calories: currentMeal.calories,
      protein: currentMeal.protein,
      fats: currentMeal.fats,
      carbohydrate: currentMeal.carbohydrate,
      preparingTime:
          int.tryParse(_timeController.text) ?? currentMeal.preparingTime,
      difficulty: int.tryParse(_difficultyController.text),
      categoryId: currentMeal.categoryId,
      imageMeal: currentMeal.imageMeal,
      ingredients: validIngredients,
    );

    try {
      await ref.read(mealDetailProvider.notifier).updateMeal(updatedMeal);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pasto aggiornato con successo ✅'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() => _isEdit = false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errore aggiornamento'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      print('ERRORE DURANTE LA PUT: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Errore di rete: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mealState = ref.watch(mealDetailProvider);
    final allIngredients = ref.watch(ingredientProvider);

    return _isEdit
        ? Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Modifica Pasto',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: "Nome",
                              labelStyle: TextStyle(
                                  color: Color(0XFFC4B7E1),
                                  fontWeight: FontWeight.bold),
                              border: OutlineInputBorder(),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.black, width: 1)),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color(0XFFC4B7E1), width: 1.5)),
                            ),
                            validator: (v) =>
                                v!.isEmpty ? "Inserisci un nome" : null,
                          ),
                          const SizedBox(height: 15),
                          TextFormField(
                            controller: _descriptionController,
                            decoration: const InputDecoration(
                              labelText: "Descrizione",
                              labelStyle: TextStyle(
                                  color: Color(0XFFC4B7E1),
                                  fontWeight: FontWeight.bold),
                              border: OutlineInputBorder(),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.black, width: 1)),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color(0XFFC4B7E1), width: 1.5)),
                            ),
                            maxLines: 2,
                          ),
                          const SizedBox(height: 15),
                          TextFormField(
                            controller: _recipeController,
                            decoration: const InputDecoration(
                              labelText: "Ricetta",
                              labelStyle: TextStyle(
                                  color: Color(0XFFC4B7E1),
                                  fontWeight: FontWeight.bold),
                              border: OutlineInputBorder(),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.black, width: 1)),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color(0XFFC4B7E1), width: 1.5)),
                            ),
                            maxLines: 4,
                          ),
                          const SizedBox(height: 15),
                          TextFormField(
                            controller: _timeController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: "Tempo di preparazione (minuti)",
                              labelStyle: TextStyle(
                                  color: Color(0XFFC4B7E1),
                                  fontWeight: FontWeight.bold),
                              border: OutlineInputBorder(),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.black, width: 1)),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color(0XFFC4B7E1), width: 1.5)),
                            ),
                            validator: (v) =>
                                v!.isEmpty ? "Obbligatorio" : null,
                          ),
                          const SizedBox(height: 15),
                          TextFormField(
                            controller: _difficultyController,
                            decoration: const InputDecoration(
                              labelText: "Difficoltà",
                              labelStyle: TextStyle(
                                  color: Color(0XFFC4B7E1),
                                  fontWeight: FontWeight.bold),
                              border: OutlineInputBorder(),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.black, width: 1)),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color(0XFFC4B7E1), width: 1.5)),
                            ),
                          ),
                          const SizedBox(height: 25),
                          const Text(
                            "Ingredienti",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),

// 🔁 Lista ingredienti modificabili
                          Column(
                            children: _editableIngredients
                                .asMap()
                                .entries
                                .map((entry) {
                              final index = entry.key;
                              final ing = entry.value;

                              return Card(
                                color: Color(0XFFC4B7E1),
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    children: [
                                      TextFormField(
                                        initialValue: ing.name,
                                        decoration: const InputDecoration(
                                          labelText: "Nome ingrediente",
                                          labelStyle: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        onChanged: (v) =>
                                            _editableIngredients[index].name =
                                                v,
                                      ),
                                      const SizedBox(height: 8),
                                      TextFormField(
                                        initialValue: ing.quantity.toString(),
                                        keyboardType: TextInputType.number,
                                        decoration: const InputDecoration(
                                          labelText: "Quantità",
                                          labelStyle: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        onChanged: (v) {
                                          final parsed = int.tryParse(v) ?? 0;
                                          _editableIngredients[index].quantity =
                                              parsed;
                                        },
                                      ),
                                      const SizedBox(height: 8),
                                      TextFormField(
                                        initialValue: ing.unit,
                                        decoration: const InputDecoration(
                                          labelText: "Unità (es: g, ml)",
                                          labelStyle: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        onChanged: (v) =>
                                            _editableIngredients[index].unit =
                                                v,
                                      ),
                                      const SizedBox(height: 8),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: TextButton.icon(
                                          onPressed: () {
                                            setState(() {
                                              _editableIngredients
                                                  .removeAt(index);
                                            });
                                          },
                                          icon: const Icon(Icons.delete,
                                              color: Colors.red),
                                          label: const Text("Rimuovi",
                                              style: TextStyle(
                                                  color: Colors.red,
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),

// ➕ Pulsante aggiungi ingrediente
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _openSelect =
                                    !_openSelect; // toggle visualizzazione dropdown
                              });
                            },
                            icon: const Icon(
                              Icons.add,
                              color: Colors.pink,
                            ),
                            label: const Text(
                              "Aggiungi ingrediente",
                              style: TextStyle(
                                  color: Colors.pink,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),

                          _openSelect
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 10),
                                    DropdownButtonFormField<Ingredient>(
                                      decoration: const InputDecoration(
                                        labelText: "Seleziona ingrediente",
                                        border: OutlineInputBorder(),
                                      ),
                                      items: allIngredients.map((ing) {
                                        return DropdownMenuItem<Ingredient>(
                                          value: ing,
                                          child: Text(ing.name),
                                        );
                                      }).toList(),
                                      onChanged: (selected) {
                                        if (selected != null) {
                                          setState(() {
                                            _editableIngredients.add(
                                              IngredientDetail(
                                                ingredientId:
                                                    selected.ingredientId,
                                                name: selected.name,
                                                quantity: 100,
                                                unit: '',
                                              ),
                                            );
                                            _openSelect =
                                                false; // chiudi dropdown
                                          });
                                        }
                                      },
                                    ),
                                    const SizedBox(height: 20),
                                  ],
                                )
                              : const SizedBox(height: 20),

                          ElevatedButton.icon(
                            onPressed: _submitUpdate,
                            icon: const Icon(
                              Icons.save,
                              color: Colors.white,
                            ),
                            label: const Text(
                              "Salva modifiche",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                              backgroundColor: Colors.pink,
                            ),
                          ),
                          const SizedBox(height: 15),
                          OutlinedButton.icon(
                            onPressed: () {
                              setState(() {
                                _isEdit = false;
                              });
                            },
                            icon: const Icon(
                              Icons.cancel,
                              color: Colors.pink,
                            ),
                            label: const Text(
                              "Annulla",
                              style: TextStyle(
                                  color: Colors.pink,
                                  fontWeight: FontWeight.bold),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.pink, width: 1.5),
                              minimumSize: const Size(double.infinity, 50),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        : _buildDetail(mealState);
  }

  Widget _buildDetail(dynamic mealState) {
    final meal = mealState.meal;

    // Se il pasto non è ancora caricato
    if (meal == null) {
      if (mealState.isLoading) {
        return const Center(child: CircularProgressIndicator());
      } else if (mealState.error != null) {
        return Center(
          child: Text(
            mealState.error!,
            style: const TextStyle(color: Colors.red),
          ),
        );
      } else {
        return const Center(child: Text("Pasto non disponibile"));
      }
    }

    final imageUrl = meal.imageMeal;
    final ingredients = meal.ingredients ?? [];

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.33,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: NetworkImage(imageUrl ??
                        'https://media.hellofresh.com/w_3840,q_auto,f_auto,c_limit,fl_lossy/recipes/image/HF220905_R14_W39_IT_IT351-1_MB_Main_highremove_chili_rounds_edit_high-8a6c9450.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Stack(
                  clipBehavior: Clip.none,
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
                          children: [
                            Text(
                              meal.name,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _isEdit = !_isEdit;
                                });
                              },
                              icon: FaIcon(
                                FontAwesomeIcons.pen,
                                size: 20,
                                color: Colors.black,
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
                    padding: const EdgeInsets.symmetric(
                        vertical: 40, horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 230,
                          height: 50,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0XFFC4B7E1),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              )
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.access_time_rounded,
                                  color: Colors.black),
                              const SizedBox(width: 6),
                              Text(
                                '${meal.preparingTime} min',
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FontStyle.italic),
                              ),
                              const SizedBox(width: 30),
                              const Text('|'),
                              const SizedBox(width: 30),
                              const Icon(Icons.bar_chart_outlined,
                                  color: Colors.black),
                              const SizedBox(width: 6),
                              Text(meal.difficulty?.toString() ?? '-')
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                        Text(meal.description ?? '',
                            style: const TextStyle(fontSize: 18)),
                        const SizedBox(height: 16),
                        const Text(
                          "Ingredienti:",
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 15),
                        if (ingredients.isNotEmpty)
                          ...ingredients.map((ing) {
                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: const Color(0XFFC4B7E1), width: 2),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: ListTile(
                                title: Row(
                                  children: [
                                    Text(ing.name),
                                    const Spacer(),
                                    Text("${ing.quantity} ${ing.unit ?? '-'}"),
                                  ],
                                ),
                              ),
                            );
                          }).toList()
                        else
                          const Text("Nessun ingrediente disponibile"),
                        const SizedBox(height: 16),
                        const Text(
                          "Ricetta:",
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 15),
                        Text(meal.recipe ?? '',
                            style: const TextStyle(fontSize: 18)),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
