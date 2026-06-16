import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slowFit_client/exercise-training/detail_ex_bottom.dart';
import 'package:slowFit_client/model/exercise_model.dart';
import 'package:slowFit_client/provider/user_provider.dart';

import '../provider/bottom_bar_provider.dart';
import '../provider/exercise_provider.dart';
import '../widget/custom_bottom_bar.dart';

class AddTraining extends ConsumerStatefulWidget {
  const AddTraining({super.key, required this.userEmail});

  final String userEmail;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _AddTrainingState();
  }
}

class _AddTrainingState extends ConsumerState<AddTraining> {
  final _formKey = GlobalKey<FormState>();
  int _selectedTypeId = 1;
  final List<Exercise> _selectedExercises = [];
  final List<Exercise> _selectedExercisesRest = [];
  final List<Exercise> _selectedExercisesStr = [];

  @override
  void initState() {
    super.initState();
    fetchUserByEmail();
    fetchExercise();
    fetchRest();
    fetchStr();
  }

  void fetchRest() {
    ref.read(exerciseRestProvider.notifier).getExerciseRest();
  }

  void fetchStr() {
    ref.read(exerciseStrProvider.notifier).getExerciseStr();
  }

  void fetchUserByEmail() {
    ref.read(userProfileProvider.notifier).fetchUserByEmail(widget.userEmail);
  }

