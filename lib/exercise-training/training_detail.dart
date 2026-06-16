import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slowFit_client/model/training_model.dart';
import 'package:slowFit_client/provider/exercise_provider.dart';
import 'package:slowFit_client/provider/training_provider.dart';
import 'package:slowFit_client/provider/user_provider.dart';

import '../provider/bottom_bar_provider.dart';
import '../widget/custom_bottom_bar.dart';

class TrainingDetail extends ConsumerStatefulWidget {
  const TrainingDetail(
      {super.key,
      required this.userEmail,
      required this.training,
      required this.level,
      required this.type});

  final String userEmail;
  final TrainingCreateResponse training;
  final String level;
  final String type;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _TrainingDetailState();
  }
}

class _TrainingDetailState extends ConsumerState<TrainingDetail> {
  List<DetailExercise> riscaldamento = [];
  List<DetailExercise> stretching = [];
  List<DetailExercise> allenamento = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchAllExercisesAndClassify();
  }

  Future<void> fetchAllExercisesAndClassify() async {
    final notifier = ref.read(exerciseSingleMapProvider.notifier);

    // Fetch di tutti gli exerciseId
    await Future.wait(
      widget.training.detailExercises.map((ex) async {
        await notifier.getSingleExerciseMap(ex.exerciseId);
      }),
    );

    // Ora che i dati sono nel provider, possiamo classificare
    final exMap = ref.read(exerciseSingleMapProvider);

    for (final ex in widget.training.detailExercises) {
      final exercise = exMap[ex.exerciseId];
      if (exercise == null) continue;

      if (exercise.typeTrainingId == 15) {
        riscaldamento.add(ex);
      } else if (exercise.typeTrainingId == 14) {
        stretching.add(ex);
      } else {
        allenamento.add(ex);
      }
    }

    setState(() {}); // Aggiorna il widget
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(bottomBarProvider);
    final user = ref.watch(userSingleProvider);
    final exDet = ref.watch(exerciseSingleMapProvider);
    debugPrint('$exDet');

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
                  'assets/intermedio.jpg',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Freccia in alto a destra sopra immagine
          SafeArea(
            child: Row(children: [Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: IconButton(
                  onPressed: () {
                    ref.read(bottomBarProvider.notifier).updateIndex(3);
                    Navigator.pushNamed(context, '/clients');
                  },
                  icon: const Icon(Icons.arrow_back_ios),
                  color: Colors.white,
                ),
              ),
            ),
              Spacer(),
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: IconButton(
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text("Conferma eliminazione", style: TextStyle(fontWeight: FontWeight.bold),),
                            content: const Text(
                              "Sei sicuro di voler eliminare questo allenamento? Tutti gli esercizi associati verranno rimossi.",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text("Annulla", style: TextStyle(fontWeight: FontWeight.bold),),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text("Elimina", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),),
                              ),
                            ],
                          );
                        },
                      );

                      if (confirmed == true) {
                        await ref
                            .read(trainingProvider.notifier)
                            .deleteTraining(widget.training.trainingId);

                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(" Allenamento eliminato con successo", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                              backgroundColor: Colors.green,
                              duration: Duration(seconds: 2),
                            ),
                          );

                          Navigator.pushNamed(context, '/clients'); // Torna indietro alla lista
                        }
                      }
                    },

                    icon: const Icon(Icons.delete_outline_outlined),
                    color: Colors.white,
                  ),
                ),
              )],) ,
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
                            'Workout ${'${user!.firstName} ${user.surname}'}',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(widget.training.duration.toString()),
                              SizedBox(width: 6),
                              Text('min'),
                              SizedBox(width: 10),
                              Text(' | '),
                              SizedBox(width: 10),
                              Text(widget.level)
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Text(widget.type),
                          SizedBox(
                            height: 20,
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              ' Riscaldamento',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height *
                                0.20, // Imposta l'altezza fissa
                            child: ListView.builder(
                              shrinkWrap:
                                  true, // Permette di adattarsi al contenuto
                              scrollDirection: Axis.horizontal,
                              itemCount: riscaldamento.length,
                              itemBuilder: (context, index) {
                                final ex = riscaldamento[index];
                                final exD = exDet[ex.exerciseId];
                                return riscaldamento.isNotEmpty
                                    ? Card(
                                        margin: EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 30),
                                        child: Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.55,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(15),
                                            ),
                                            image: DecorationImage(
                                              image: NetworkImage(exD!.image!),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          child: Stack(
                                            children: [
                                              Positioned(
                                                top: 20,
                                                right: 10,
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 6),
                                                  decoration: BoxDecoration(
                                                    color: Color(0XFFBAFFA5),
                                                    borderRadius:
                                                        BorderRadius.all(
                                                      Radius.circular(20),
                                                    ),
                                                  ),
                                                  child: Text(
                                                    exD.name,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                bottom: 10,
                                                left: 10,
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 6),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.all(
                                                      Radius.circular(20),
                                                    ),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                          '${ex.series} X ${ex.nRipetition}'),
                                                      SizedBox(
                                                        width: 10,
                                                      ),
                                                      Text(
                                                          '${ex.pause.toString()} sec')
                                                    ],
                                                  ),
                                                ),
                                              )
                                            ],
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
                          SizedBox(
                            height: 20,
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              ' Allenamneto',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height *
                                0.20, // Imposta l'altezza fissa
                            child: ListView.builder(
                              shrinkWrap:
                                  true, // Permette di adattarsi al contenuto
                              scrollDirection: Axis.horizontal,
                              itemCount: allenamento.length,
                              itemBuilder: (context, index) {
                                final ex = allenamento[index];
                                final exD = exDet[ex.exerciseId];
                                return allenamento.isNotEmpty
                                    ? Card(
                                        margin: EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 30),
                                        child: Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.55,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(15),
                                            ),
                                            image: DecorationImage(
                                              image: NetworkImage(exD!.image!),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          child: Stack(
                                            children: [
                                              Positioned(
                                                top: 20,
                                                right: 10,
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 6),
                                                  decoration: BoxDecoration(
                                                    color: Color(0XFFBAFFA5),
                                                    borderRadius:
                                                        BorderRadius.all(
                                                      Radius.circular(20),
                                                    ),
                                                  ),
                                                  child: Text(
                                                    exD.name,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                bottom: 10,
                                                left: 10,
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 6),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.all(
                                                      Radius.circular(20),
                                                    ),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                          '${ex.series} X ${ex.nRipetition}'),
                                                      SizedBox(
                                                        width: 10,
                                                      ),
                                                      Text(
                                                          '${ex.pause.toString()} sec')
                                                    ],
                                                  ),
                                                ),
                                              )
                                            ],
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
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              ' Stretching',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height *
                                0.20, // Imposta l'altezza fissa
                            child: ListView.builder(
                              shrinkWrap:
                                  true, // Permette di adattarsi al contenuto
                              scrollDirection: Axis.horizontal,
                              itemCount: stretching.length,
                              itemBuilder: (context, index) {
                                final ex = stretching[index];
                                final exD = exDet[ex.exerciseId];

                                return stretching.isNotEmpty
                                    ? Card(
                                        margin: EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 30),
                                        child: Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.55,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(15),
                                            ),
                                            image: DecorationImage(
                                              image: NetworkImage(exD!.image!),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          child: Stack(
                                            children: [
                                              Positioned(
                                                top: 20,
                                                right: 10,
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 6),
                                                  decoration: BoxDecoration(
                                                    color: Color(0XFFBAFFA5),
                                                    borderRadius:
                                                        BorderRadius.all(
                                                      Radius.circular(20),
                                                    ),
                                                  ),
                                                  child: Text(
                                                    exD.name,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                bottom: 10,
                                                left: 10,
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 6),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.all(
                                                      Radius.circular(20),
                                                    ),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                          '${ex.series} X ${ex.nRipetition}'),
                                                      SizedBox(
                                                        width: 10,
                                                      ),
                                                      Text(
                                                          '${ex.pause.toString()} sec')
                                                    ],
                                                  ),
                                                ),
                                              )
                                            ],
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
                          SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: selectedIndex,
      ),
    );
  }
}
