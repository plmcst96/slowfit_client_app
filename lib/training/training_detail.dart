import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slowFit_client/provider/training_provider.dart';
import 'package:slowFit_client/training/detail_exercise_sheet.dart';
import 'package:slowFit_client/training/play_training.dart';

import '../model/training_model.dart';
import '../provider/bottom_bar_provider.dart';
import '../provider/exercise_provider.dart';
import '../widget/custom_bottom_bar.dart';

class TrainingDetail extends ConsumerStatefulWidget {
  const TrainingDetail({
    super.key,
    required this.selectedTypeId,
    required this.training,
    required this.level,
  });

  final int selectedTypeId;
  final int level;
  final TrainingCreateResponse training;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TrainingDetailState();
}

class _TrainingDetailState extends ConsumerState<TrainingDetail> {
  List<DetailExercise> riscaldamento = [];
  List<DetailExercise> stretching = [];
  List<DetailExercise> allenamento = [];
  bool _showPlayTraining = false;

  @override
  void initState() {
    super.initState();
    fetchAllExercisesAndClassify();
    Future.microtask(() {
      ref.read(levelSingleProvider.notifier).getSingleLevel(widget.level);
      ref
          .read(typeSingleProvider.notifier)
          .getSingleType(widget.selectedTypeId);
    });
  }

  Future<void> fetchAllExercisesAndClassify() async {
    final notifier = ref.read(exerciseSingleMapProvider.notifier);

    await Future.wait(
      widget.training.detailExercises.map((ex) async {
        await notifier.getSingleExerciseMap(ex.exerciseId);
      }),
    );

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

    setState(() {});
  }

  Widget buildExerciseSection(
    String title,
    List<DetailExercise> exercises,
    Map<int, dynamic> exDet,
    int typeId,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        SizedBox(height: 10),
        exercises.isEmpty
            ? Container(
                padding: EdgeInsets.symmetric(vertical: 20),
                alignment: Alignment.center,
                child: Text('Nessun contenuto'),
              )
            : Column(
                children: exercises.map((ex) {
                  final exD = exDet[ex.exerciseId];
                  if (exD == null) return SizedBox.shrink();

                  return GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        builder: (context) => DetailExerciseSheet(
                          exerciseId: ex.exerciseId,
                          typeId: typeId,
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity, // width piena della colonna
                      margin: EdgeInsets.symmetric(vertical: 8),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(25),
                                child: Image.network(
                                  exD.image!,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  exD.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.pink,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(Icons.timer_outlined),
                              SizedBox(width: 12),
                              Text('Tempo di riposo: ${ex.pause}s'),
                            ],
                          ),
                          SizedBox(height: 12),
                          Table(
                            columnWidths: {
                              0: FlexColumnWidth(0.5),
                              1: FlexColumnWidth(0.5),
                              2: FlexColumnWidth(0.5),
                            },
                            children: [
                              TableRow(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      'SERIE',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      'KG',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      'RIPETIZIONI',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              // Genera una riga per ogni serie
                              ...List.generate(ex.series, (index) {
                                return TableRow(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text('${index + 1}'),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(8),
                                      child: Text(
                                        ex.kg == null ? '-' : '${ex.kg}Kg',
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text('${ex.nRipetition}'),
                                    ),
                                  ],
                                );
                              }),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
        SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final exDet = ref.watch(exerciseSingleMapProvider);
    final selectedIndex = ref.watch(bottomBarProvider);
    final type = ref.watch(typeSingleProvider);
    final typeDat = type[widget.selectedTypeId];
    final levelMap = ref.watch(levelSingleProvider);
    final levelData = levelMap[widget.level];

    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.23,
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  widget.level == 1
                      ? 'assets/principiante.jpg'
                      : widget.level == 2
                      ? 'assets/intermedio.jpg'
                      : 'assets/avanzato.jpg',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () {
                      ref.read(bottomBarProvider.notifier).updateIndex(1);
                      Navigator.pushNamed(context, '/training');
                    },
                    icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                  ),
                  Center(
                    child: Column(
                      children: [
                        Text(
                          typeDat!.typeName,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${widget.training.duration}',
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            SizedBox(width: 6),
                            Text(
                              'min',
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            SizedBox(width: 10),
                            Text(
                              ' | ',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            SizedBox(width: 10),
                            if (levelData != null)
                              Text(
                                levelData.levelString,
                                style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            top: MediaQuery.of(context).size.height * 0.20,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.only(top: 30),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildExerciseSection(
                      'Riscaldamento',
                      riscaldamento,
                      exDet,
                      typeDat.typeId,
                    ),
                    buildExerciseSection(
                      'Allenamento',
                      allenamento,
                      exDet,
                      typeDat.typeId,
                    ),
                    buildExerciseSection(
                      'Stretching',
                      stretching,
                      exDet,
                      typeDat.typeId,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.18,
            right: 25,
            child: Container(
              padding: EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: Colors.pink,
                borderRadius: BorderRadius.all(Radius.circular(30)),
              ),
              child: IconButton(
                onPressed: () {
                  setState(() {
                    _showPlayTraining= true;
                  });
                },
                icon: Icon(Icons.play_arrow, color: Colors.white),
              ),
            ),
          ),
          // PlayTraining overlay
          if (_showPlayTraining)
            PlayTraining(
              riscaldamento: riscaldamento,
              allenamento: allenamento,
              stretching: stretching,
              selectedTypeId: widget.selectedTypeId,
              level: widget.level,
              exDet: exDet,
              trainingId: widget.training.trainingId,
              onClose: () {
                setState(() {
                  _showPlayTraining = false;
                });
              },
            ),
        ],
      ),
      bottomNavigationBar: FloatingBottomBar(currentIndex: selectedIndex),
    );
  }
}