  void fetchExercise() {
    ref.read(exerciseProvider.notifier).getExercise(1);
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(bottomBarProvider);
    final user = ref.watch(userProfileProvider);
    final type = ref.watch(typeExerciseProvider);
    final exercise = ref.watch(exerciseProvider);
    final exerciseRest = ref.watch(exerciseRestProvider);
    final exerciseStr = ref.watch(exerciseStrProvider);

    // Controlla se i dati sono caricati prima di procedere con il build
    if (user == null) {
      return Scaffold(
        body: Center(
            child:
                CircularProgressIndicator()), // Mostra un caricamento mentre i dati non sono pronti
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // Immagine sfondo
          Container(
            height: MediaQuery.of(context).size.height * 0.25,
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  'assets/avanzato.jpg',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Freccia in alto a destra sopra immagine
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: IconButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/trainer-exercise');
                  },
                  icon: const Icon(Icons.arrow_back_ios),
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.23,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: 30,
              ),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.only(top: 20, left: 16, right: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      child: Column(
                        children: [
                          Text(
                            'Workout ${'${user.firstName} ${user.surname}'}',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 20,
                                ),
                                Text(
                                  'Seleziona Riscaldamento',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                                SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      0.20, // Imposta l'altezza fissa
                                  child: ListView.builder(
                                    shrinkWrap:
                                        true, // Permette di adattarsi al contenuto
                                    scrollDirection: Axis.horizontal,
                                    itemCount: exerciseRest.length,
                                    itemBuilder: (context, index) {
                                      final ex = exerciseRest[index];
                                      final isSelected =
                                          _selectedExercisesRest.contains(ex);
                                      return exerciseRest.isNotEmpty
                                          ? GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  if (isSelected) {
                                                    _selectedExercisesRest
                                                        .remove(ex);
                                                  } else {
                                                    _selectedExercisesRest
                                                        .add(ex);
                                                  }
                                                });
                                              },
                                              child: Card(
                                                margin: EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 30),
                                                child: Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.55,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                      Radius.circular(15),
                                                    ),
                                                    image: DecorationImage(
                                                      image: NetworkImage(
                                                          ex.image ?? ''),
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                  child: Stack(
                                                    children: [
                                                      Positioned(
                                                        top: 20,
                                                        right: 10,
                                                        child: Container(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal: 6,
                                                                  vertical: 6),
                                                          decoration: BoxDecoration(
                                                              color: Color(
                                                                  0XFFBAFFA5),
                                                              borderRadius: BorderRadius
                                                                  .all(Radius
                                                                      .circular(
                                                                          20))),
                                                          child: Text(
                                                            ex.name,
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      // Spunta di selezione
                                                      if (isSelected)
                                                        Positioned(
                                                          top: 10,
                                                          left: 10,
                                                          child: Icon(
                                                            Icons.check_circle,
                                                            color: Colors.green,
                                                            size: 24,
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
                                                style: TextStyle(
                                                    color: Colors.black),
                                              ),
                                            );
                                    },
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Text(
                                  'Seleziona Tipo Allenamneto',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                SizedBox(
                                  height: 40,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: type.length,
                                    itemBuilder: (context, index) {
                                      final typeEx = type[index];
                                      bool isSelected =
                                          _selectedTypeId == typeEx.typeId;

                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 5),
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
                                                color: isSelected
                                                    ? Colors.white
                                                    : Colors.black,
                                                width: 1.5),
                                            backgroundColor: isSelected
                                                ? Colors.white
                                                : Colors
                                                    .transparent, // Sfondo bianco se selezionato
                                            foregroundColor: isSelected
                                                ? Colors.black
                                                : Colors
                                                    .black, // Testo nero se selezionato
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                          ),
                                          child: Text(
                                            typeEx.typeName,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      0.20, // Imposta l'altezza fissa
                                  child: ListView.builder(
                                    shrinkWrap:
                                        true, // Permette di adattarsi al contenuto
                                    scrollDirection: Axis.horizontal,
                                    itemCount: exercise.length,
                                    itemBuilder: (context, index) {
                                      final ex = exercise[index];
                                      final isSelected =
                                          _selectedExercises.contains(ex);
                                      return exercise.isNotEmpty
                                          ? GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  if (isSelected) {
                                                    _selectedExercises
                                                        .remove(ex);
                                                  } else {
                                                    _selectedExercises.add(ex);
                                                  }
                                                });
                                              },
                                              child: Card(
                                                margin: EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 30),
                                                child: Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.55,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                      Radius.circular(15),
                                                    ),
                                                    image: DecorationImage(
                                                      image: NetworkImage(
                                                          ex.image ?? ''),
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                  child: Stack(
                                                    children: [
                                                      Positioned(
                                                        top: 20,
                                                        right: 10,
                                                        child: Container(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal: 6,
                                                                  vertical: 6),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Color(
                                                                0XFFBAFFA5),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .all(
                                                              Radius.circular(
                                                                  20),
                                                            ),
                                                          ),
                                                          child: Text(
                                                            ex.name,
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      // Spunta di selezione
                                                      if (isSelected)
                                                        Positioned(
                                                          top: 10,
                                                          left: 10,
                                                          child: Icon(
                                                            Icons.check_circle,
                                                            color: Colors.green,
                                                            size: 24,
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
                                                style: TextStyle(
                                                  color: Colors.black,
                                                ),
                                              ),
                                            );
                                    },
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Text(
                                  'Seleziona Stretching',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                                SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      0.20, // Imposta l'altezza fissa
                                  child: ListView.builder(
                                    shrinkWrap:
                                        true, // Permette di adattarsi al contenuto
                                    scrollDirection: Axis.horizontal,
                                    itemCount: exerciseStr.length,
                                    itemBuilder: (context, index) {
                                      final ex = exerciseStr[index];
                                      final isSelected =
                                          _selectedExercisesStr.contains(ex);
                                      return exerciseStr.isNotEmpty
                                          ? GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  if (isSelected) {
                                                    _selectedExercisesStr
                                                        .remove(ex);
                                                  } else {
                                                    _selectedExercisesStr
                                                        .add(ex);
                                                  }
                                                });
                                              },
                                              child: Card(
                                                margin: EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 30),
                                                child: Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.55,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                      Radius.circular(15),
                                                    ),
                                                    image: DecorationImage(
                                                      image: NetworkImage(
                                                          ex.image ?? ''),
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                  child: Stack(
                                                    children: [
                                                      Positioned(
                                                        bottom: 20,
                                                        right: 10,
                                                        child: SizedBox(
                                                          width: 180, // 👈 limite
                                                          child: Container(
                                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                                                            decoration: const BoxDecoration(
                                                              color: Color(0XFFBAFFA5),
                                                              borderRadius: BorderRadius.all(Radius.circular(20)),
                                                            ),
                                                            child: Text(
                                                              ex.name,
                                                              maxLines: 2,
                                                              textAlign: TextAlign.center,
                                                              overflow: TextOverflow.ellipsis,
                                                              style: const TextStyle(
                                                                fontWeight: FontWeight.bold,
                                                                fontSize: 12,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),

                                                      // Spunta di selezione
                                                      if (isSelected)
                                                        Positioned(
                                                          top: 10,
                                                          left: 10,
                                                          child: Icon(
                                                            Icons.check_circle,
                                                            color: Colors.green,
                                                            size: 24,
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
                                                style: TextStyle(
                                                    color: Colors.black),
                                              ),
                                            );
                                    },
                                  ),
                                ),
                                SizedBox(height: 30),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Color(0XFFC4B7E1)),
                                    onPressed: () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => DetailExBottom(
                                            ex: _selectedExercises,
                                            exRest: _selectedExercisesRest,
                                            exStr: _selectedExercisesStr,
                                            email: user.email,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      'Salva Workout',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 30,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: selectedIndex,
      ),
    );
  }
}
