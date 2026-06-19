import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slowFit_client/exercise-training/add_exercise.dart';
import 'package:slowFit_client/exercise-training/detail_exercise_sheet.dart';
import 'package:slowFit_client/exercise-training/exercise_gpt.dart';
import 'package:slowFit_client/provider/exercise_provider.dart';

import '../provider/bottom_bar_provider.dart';
import '../provider/chatgpt_api_provider.dart';
import '../provider/user_provider.dart';
import '../widget/custom_bottom_bar.dart';
import 'add_training.dart';

class ExercisePage extends ConsumerStatefulWidget {
  const ExercisePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _ExercisePageState();
  }
}

class _ExercisePageState extends ConsumerState<ExercisePage> {
  int _selectedTypeId =
      1; // Variabile per tenere traccia del tipo di esercizio selezionato
  bool _isOpen = false;
  bool isOpen2 = false;

  void toggleBottomSheet() {
    setState(() {
      isOpen2 = true;
    });
    if (isOpen2) {
      showModalBottomSheet(
        backgroundColor: Colors.white,
        context: context,
        isScrollControlled: true,
        builder: (context) => AddExercise(typeId: _selectedTypeId),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchTypeExercise();
    fetchExercise();
    //fetchExerciseExample();
  }

  void fetchExercise() {
    ref.read(exerciseProvider.notifier).getExercise(1);
  }

  void fetchExerciseExample() {
    ref.read(trainingRequestProvider(_selectedTypeId));
  }

  void fetchTypeExercise() {
    ref.read(typeExerciseProvider.notifier).getTypeExercise();
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(bottomBarProvider);
    final type = ref.watch(typeExerciseProvider);
    final exercise = ref.watch(exerciseProvider);
    final users = ref.watch(userProvider);
    //final trainingAsync = ref.watch(trainingRequestProvider(_selectedTypeId));

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.33,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                image: DecorationImage(
                  image: AssetImage('assets/sfondo_training.jpeg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 10,
                    left: 10,
                    child: IconButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/trainer-home');
                      },
                      icon: Icon(Icons.arrow_back_ios),
                      color: Colors.white,
                    ),
                  ),
                  Positioned(
                    top: MediaQuery.of(context).size.height * 0.10,
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        'Esercizi',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                        ),
                      ),
                    ),
                  ),
                  //Lista dei tipi di allenamento
                  Positioned(
                    top: MediaQuery.of(context).size.height * 0.25,
                    left: 0,
                    right: 0,
                    child: SizedBox(
                      height: 40,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: type.length,
                          itemBuilder: (context, index) {
                            final typeEx = type[index];
                            bool isSelected = _selectedTypeId == typeEx.typeId;

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                              ),
                              child: OutlinedButton(
                                onPressed: () async {
                                  setState(() {
                                    _selectedTypeId = typeEx
                                        .typeId; // Imposta il tipo selezionato
                                  });
                                  await ref
                                      .read(exerciseProvider.notifier)
                                      .getExercise(typeEx.typeId);
                                },
                                style: OutlinedButton.styleFrom(
                                  minimumSize: Size(100, 40),
                                  side: BorderSide(
                                    color: Colors.white,
                                    width: 1.5,
                                  ),
                                  backgroundColor: isSelected
                                      ? Colors.white
                                      : Colors.transparent,
                                  foregroundColor: isSelected
                                      ? Colors.black
                                      : Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: Text(
                                  typeEx.typeName,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (type.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(
                          left: 20,
                          bottom: 10,
                          right: 20,
                          top: 30,
                        ),
                        child: Row(
                          children: [
                            Text(
                              type
                                  .firstWhere(
                                    (t) => t.typeId == _selectedTypeId,
                                    orElse: () => type.first,
                                  )
                                  .typeName,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Spacer(),
                            GestureDetector(
                              onTap: toggleBottomSheet,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.add_circle_outline_outlined,
                                    color: Color(0XFFC4B7E1),
                                  ),
                                  SizedBox(width: 15),
                                  Text(
                                    'Esercizi',
                                    style: TextStyle(
                                      color: Color(0XFFC4B7E1),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    // Lista orizzontale per gli esercizi
                    SizedBox(
                      height:
                          MediaQuery.of(context).size.height *
                          0.33, // Imposta l'altezza fissa
                      child: ListView.builder(
                        shrinkWrap: true, // Permette di adattarsi al contenuto
                        scrollDirection: Axis.horizontal,
                        itemCount: exercise.length,
                        itemBuilder: (context, index) {
                          final ex = exercise[index];
                          return exercise.isNotEmpty
                              ? GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _isOpen = !_isOpen;
                                    });
                                    debugPrint('${ex.exerciseId}');
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      builder: (context) => DetailExercise(
                                        exerciseId: ex.exerciseId,
                                        typeId: _selectedTypeId,
                                      ),
                                    );
                                  },
                                  child: Card(
                                    margin: EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 30,
                                    ),
                                    child: Container(
                                      width:
                                          MediaQuery.of(context).size.width *
                                          0.70,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(15),
                                        ),
                                        image: DecorationImage(
                                          image: NetworkImage(ex.image ?? ''),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      child: Stack(
                                        children: [
                                          Positioned(
                                            top: 20,
                                            right: 40,
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 15,
                                                vertical: 8,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Color(0XFFBAFFA5),
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(20),
                                                ),
                                              ),
                                              child: Text(
                                                ex.name,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              : Container(
                                  child: Text(
                                    'Nessun contenuto',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                );
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        left: 20,
                        bottom: 30,
                        right: 20,
                        top: 10,
                      ),
                      child: Text(
                        'Assegna Workout',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.17,
                      child: users.isNotEmpty
                          ? ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: users.length,
                              itemBuilder: (context, index) {
                                final user = users[index];

                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AddTraining(
                                          userEmail: users[index].email,
                                        ),
                                      ),
                                    );
                                  },
                                  child: SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width *
                                        0.85,
                                    child: Card(
                                      color: Color(0XFFE0F6DA),
                                      margin: EdgeInsets.symmetric(
                                        horizontal: 10,
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.all(16),
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
                                                    Text(
                                                      '${user.firstName} ${user.surname}',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    SizedBox(height: 10),
                                                    Text(
                                                      user.email,
                                                      style: TextStyle(
                                                        fontSize:
                                                            MediaQuery.of(
                                                              context,
                                                            ).size.width /
                                                            35,
                                                      ),
                                                    ),
                                                    SizedBox(height: 10),
                                                    Text(
                                                      user.phone!,
                                                      style: TextStyle(
                                                        fontSize:
                                                            MediaQuery.of(
                                                              context,
                                                            ).size.width /
                                                            35,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Nessun utente da seguire!'),
                                ElevatedButton(
                                  onPressed: () {},
                                  child: Text('Inizia qui'),
                                ),
                              ],
                            ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        left: 20,
                        bottom: 30,
                        right: 20,
                        top: 30,
                      ),
                      child: Text(
                        'Suggerimenti Allenamento',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 3,
                        itemBuilder: (context, index) {
                          final levels = [
                            'Principiante',
                            'Intermedio',
                            'Avanzato',
                          ];
                          final level = levels[index];

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ExerciseGpt(
                                    selectedTypeId: _selectedTypeId,
                                    level: level,
                                  ),
                                ),
                              );
                            },
                            child: Card(
                              margin: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 10,
                              ),
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.70,
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(15),
                                        ),
                                        image: DecorationImage(
                                          image: AssetImage(
                                            level == 'Principiante'
                                                ? 'assets/principiante.jpg'
                                                : level == 'Intermedio'
                                                ? 'assets/intermedio.jpg'
                                                : 'assets/avanzato.jpg',
                                          ),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 20,
                                      right: 40,
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 15,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Color(0XFFBAFFA5),
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(20),
                                          ),
                                        ),
                                        child: Text(
                                          level,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
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
                    ),
                    SizedBox(height: 30),
                  ],
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
