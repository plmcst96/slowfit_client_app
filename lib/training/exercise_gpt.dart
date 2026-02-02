import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../model/exercise_model.dart';
import '../model/training_model.dart';
import '../provider/bottom_bar_provider.dart';
import '../provider/exercise_provider.dart';
import '../widget/custom_bottom_bar.dart';

class ExerciseGpt extends ConsumerStatefulWidget {
  const ExerciseGpt({
    super.key,
    required this.selectedTypeId,
    required this.level,
  });

  final int selectedTypeId;
  final String level;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _ExerciseGptState();
  }
}

class _ExerciseGptState extends ConsumerState<ExerciseGpt> {
  List<Exercise> allExercises = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAllExercises();
  }

  @override
  void didUpdateWidget(covariant ExerciseGpt oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedTypeId != widget.selectedTypeId) {
      // Se cambia il tipo selezionato, rifai la fetch
      setState(() {
        isLoading = true;
      });
      fetchAllExercises();
    }
  }


  Future<void> fetchAllExercises() async {
    final notifier = ref.read(exerciseProvider.notifier);

    // Fetch exercises for different phases
    var warmUp1 = await notifier.getExerciseGpt(11);
    var warmUp2 = await notifier.getExerciseGpt(15);
    var training = await notifier.getExerciseGpt(widget.selectedTypeId);
    var relax = await notifier.getExerciseGpt(14);

    // Assuming the exercises are stored in the state after calling getExercise
    setState(() {
      allExercises = [...warmUp1, ...warmUp2, ...training, ...relax];
      isLoading = false;
    });
  }

  // Classification logic
  Map<String, List<Exercise>> classifyExercises(List<Exercise> exercises) {
    final Map<String, List<Exercise>> classified = {
      'riscaldamento': [],
      'allenamento': [],
      'stretching': [],
    };

    for (var ex in exercises) {
      if (ex.typeTrainingId == 11 || ex.typeTrainingId == 15) {
        classified['riscaldamento']!.add(ex);
      } else if (ex.typeTrainingId == 14) {
        classified['stretching']!.add(ex);
      } else {
        classified['allenamento']!.add(ex);
      }
    }

    return classified;
  }

  Map<String, dynamic> generateTrainingPlan(List<Exercise> allExercises) {
    final classifiedExercises = classifyExercises(allExercises);

    List<Map<String, dynamic>> selectExercises(List<Exercise> source, int count,
        {required String fase}) {
      final random = Random();
      source.shuffle(random);
      return source.take(count).map((ex) {
        int serie =
            fase == 'riscaldamento' ? 2 : (fase == 'stretching' ? 2 : 4);
        int ripetizioni =
            fase == 'riscaldamento' ? 15 : (fase == 'stretching' ? 10 : 12);
        int recupero =
            fase == 'riscaldamento' ? 30 : (fase == 'stretching' ? 30 : 60);

        return {
          "esercizio": ex.toJson(),
          "serie": serie,
          "ripetizioni": ripetizioni,
          "recupero": recupero,
        };
      }).toList();
    }

    return {
      "Principiante": {
        "riscaldamento": selectExercises(
            classifiedExercises['riscaldamento']!, 3,
            fase: 'riscaldamento'),
        "allenamento": selectExercises(classifiedExercises['allenamento']!, 4,
            fase: 'allenamento'),
        "stretching": selectExercises(classifiedExercises['stretching']!, 3,
            fase: 'stretching'),
      },
      "Intermedio": {
        "riscaldamento": selectExercises(
            classifiedExercises['riscaldamento']!, 4,
            fase: 'riscaldamento'),
        "allenamento": selectExercises(classifiedExercises['allenamento']!, 5,
            fase: 'allenamento'),
        "stretching": selectExercises(classifiedExercises['stretching']!, 4,
            fase: 'stretching'),
      },
      "Avanzato": {
        "riscaldamento": selectExercises(
            classifiedExercises['riscaldamento']!, 4,
            fase: 'riscaldamento'),
        "allenamento": selectExercises(classifiedExercises['allenamento']!, 6,
            fase: 'allenamento'),
        "stretching": selectExercises(classifiedExercises['stretching']!, 4,
            fase: 'stretching'),
      }
    };
  }


  DetailExerciseRequest mapToDetailExerciseRequest(Map<String, dynamic> map) {
    final esercizioMap = map['esercizio'] as Map<String, dynamic>;

    return DetailExerciseRequest(
      exerciseId: esercizioMap['exerciseId'],
      series: map['serie'],
      nRipetition: map['ripetizioni'],
      pause: map['recupero'],
      phase: '',
      image: esercizioMap['image'],
      name: esercizioMap['name'], // o un altro campo se necessario
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(bottomBarProvider);
    final type = ref.watch(typeExerciseProvider);

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final trainingPlan = generateTrainingPlan(allExercises);
    final selectedLevelData = trainingPlan[widget.level];

    String workoutName = 'Workout';
    if (type.isNotEmpty) {
      final match = type.firstWhere(
            (t) => t.typeId == widget.selectedTypeId,
        orElse: () => type.first,
      );
      workoutName = match.typeName;
    }



    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Stack(
        children: [
          // Immagine sfondo
          Container(
            height: MediaQuery.of(context).size.height * 0.33,
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  widget.level == 'Principiante'
                      ? 'assets/principiante.jpg'
                      : widget.level == 'Intermedio'
                          ? 'assets/intermedio.jpg'
                          : 'assets/avanzato.jpg',
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
                child:
                    IconButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/training');
                      },
                      icon: const Icon(Icons.arrow_back_ios),
                      color: Colors.white,
                    ),

              ),
            ),
          ),

          // Contenuto scrollabile
          Positioned(
            top: MediaQuery.of(context).size.height * 0.26,
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
                  padding: EdgeInsets.only(top: 20, left: 20, right: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        child: Column(
                          children: [
                            Text(
                              workoutName,
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  FontAwesomeIcons.clock,
                                  size: 15,
                                ),
                                SizedBox(
                                  width: 6,
                                ),
                                Text('45 minuti'),
                                SizedBox(
                                  width: 12,
                                ),
                                Text('|'),
                                SizedBox(
                                  width: 12,
                                ),
                                Icon(
                                  FontAwesomeIcons.chartColumn,
                                  size: 15,
                                ),
                                SizedBox(
                                  width: 6,
                                ),
                                Text(widget.level),
                              ],
                            ),

                            SizedBox(
                              height: 20,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'Descrizione',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Text(
                          'Questa routine di allenamento è progettata per uomini e donne, giovani e anziani, per chi desidera sviluppare una quantità significativa di massa muscolare e diventare "grosso" o sviluppare una piccola quantità di massa muscolare e semplicemente "tonificarsi". In pratica, se il tuo obiettivo principale è sviluppare la massa muscolare, questo programma fa al caso tuo.'),
                      _buildExercisePhase(
                          'Riscaldamento', selectedLevelData['riscaldamento']),
                      _buildExercisePhase(
                          'Allenamento', selectedLevelData['allenamento']),
                      _buildExercisePhase(
                          'Stretching', selectedLevelData['stretching']),
                      const SizedBox(height: 40), // margine per bottom bar
                    ],
                  ),
                )),
          ),
        ],
      ),
      bottomNavigationBar: FloatingBottomBar(currentIndex: selectedIndex),
    );
  }

  Widget _buildExercisePhase(String phase, List exercises) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 20, bottom: 10),
          child: Text(
            phase,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 10),
        if (exercises.isEmpty)
          const Text("Nessun esercizio disponibile per questa fase.")
        else
          ...exercises.map<Widget>((exercise) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 13),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    // Immagine esercizio
                    Container(
                      width: MediaQuery.of(context).size.width * 0.2,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        image: DecorationImage(
                          image: NetworkImage(
                              exercise['esercizio']['image'] ?? ''),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),

                    // Dettagli esercizio
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              exercise['esercizio']['name'],
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${exercise['serie']} X ${exercise['ripetizioni']} ripetizioni',
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Recupero: ${exercise['recupero']}''",
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
      ],
    );
  }
}
