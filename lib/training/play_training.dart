import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slowFit_client/model/exercise_model.dart';
import 'package:slowFit_client/model/progress_model.dart';
import 'package:slowFit_client/model/training_model.dart';
import 'package:slowFit_client/provider/login_provider.dart';
import 'package:slowFit_client/provider/progress_provider.dart';
import 'package:slowFit_client/training/detail_exercise_sheet.dart';
import '../provider/exercise_provider.dart';
import '../provider/training_provider.dart';

class PlayTraining extends ConsumerStatefulWidget {
  final List<DetailExercise> riscaldamento;
  final List<DetailExercise> allenamento;
  final List<DetailExercise> stretching;
  final int selectedTypeId;
  final int level;
  final Map<int, Exercise> exDet;
  final VoidCallback onClose;
  final int trainingId;

  const PlayTraining({
    super.key,
    required this.riscaldamento,
    required this.allenamento,
    required this.stretching,
    required this.selectedTypeId,
    required this.level,
    required this.exDet,
    required this.onClose,
    required this.trainingId,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PlayTrainingState();
}

class _PlayTrainingState extends ConsumerState<PlayTraining> {
  Timer? _timer;
  int _seconds = 0;
  double _kg = 0;
  int _series = 0;
  Map<int, List<bool>> exerciseChecks = {};
  late Map<int, List<TextEditingController>> kgControllers = {};
  bool _isMinimized = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
    Future.microtask(() {
      ref.read(levelSingleProvider.notifier).getSingleLevel(widget.level);
      ref
          .read(typeSingleProvider.notifier)
          .getSingleType(widget.selectedTypeId);
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (_) {
      setState(() {
        _seconds++;
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _seconds = 0;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    kgControllers.forEach((_, list) {
      for (var controller in list) {
        controller.dispose();
      }
    });
    super.dispose();
  }

  double _calculateTotalKg() {
    double total = 0;
    kgControllers.forEach((exerciseId, controllerList) {
      final checks = exerciseChecks[exerciseId];
      if (checks == null) return;
      for (int i = 0; i < controllerList.length; i++) {
        if (checks[i]) {
          final v = double.tryParse(controllerList[i].text);
          if (v != null) total += v;
        }
      }
    });
    return total;
  }

  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  Widget _miniContainer() {
    return Container(
      decoration: BoxDecoration(color: Colors.grey[200]),
      height: 200,

      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Text(
            'Allenamento in corso',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontSize: 15,
            ),
          ),
          Row(
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _isMinimized = false;
                  });
                },
                child: Row(
                  children: [
                    Icon(Icons.play_circle_outline, color: Colors.pink),
                    SizedBox(width: 10),
                    Text(
                      'Riprendi',
                      style: TextStyle(
                        color: Colors.pink,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Spacer(),

              TextButton(
                onPressed: _confirmDiscardTraining,

                child: Row(
                  children: [
                    Icon(Icons.delete_outline_rounded, color: Colors.red),
                    SizedBox(width: 10),
                    Text(
                      'Scarta',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildExerciseSection(
    String title,
    List<DetailExercise> exercises,
    Map<int, Exercise> exDet,
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

                  // Inizializza checkbox e controller se non presenti
                  exerciseChecks[ex.exerciseId] ??= List.generate(
                    ex.series,
                    (_) => false,
                  );
                  kgControllers[ex.exerciseId] ??= List.generate(
                    ex.series,
                    (i) => TextEditingController(text: ex.kg?.toString() ?? ''),
                  );

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
                        builder: (_) => DetailExerciseSheet(
                          exerciseId: ex.exerciseId,
                          typeId: typeId,
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
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
                            defaultVerticalAlignment:
                                TableCellVerticalAlignment.middle,
                            columnWidths: {
                              0: FlexColumnWidth(0.4),
                              1: FlexColumnWidth(0.5),
                              2: FlexColumnWidth(0.7),
                              3: FlexColumnWidth(0.3),
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
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(''),
                                  ),
                                ],
                              ),
                              ...List.generate(ex.series, (index) {
                                return TableRow(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(8),
                                      child: Text('${index + 1}'),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(8),
                                      child: TextField(
                                        controller:
                                            kgControllers[ex
                                                .exerciseId]![index],
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                          hintText: "kg",
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                        ),
                                        onChanged: (_) {
                                          setState(() {
                                            _kg = _calculateTotalKg();
                                          });
                                        },
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(8),
                                      child: Text('${ex.nRipetition}'),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(8),
                                      child: Checkbox(
                                        value:
                                            exerciseChecks[ex
                                                .exerciseId]![index],
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            5,
                                          ),
                                        ),
                                        activeColor: Colors.blue,
                                        onChanged: (val) {
                                          setState(() {
                                            exerciseChecks[ex
                                                    .exerciseId]![index] =
                                                val!;
                                            _series = exerciseChecks.values
                                                .map(
                                                  (list) => list
                                                      .where((v) => v)
                                                      .length,
                                                )
                                                .fold(0, (a, b) => a + b);
                                            _kg = _calculateTotalKg();
                                          });
                                        },
                                      ),
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

  Widget _fullTrainingView() {
    final typeId = ref.watch(typeSingleProvider)[widget.selectedTypeId]!.typeId;
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildExerciseSection(
            'Riscaldamento',
            widget.riscaldamento,
            widget.exDet,
            typeId,
          ),
          buildExerciseSection(
            'Allenamento',
            widget.allenamento,
            widget.exDet,
            typeId,
          ),
          buildExerciseSection(
            'Stretching',
            widget.stretching,
            widget.exDet,
            typeId,
          ),
        ],
      ),
    );
  }

  void _confirmDiscardTraining() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Annullare allenamento?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Sei sicuro di voler scartare l’allenamento in corso? I progressi andranno persi.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Annulla', style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
            onPressed: () {
              Navigator.of(context).pop(); // chiude il dialog
              _stopTimer();
              widget.onClose(); // chiude il training
            },
            child: Text(
              'Scarta',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _calculateTotalSeries() {
    int total = 0;

    for (final ex in [
      ...widget.riscaldamento,
      ...widget.allenamento,
      ...widget.stretching,
    ]) {
      total += ex.series;
    }

    return total;
  }

  int _calculateProgressValue() {
    final completedSeries = _series;
    final totalSeries = _calculateTotalSeries();

    if (totalSeries == 0) return 0;

    return ((completedSeries / totalSeries) * 100).round();
  }

  Future<void> handelSaveProgress() async {
    final login = ref.read(loginProvider);
    if (login.userId == null) return;

    final progressValue = _calculateProgressValue();

    final progressBody = ProgressTraining(
      userId: login.userId!,
      trainingId: widget.trainingId,
      progressValue: progressValue,
      avarageKg: _kg.toInt(),
      dateOfProgress: DateTime.now(),
      createdAt: DateTime.now(),
    );

    await ref
        .read(progressTrainingProvider.notifier)
        .postProgressTraining(progressBody);
    print(progressValue);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Stack(
        children: [
          GestureDetector(
            onTap: widget.onClose,
            child: Container(width: double.infinity, height: double.infinity),
          ),
          AnimatedPositioned(
            duration: Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            bottom: 0,
            left: 0,
            right: 0,
            height: _isMinimized ? screenHeight * 0.12 : screenHeight * 0.85,
            child: Material(
              color: _isMinimized ? Colors.grey[200] : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Colors.black,
                      width: 1.3,
                    ), // solo bordo superiore
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    children: [
                      SizedBox(height: 30),
                      if (!_isMinimized)
                        Row(
                          children: [
                            IconButton(
                              onPressed: () =>
                                  setState(() => _isMinimized = !_isMinimized),
                              icon: Icon(Icons.arrow_circle_down_sharp),
                            ),
                            Text('Allenamento', style: TextStyle(fontSize: 16)),
                            Spacer(),
                            ElevatedButton(
                              onPressed: () async {
                                _stopTimer();
                                await handelSaveProgress();
                                widget.onClose();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.pink,
                              ),
                              child: Text(
                                'Finito',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      Padding(
                        padding: EdgeInsets.all(15),
                        child: Table(
                          columnWidths: {
                            0: FlexColumnWidth(1),
                            1: FlexColumnWidth(1),
                            2: FlexColumnWidth(1),
                          },
                          children: [
                            TableRow(
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Text(
                                    'Durata',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Text(
                                    'Volume',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Text(
                                    'Serie',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            TableRow(
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(5),
                                  child: Text(
                                    _formatTime(_seconds),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(5),
                                  child: Text(
                                    '${_kg.toString()} kg',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(5),
                                  child: Text(
                                    _series.toString(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Divider(),
                      Expanded(
                        child: _isMinimized
                            ? _miniContainer()
                            : _fullTrainingView(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
